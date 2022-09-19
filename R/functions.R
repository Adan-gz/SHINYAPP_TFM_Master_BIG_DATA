



plot_error <- function(){
  ggplot( data.frame(x=1,y=1), aes(x,y) )+
    geom_text(aes(label = 'Ha ocurrido un error. Revisa la pestaña de checks'))+
    theme_void()
}

# library(ggplot2);library(patchwork);library(dplyr)

datatable_format <- function(data,page_length=10, length_menu =  c(5,10,15,20), search = F){
  DT::datatable(data, 
                options = list(
                  'scrollX'= TRUE,
                  
                  'pageLength'=page_length,
                  'lengthMenu' = length_menu,
                  'ordering' = FALSE,
                  'searching' = search,
                    
                  
                  "language" = list(
                    "info"=  "Mostrando de _START_ a _END_ de _TOTAL_ filas",
                    "infoEmpty"= "Mostrando 0 de 0 filas",
                    "emptyTable"=  "No hay políticas recogidas para dichos criterios",
                    "lengthMenu"= "Mostrando _MENU_ filas",
                    "loadingRecords"= "Cargando...",
                    "processing"=  "Procesando...",
                    "search"=    "Búsqueda:",
                    "paginate"= list(
                      "first"=     "Primera",
                      "last"=       "Última",
                      "next"=       "Siguiente",
                      "previous"=   "Previa" ) 
                  ) 
                ))
}

plot_evol <- function(file, city, city_name){
  file %>% 
    filter(city == city) %>% 
    select(-c(city,year,weekofyear)) %>%
    tidyr::pivot_longer(-week_start_date) %>% 
    ggplot( aes( x = week_start_date, y = value ) )+
    geom_line( color = '#f46572',size = 1,alpha=.5 )+
    geom_smooth(se=F,color = '#f46572')+
    scale_x_date( labels = ~ksnet::month_label_cat_esp(.x,language = 'spanish') )+
    scale_y_continuous(breaks = scales::breaks_pretty(5),
                       labels = scales::number_format(big.mark = ',',decimal.mark = '.'))+
    labs(y=NULL,x=NULL, title = city_name)+
    theme_light()+
    theme( panel.grid.major.y = element_blank(),
           panel.grid.minor.x = element_blank(),
           panel.grid.minor.y = element_blank(),
           plot.title = element_text(face = 'bold'),
           strip.text = element_text(size = 13))+
    facet_wrap(~name,scales = 'free_y')
}

plot_den <- function(file, city, city_name){
  file %>% 
    filter(city == city) %>% 
    select(-c(week_start_date,city,year,weekofyear)) %>%
    tidyr::pivot_longer(everything(.)) %>% 
    ggplot( aes( x = value ) )+
    geom_density('fill'= '#f46572',color = 'white')+
    scale_x_continuous(breaks = scales::breaks_pretty(3),
                       labels = scales::number_format(big.mark = ',',decimal.mark = '.'))+
    labs(y=NULL,x=NULL, title = city_name)+
    theme_light()+
    theme( panel.grid.major.y = element_blank(),
           panel.grid.minor.x = element_blank(),
           panel.grid.minor.y = element_blank(),
           axis.text.y = element_blank(),
           plot.title = element_text(face = 'bold'),
           strip.text = element_text(size = 13))+
    facet_wrap(~name,scales = 'free')
}
# plot_den(data_muestra,'sj','San Juan')

# plot_pca_cities <- function(file){
#   p_sj <- plot_pca(file = file, 'sj','San Juan')
#   p_iq <- plot_pca(file = file,'iq','Iquitos')
#   
#   p_sj + p_iq
# }

plot_pca <- function(file,city,city_name){
  pca_fit <- FactoMineR::PCA(file %>% 
                              filter(city == city) %>% 
                              select(-c(city,year,weekofyear,week_start_date)),graph = F)
  
  factoextra::fviz_pca_var(pca_fit,repel = T,col.var = "#f46572")+
    labs(title = paste0(city_name,' - PCA'))+
    theme( panel.grid.major.y = element_blank(),
           panel.grid.major.x = element_blank(),
           panel.grid.minor.x = element_blank(),
           panel.grid.minor.y = element_blank(),
           plot.title = element_text(face = 'bold'))
}

infoPred <- readRDS('data/infoPred.RDS')

z_conf <- c(1.28,1.65,1.96,2.58)
names(z_conf) <- c('0.80','0.90','0.95','0.99')

get_pred_interval <- function(data, city, conf){

  z <- z_conf[ conf ]
  
  if( city == 'San Juan' ){
    # df_sj <- data %>% filter(Ciudad == 'San Juan')
    
    out <- data %>% 
      mutate(
        .pred_low = casos_dengue - z * sqrt( infoPred$mse_sj * ( 1 + 1/infoPred$n_sj +
                                                                       (( casos_dengue - infoPred$mean_sj )^2)/infoPred$centroid_dist_sj ) ),
        .pred_high = casos_dengue + z * sqrt( infoPred$mse_sj * ( 1 + 1/infoPred$n_sj +
                                                                        (( casos_dengue - infoPred$mean_sj )^2)/infoPred$centroid_dist_sj  ) )
      )
  } else if( city == 'Iquitos'){
    # df_iq <- data %>% filter(Ciudad == 'Iquitos')
    
    out <- data %>% 
      mutate(
        .pred_low = casos_dengue - z * sqrt( infoPred$mse_iq * ( 1 + 1/infoPred$n_iq +
                                                                       (( casos_dengue - infoPred$mean_iq )^2)/infoPred$centroid_dist_iq ) ),
        .pred_high = casos_dengue + z * sqrt( infoPred$mse_iq * ( 1 + 1/infoPred$n_iq +
                                                                        (( casos_dengue - infoPred$mean_iq )^2)/infoPred$centroid_dist_iq  ) )
      )
  }
  out <- out %>% mutate( across(c(.pred_low,.pred_high),round) )
  return(out)
}
# library(dplyr)
# data <- readRDS(file = 'data/data.RDS')
# data$.pred <- data$total_cases
# get_pred_interval( data ) %>% select(city,contains('pred')) %>% slice_sample(n=10)

plot_predicciones <- function(data,city_label, interactive = TRUE, confCI){
  
  max_3casos <- sort(data$casos_dengue,decreasing = T)[1:3]
  
  df <- get_pred_interval( data, city_label,conf = confCI ) %>% 
    select( 'Fecha' = semana_estimacion, 'Nº casos' = casos_dengue,
            'CI min' = .pred_low, 'CI max' = .pred_high) %>% 
    mutate( 'city'= city_label )

  df %>% ggplot( aes( x = Fecha, y = `Nº casos`, ymin = `CI min`,ymax = `CI max`) )+
    
    geom_ribbon( fill = "#f46572", alpha = .3)+
    
    geom_line(  mapping =aes(group = 1 ),color = "#f46572", size = .5, alpha = .8 )+
    
    geom_smooth(  mapping =aes(group = 1 ), se = F, color =  "#f46572" )+

    geom_point( data = . %>% filter( `Nº casos` %in% max_3casos ),
                size = 3.5, color = "#f46572" )+

    scale_y_continuous(breaks = scales::breaks_pretty(5),
                       labels = scales::number_format(big.mark = ',',decimal.mark = '.'))+

    scale_x_date( breaks = scales::breaks_pretty(11),labels = scales::label_date_short() )+
    labs(x=NULL, y = '')+
    theme_light()+


    theme( panel.grid.major.y = element_blank(),
           panel.grid.minor.x = element_blank(),
           panel.grid.minor.y = element_blank(),
           plot.title = element_text(face = 'bold'),
           strip.text = element_text(size = 13),
           axis.text.y = element_text(size = 10.5))+
    facet_wrap(~city)
}

# temp <- data_sj
# 
# temp$semana_informacion <- data_sj$week_start_date
# temp$semana_estimacion <- data_sj$week_start_date
# temp$casos_dengue <- data_sj$total_cases
# 
# plot_predicciones(temp,'sj') %>% ggplotly(tooltip = 'text')

