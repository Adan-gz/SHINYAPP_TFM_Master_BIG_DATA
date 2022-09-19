


data <- readRDS('data/data.RDS') 

data_num <- data %>% select_if( is.numeric ) %>% 
  select(-c(total_cases,year,weekofyear))

nombre_variables <- names(data)
clase_variables <- purrr::map_chr(data,class)


rango_aceptable_variables <- purrr::map_dbl(
  data_num, function(var){
    mean(var, na.rm = TRUE) + 5*sd(var, na.rm = TRUE)
  }
)

# saveRDS( list('nombre_variables' = nombre_variables,
#               'clase_variables' = clase_variables,
#               'rango_aceptable_variables' = rango_aceptable_variables),
#          file = 'data/info_checkear_dataset.rds'
#         )

# Realizo una función para checkear que el dataset importado es correcto

df_import <- data 
df_import_name <- data %>% select(-1)
df_import_class <- data %>% mutate( year = as.factor(year) )

readr::write_csv( df_import_name, 'data/df_import_name.csv' )
readr::write_csv( df_import_class, 'data/df_import_class.csv' )


check_import_data <- function(df_imp){
  
  ## checkear los nombres y ordenar
  df <-  tryCatch(
    df_imp[ , names(data) ],
    error = function(e) 'Faltan variables o los nombres están mal escritos'
  )
  
  if( is.character( df ) )  stop( df )
  
  ## transformar week_start_date a fecha y checkear
  df$week_start_date <- lubridate::as_date( df$week_start_date )
  
  if( sum( is.na( df$week_start_date  ) == nrow(df) ) ){
    stop('La variable week_start_date debe seguir el formato yyyy-mm-dd')
  }
  
  ## checkear la clase de las variables
  correct_check_class <- check_class( df )
  
  if( is.character(correct_check_class) ) stop( correct_check_class )
  
  ## checkear que weekofyear esté entre 1 y 53
  if( min( df$weekofyear ) < 1  ) stop('El valor mínimo de weekofyear no puede ser inferior a 1')
  if( max( df$weekofyear ) > 53 ) stop('El valor mínimo de weekofyear no puede ser superior a 53')
  
  ## checkear el rango de datos de cara variable y dar un warning como atributo  
  
  checkeo_rango <- check_var_range( df )
  
  attr(df,'warning') <- checkeo_rango
  
  return(df)
}

check_import_data( df_import_name  )
check_import_data( df_import_class  )
check_import_data( df_import  )
glimpse(df_import)


check_class <- function( df_imp ){
  
  df_comparacion <- tibble(
    'id' = 1:length(clase_variables),
    'original' = clase_variables,
    'importado' = purrr::map_chr(df_imp,class) ) %>% 
    mutate( all_equal = original == importado )  %>% 
    filter( !all_equal )
  
  n_desigual <- df_comparacion %>% nrow()
  
  if( n_desigual == 0 ){
    out <- TRUE
  }
  
  else{
    
    vars_error <- names(clase_variables)[ df_comparacion$id ]
    
    out <- paste0('No coinciden las clases de las variables: ', 
                  paste0( vars_error, collapse = ', ' ))
    
    
  }
  return(out)
  
}
check_class( df_import_class )
check_class( df_import )


check_var_range <- function(df_imp){
  
  df <- df_imp[,names(rango_aceptable_variables)]
  
  var_warning <- c()
  
  for (i in 1:ncol(df)) {
    
    range_var <- abs( range( df[[i]], na.rm = TRUE ) )
    
    mean3sd_var <- rango_aceptable_variables[i]
    
    is_warning <- any( range_var > mean3sd_var ) 
    
    if( is_warning ){
      var_warning <- c( var_warning, names(df[,i]) )
    }
    
  }
  
  if( length(var_warning) > 0 ){
    var_warning <- paste0( 'Ojo, esta/s variable/s tienen valores de hasta 5 desviaciones típicas superiores a la media: ',
                           paste0( var_warning, collapse = ', ' ))
  }
  
  return( var_warning )
  
}


