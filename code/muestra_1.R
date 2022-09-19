
library(dplyr)
df <- readRDS('data/data.RDS')

df_sj <- df %>%
  filter( city == 'sj' ) %>%
  select(ndvi_ne:station_precip_mm) %>%
  na.omit()

df_iq <- df %>%
  filter( city == 'iq' ) %>%
  select(ndvi_ne:station_precip_mm) %>%
  na.omit()

set.seed(123)
muestra_sj <- ksnet::generate_synthetic_object(df_sj) %>%
  slice_sample( n = 28 )

set.seed(123)
muestra_iq <- ksnet::generate_synthetic_object(df_iq) %>%
  slice_sample( n = 28 )

fechas <- seq.Date( lubridate::as_date('2014-09-08'), lubridate::as_date("2015-03-16"), by = '1 week' )

muestra_sj <- muestra_sj %>%
  mutate( 'week_start_date' = fechas,.before = 1 ) %>%
  mutate( 'city' = 'sj',
          'year' = lubridate::year(week_start_date),
          'weekofyear' = lubridate::isoweek( week_start_date ),
          .before = 1 )

muestra_iq <- muestra_iq %>%
  mutate( 'week_start_date' = fechas,.before = 1 ) %>%
  mutate( 'city' = 'iq',
          'year' = lubridate::year(week_start_date),
          'weekofyear' = lubridate::isoweek( week_start_date ),
          .before = 1 )

muestra_1 <- bind_rows(muestra_sj, muestra_iq)

muestra_1[['station_precip_mm']][1] <- mean(muestra_1$station_precip_mm)+
  6*sd(muestra_1$station_precip_mm)

muestra_1[['ndvi_ne']][25] <- mean(muestra_1$ndvi_ne)+
  6*sd(muestra_1$ndvi_ne)


muestra_1[['station_avg_temp_c']][50] <- mean(muestra_1$station_avg_temp_c)+
  6*sd(muestra_1$station_avg_temp_c)

saveRDS(muestra_1,'data/muestra_1.RDS' )


# checks ------------------------------------------------------------------

# muestra_1 <- readRDS(file = 'data/muestra_1.RDS')
# 
# check_data(muestra_1)
# 
# summary(muestra_1$station_avg_temp_c)
# 
# 
# muestra_1[['station_precip_mm']][1] <- mean(muestra_1$station_precip_mm)+
#   6*sd(muestra_1$station_precip_mm)
# 
# muestra_1[['ndvi_ne']][25] <- mean(muestra_1$ndvi_ne)+
#   6*sd(muestra_1$ndvi_ne)
# 
# 
# muestra_1[['station_avg_temp_c']][1] <- mean(muestra_1$station_avg_temp_c)+
#   6*sd(muestra_1$station_avg_temp_c)


# temp <- muestra_1 %>% select(-5)
# 
# check_data(temp)
# check_todasvariables(temp)
# check_nombres(temp)
# check_clases(temp)
# check_fecha(temp)
# check_ciudad(temp)
# check_rango(temp)

