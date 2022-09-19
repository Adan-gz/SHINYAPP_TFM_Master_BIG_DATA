
data <- readRDS('data/data.RDS') %>% 
  select( -fe_iso_week, -contains('fe')) 

plantilla <- plantilla[1, ]
plantilla[1,] <- NA

readr::write_csv(plantilla,file = 'data/plantilla.csv')


data_sample <- data %>% 
  slice_sample( n = 20 )
readr::write_csv(data_sample,file = 'data/data_sample.csv')
