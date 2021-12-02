library(rstan)
library(loo)
library(plyr)
data = read.csv(file ="data/quali_differences_processed.csv")
data = data[order(data$age),]
ages = sort(unique(data$age))
data_diff = c()
data_ids = c()
sizes = c()
for (i in ages){
  indices = (data$age)==i
  sizes = c(sizes, length(data$difference[indices]))
  data_diff = c(data_diff, c(data$difference[indices]))
}



data_differences = matrix(0, nrow = max(sizes), ncol = length(sizes))
data_indices = matrix(0, nrow = max(sizes), ncol = length(sizes))
k=1
for(i in 1:length(sizes)){
  for(j in 1:sizes[i]){
    data_differences[j,i] = data_diff[k]
    data_indices[j,i] = k
    k = k + 1
  }
}
options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)
stan_data <- list(time = data_diff, N = ncol(data_differences), max_i=nrow(data_differences), I = sizes, indices = data_indices, total_length = length(data_diff))
fit <- stan(file = "src/stan/separate_model.stan", data = stan_data)
print(fit)