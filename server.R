

# Data --------------------------------------------------------------------


muestra_1 <- readRDS(file = 'data/muestra_1.RDS')
muestra_2 <- readRDS(file = 'data/muestra_2.RDS')
muestra_3 <- readRDS(file = 'data/muestra_3.RDS')


muestra_show_app <- muestra_2[c(1:2,nrow(muestra_2)-1,nrow(muestra_2)),]

data_plantilla <- muestra_2[1,-4]


# _ -----------------------------------------------------------------------


# Server ------------------------------------------------------------------


server <- function(input, output) {

# presentacion ------------------------------------------------------------

  output$mapa <-renderImage({
    # When input$n is 3, filename is ./images/image3.jpeg
    filename <- normalizePath(file.path('www/mapa.png'))
    
    # Return a list containing the filename and alt text
    list(src = filename,
         alt = "Imagen extraía de DRIVENDATA",
         class="center")
    
  }, deleteFile = FALSE)
  

# Explicacion -------------------------------------------------------------


  output$muestra_data <- renderDataTable({
    DT::datatable(muestra_show_app,
                  options=list('dom'='t','scrollX'= TRUE,
                               'ordering' = FALSE, 'searching' = FALSE)) })
  
  
  output$data_plantilla <- downloadHandler(
    filename = function() { 'Plantilla_prediccion.csv' },
    content = function(file) { readr::write_csv(data_plantilla, file)   }
  )
  
  output$muestra_1 <- downloadHandler(
    filename = function() { 'Muestra prediccion (1).csv' },
    content = function(file) { readr::write_csv(muestra_1, file)   }
  )
  
  output$muestra_2 <- downloadHandler(
    filename = function() { 'Muestra prediccion (2).csv' },
    content = function(file) { readr::write_csv(muestra_2, file)   }
  )
  
  output$muestra_3 <- downloadHandler(
    filename = function() { 'Muestra prediccion (3 - error).csv' },
    content = function(file) { readr::write_csv(muestra_3, file)   }
  )


# Prediccion --------------------------------------------------------------


  file <- reactive({
    
    file <- input$file
    ext <- tools::file_ext(file$datapath)
    
    req(file)
    validate(need(ext == "csv", "Por favor sube un fichero .csv"))
    
    df_raw <- readr::read_csv(file$datapath) 
    
    if( 'week_start_date' %in% names(df_raw) ){
      df_raw <- df_raw %>%
        mutate( 'weekofyear' = lubridate::isoweek(week_start_date),
                .after = week_start_date )
    }

    return(df_raw)
    })
  
  output$file_head <- renderDataTable( datatable_format(file()) )
  
  file_check <- reactive(  check_data(file()) )
  
  output$file_checks <- renderUI(  flextable::htmltools_value( flextable_checks(file_check()),
                                    ft.shadow = F, ft.htmlscroll = F) ) 
  
## resumen -----------------------------------------------------------------

  output$p_temp_sj <- renderPlot( plot_evol(file = file(),'sj','San Juan') )
  output$p_temp_iq <- renderPlot( plot_evol(file = file(),'iq','Iquitos') )
  
  output$p_dist_sj <- renderPlot( plot_den(file = file(),'sj','San Juan') )
  output$p_dist_iq <- renderPlot( plot_den(file = file(),'iq','Iquitos') )
  
  output$p_pca_sj <- renderPlot( plot_pca(file = file(),'sj','San Juan' ) )
  output$p_pca_iq <- renderPlot( plot_pca(file = file(),'iq','Iquitos') )
    
  

## Estimacion --------------------------------------------------------------
  
  
  predicciones <- reactive({
    
    if( attr(file_check(), 'do_pred') == 'Sí' ){
      ### SAN JUAN
      newdata_sj <- file() %>% dplyr::filter(city == 'sj')
      
      newdata_bake_sj <- bake( recipe_dif16_prep_sj, new_data = newdata_sj)
      
      pred_sj <- predict( fit_sj, new_data = newdata_bake_sj )$.pred
      
      df_pred_sj <- newdata_sj[,c('city','week_start_date')] %>%
        rename( 'Ciudad'=1,'semana_informacion'=2 ) %>%
        mutate(
          'semana_estimacion' = semana_informacion + lubridate::dweeks(1),
          'casos_dengue' = round(pred_sj),
          'casos_dengue' = ifelse(casos_dengue<0,0,casos_dengue))
      
      ### IQUITOS
      newdata_iq <- file() %>% dplyr::filter(city == 'iq')
      
      newdata_bake_iq <- bake( recipe_binning_mes_prep_iq, new_data = newdata_iq)
      
      pred_iq <- predict( fit_iq, new_data = newdata_bake_iq )$.pred
      
      df_pred_iq <- newdata_iq[,c('city','week_start_date')] %>%
        rename( 'Ciudad'=1,'semana_informacion'=2 ) %>%
        mutate(
          'semana_estimacion' = semana_informacion + lubridate::dweeks(1),
          'casos_dengue' = round(pred_iq),
          'casos_dengue' = ifelse(casos_dengue<0,0,casos_dengue))
      
      ## JOIN
      dplyr::bind_rows( df_pred_sj, df_pred_iq ) %>% 
        mutate( Ciudad = factor(Ciudad, c('sj','iq'),c('San Juan','Iquitos')) )
    } else{
      data.frame( 'Ciudad'=NA,'semana_informacion'=NA,'semana_estimacion'=NA,
                  'casos_dengue' = NA)
    }


  })
  
  ## tabla predicciones
  output$df_predictions <- renderDataTable( datatable_format(predicciones(),search = T) )
  
  output$data_predicciones <- downloadHandler(
    filename = function() { paste0('PrediccionesDengue','_',Sys.Date(),'.csv') },
    content = function(file) { readr::write_csv(predicciones(), file)   }
  )
  
  
  ## graficos predicciones
  output$plot_predictions_sj <- renderPlotly({
    
    if(  attr(file_check(), 'do_pred') == 'Sí' ){
      plot_predicciones( predicciones() %>% filter( Ciudad == 'San Juan' ),'San Juan',interactive = F, confCI = input$select_CI )
    } else{
      plot_error()
    }
    
   
  })
  
  output$plot_predictions_iq <- renderPlotly({
    if(  attr(file_check(), 'do_pred') == 'Sí' ){
      plot_predicciones( predicciones() %>% filter( Ciudad == 'Iquitos' ),'Iquitos', interactive = F, confCI = input$select_CI )
    } else{
      plot_error()
      }
  })
  


}