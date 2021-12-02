library(rstan)
library(loo)
library(plyr)
data = read.csv(file ="data/quali_differences_processed.csv")
data = data[order(data$age),]
ages = sort(unique(data$age))
data_diff = c()
data_ids = c()
sizes = c()
data$teammateId = mapvalues(data$teammateId, unique(data$teammateId), 1:length(unique(data$teammateId)))
for (i in ages){
  indices = (data$age)==i
  sizes = c(sizes, length(data$difference[indices]))
  data_diff = c(data_diff, c(data$difference[indices]))
  data_ids = c(data_ids, c(data$teammateId[indices]))
}



data_differences = matrix(0, nrow = max(sizes), ncol = length(sizes))
data_driver_ids = matrix(0, nrow = max(sizes), ncol = length(sizes))
k=1
for(i in 1:length(sizes)){
  for(j in 1:sizes[i]){
    data_differences[j,i] = data_diff[k]
    data_driver_ids[j,i] = data_ids[k]
    k = k+1
  }
}
options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)
stan_data <- list(time = data_differences, N = ncol(data_differences), max_i=nrow(data_differences), 
                  I = sizes, driver_id = data_driver_ids, driver_count = length(unique(data_ids)))
#fit <- stan(file = "src/stan/separate_model_ids.stan", data = stan_data, iter=10000)
#print(fit)
#loo(fit)
ctrl = list(adapt_delta = 0.999)
fit_hierarchical <- stan(file = "src/stan/hierarchical_model_ids.stan", data = stan_data, iter=10000, control=ctrl)
print(fit_hierarchical)