library(flextable)
library(dplyr)

data <- readRDS( file = 'data/data.RDS')

data_check <- data %>% select(-weekofyear,-total_cases)

# check_data(data) %>% attributes()

check_data <- function(file,data = data_check){
  
  tabla_de_checks <- tribble(
    ~ Elementos, ~ '¿Está correcto?',
    'Están todas las variables','',
    'Nombre de las variables', '',
    'Clase de las variables', '',
    'Formato de las fechas','',
    'Formato de las ciudades','',
    'Rango de las variables', '',
    '¿Hacer la predicción?', ''
  ) 

  c_vars <- check_todasvariables( file = file )
  
  c_nombres <- check_nombres(file = file )
  c_clases <- check_clases(file = file )
  c_fecha <- tryCatch( check_fecha(file = file ), error = function(e) 'Error')
  c_ciudad <- check_ciudad(file = file )
  c_rango <- tryCatch( check_rango( file = file ), error = function(e) 'Error')
  
  tabla_de_checks[1,2] <- c_vars
  tabla_de_checks[2,2] <- c_nombres
  tabla_de_checks[3,2] <- c_clases
  tabla_de_checks[4,2] <- c_fecha
  tabla_de_checks[5,2] <- c_ciudad
  # tabla_de_checks[1,2]
  pred <- tabla_de_checks[1,2] == 'Correcto' & tabla_de_checks[2,2] == 'Correcto' &
          tabla_de_checks[3,2] == 'Correcto' & tabla_de_checks[4,2]  == 'Correcto' &
           tabla_de_checks[5,2] == 'Correcto'

  pred <- ifelse( pred == F, 'No','Sí')
 
  tabla_de_checks[7,2] <- pred
  tabla_de_checks[6,2] <- c_rango
  
  attr(tabla_de_checks, 'do_pred') <- as.character(pred)
  
  return( tabla_de_checks )
}

# attributes( check_data(data) )

flextable_checks <- function(tabla_de_checks){
  flextable::flextable( tabla_de_checks  ) %>% 
    # theme_vanilla() %>% 
    bold(part = 'header') %>% 
    bold(i=7,j=c(1,2)) %>% 
    fontsize( part = 'body',j = 1:2, size = 10 ) %>% 
    fontsize( part = 'body',i = 6,j = 2, size = 7.5 ) %>% 
    width( j = 1, 5,unit = 'cm' ) %>% 
    width( j = 2, 4,unit = 'cm' ) 
}

# todas las variables -----------------------------------------------------

check_todasvariables <- function(file,data = data_check){
 out <- tryCatch( file[,names(data_check)], error = function(e) 'Error' )
 if( is.character(out) ) return('Error')
 out <- ncol(out) == 23
 ifelse( out == F, 'Error','Correcto')
}


tryCatch( data[,names(data_check)], error = function(e) 'Error' )

# nombres -----------------------------------------------------------------

check_nombres <- function(file,data = data_check){
  
  file <- tryCatch( file[,names(data)], error = function(e) 'Error' )
  if( is.character(file) ) return('Error')
  
  out <- suppressWarnings( all( names(file) == names(data) ) )
  ifelse( out == F, 'Error','Correcto')
  
}


# clases ------------------------------------------------------------------

check_clases <- function(file,data = data_check){
  
  file <- tryCatch( file[,names(data)], error = function(e) 'Error' )
  if( is.character(file) ) return('Error')
  
  clases_file <- purrr::map_chr(file,class)
  clases_data <- purrr::map_chr(data,class)
  out <- suppressWarnings( all( clases_file == clases_data ) )
  ifelse( out == F, 'Error','Correcto')
}


# fecha -------------------------------------------------------------------

check_fecha <- function(file){
  # checkeamos un 5% de las observaciones aleatoriamente
  fechas <- file[['week_start_date']][ sample(1:nrow(file), round(nrow(file))*.05 ) ]
  out <- all( sapply(fechas,check_1fecha) )
  ifelse( out == F, 'Error','Correcto')
}


check_1fecha <- function(fecha){
  
  
  fecha <- as.character( fecha )
  
  split_fecha <- strsplit(fecha, '-')[[1]]

  n_1 <- nchar(split_fecha[1]==1)
  n_2 <- nchar(split_fecha[2]==2)
  n_3 <- nchar(split_fecha[3]==2)
  range_2 <- as.numeric(split_fecha[2]) >= 1 & as.numeric(split_fecha[2]) <= 12
  range_3 <- as.numeric(split_fecha[3]) >= 1 & as.numeric(split_fecha[3]) <= 31
  
 all( n_1,n_2,n_3,range_2,range_3 )
}


# ciudad ------------------------------------------------------------------

check_ciudad <- function(file){
  
  vec_city <- tryCatch(file[['city']], error = function(e) NA )
  if( is.na(vec_city) ) return('Error')
  out <- all(sort(unique(vec_city)) %in% c('iq','sj'))
  ifelse( out == F, 'Error','Correcto')
}

# rango de las variables --------------------------------------------------

vars_to_check <- data %>% select(-c(city,year, week_start_date, weekofyear,total_cases)) %>% names()

meansd_5times <- purrr::map_dbl(data[,vars_to_check], ~ abs( mean(.x,na.rm = TRUE) + sd(.x,na.rm = TRUE)*5 ))

check_rango <- function(file){
  file_range <- file[,vars_to_check]
  # return(file_range)
  temp_check <- purrr::map2_chr( file_range, meansd_5times, 
                                 function(var,mean_sd5) {
    
    out <- any( abs(max(var,na.rm = T)) > mean_sd5,
         abs(min(var,na.rm = T)) > mean_sd5 )
    ifelse( out == T, 'warning',NA )
  })
  vars_warning <- names( temp_check[ which(!is.na(temp_check)) ] )

  ifelse( length(vars_warning) >= 1,
          paste0( 'Ojo, las siguientes variables tienen valores hasta 5 desviaciones típicas superiores a la media: ',
                  paste0( vars_warning, collapse = ', ' ) ),
          'Correcto'

          )
}


