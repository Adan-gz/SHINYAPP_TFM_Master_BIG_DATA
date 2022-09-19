
## informacio necesaria para calcular los intervalos de prediccion!!

### PREDICTION INTERVAL
n_sj <- 935
n_iq <- 519

mean_sj <- 34.21
mean_iq <- 7.58

mse_sj <- 15.37
mse_iq <- 6.47

centroid_dist_sj <- 2467531
centroid_dist_iq <- 60092.43

infoPred <- list('n_sj' = n_sj,
                 'n_iq' = n_iq,
                 'mean_sj' = mean_sj,
                 'mean_iq' = mean_iq,
                 'mse_sj' = mse_sj,
                 'mse_iq' = mse_iq,
                 'centroid_dist_sj' = centroid_dist_sj,
                 'centroid_dist_iq' = centroid_dist_iq)

saveRDS(infoPred, 'data/infoPred.RDS')
