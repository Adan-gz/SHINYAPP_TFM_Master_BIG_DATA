
library(recipes)
library(parsnip)
library(dplyr)
# library(tidymodels)


# Preprocesamiento --------------------------------------------------------

data_sj <- readRDS('data/data_sj.RDS')
data_iq <- readRDS('data/data_iq.RDS')

# vars_to_lag <- data_sj %>% select(-c(city,year,week_start_date,weekofyear, total_cases)) %>% names()
recipe_dif16 <- function(df){
  
  recipe( total_cases ~ ., data = df ) %>% 
    
    step_mutate( 'mes' = lubridate::month(week_start_date, label = TRUE) ) %>% 
    
    step_rm( c(city, week_start_date) ) %>% 
    
    step_nzv(  all_numeric_predictors() ) %>% 
    
    step_impute_bag( all_numeric_predictors() ) %>% 
    
    timetk::step_diff( ndvi_ne,ndvi_nw,ndvi_se,ndvi_sw,precipitation_amt_mm,reanalysis_air_temp_k,
                       reanalysis_avg_temp_k,reanalysis_dew_point_temp_k,reanalysis_max_air_temp_k,          
                       reanalysis_min_air_temp_k,reanalysis_precip_amt_kg_per_m2,
                       reanalysis_relative_humidity_percent,reanalysis_sat_precip_amt_mm,
                       reanalysis_specific_humidity_g_per_kg, reanalysis_tdtr_k,                    
                       station_avg_temp_c,station_diur_temp_rng_c,station_max_temp_c,                   
                       station_min_temp_c,station_precip_mm , lag = 16 ) %>% 
    
    step_normalize(all_numeric_predictors()) %>% 
    
    step_dummy( mes, one_hot = TRUE )
}

recipe_binning_mes <- function(df){
  
  recipe( total_cases ~ ., data = df ) %>% 
    
    step_mutate( 'mes' = lubridate::month(week_start_date, label = TRUE) ) %>% 
    
    step_rm( c(city, week_start_date) ) %>% 
    
    step_nzv(  all_numeric_predictors() ) %>% 
    
    step_impute_bag( all_numeric_predictors() ) %>% 
    
    step_discretize( all_numeric_predictors(),num_breaks = 4,min_unique = 2 ) %>% 
    
    step_dummy( all_nominal_predictors(), one_hot = TRUE ) %>% 
    
    step_normalize(all_numeric_predictors())
}

recipe_dif16_prep_sj <- recipe_dif16(df = data_sj) %>%  prep( )
recipe_binning_mes_prep_iq <- recipe_binning_mes(df = data_iq) %>%  prep( )

# Modelo ------------------------------------------------------------------


info_modelo <- readRDS('data/list_models_app.RDS')
list2env(info_modelo, globalenv())
rm(info_modelo)


# Prueba ------------------------------------------------------------------

# data_muestra <- readr::read_csv( file = 'data/data_muestra.csv')
# data_muestra <- data_muestra %>%
#   mutate( 'weekofyear' = lubridate::isoweek(week_start_date),
#           .after = week_start_date )
# data_muestra_bake_sj <- bake( recipe_dif16_prep_sj, new_data = data_muestra %>% filter(city=='sj') )
# #
# predict(fit_sj, new_data = data_muestra_bake_sj)
# 
# data_muestra_bake_iq <- bake( recipe_binning_mes_prep_iq, new_data = data_muestra %>% filter(city=='iq') )
# predict(fit_iq, new_data = data_muestra_bake_iq)

