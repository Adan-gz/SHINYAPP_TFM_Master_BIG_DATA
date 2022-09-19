
data <- readRDS(file = 'data/data.RDS')
data_muestra <- data %>%
  select(-total_cases,weekofyear) %>%
  group_by(city) %>%
  slice_tail(n = 100) %>%
  ungroup()

# readr::write_csv(data_muestra, file = 'data/muestra_2.csv')
saveRDS(data_muestra, file = 'data/muestra_2.RDS')

set.seed(23)
muestra_3 <- data_muestra %>% 
  select( -c(week_start_date,ndvi_ne) ) %>% 
  slice_sample( n = 20 )

saveRDS(muestra_3, file = 'data/muestra_3.RDS')
