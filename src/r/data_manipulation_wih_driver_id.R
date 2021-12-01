library(rstan)
library(loo)
library(plyr)
data = read.csv(file ="data/quali_differences_processed.csv")
data = data[order(data$age),]
ages = sort(unique(data$age))
data_differences = c()
data_ids = c()
sizes = c()
data$driverId = mapvalues(data$driverId, unique(data$driverId), 1:length(unique(data$driverId)))
for (i in ages){
  indices = (data$age)==i
  sizes = c(sizes, length(data$difference[indices]))
  data_differences = c(data_differences, c(data$difference[indices]))
  data_ids = c(data_ids, c(data$driverId[indices]))
}



data_differences = matrix(0, nrow = max(sizes), ncol = length(sizes))
data_driver_ids = matrix(0, nrow = max(sizes), ncol = length(sizes))
k=1
for(i in 1:length(sizes)){
  for(j in 1:sizes[i]){
    data_differences[j,i] = data_differences[k]
    data_driver_ids[j,i] = data_ids[k]
    k = k+1
  }
}

stan_data <- list(time = data_differences, N = ncol(data_differences), max_i=nrow(data_differences), 
                  I = sizes, driver_id = data_driver_ids, driver_count = length(unique(data_ids)))
fit <- stan(file = "src/stan/separate_model_ids.stan", data = stan_data)
print(fit)
#loo(fit)
