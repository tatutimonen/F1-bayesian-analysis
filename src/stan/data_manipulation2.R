library(rstan)
library(loo)
library(plyr)
data = read.csv(file ="data/quali_differences_processed.csv")
#data = head(data[order(data$age),], 500)

options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)
ages = data$age
N = length(unique(ages))
stan_data <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages))
fit2 <- stan(file = "src/stan/separate_model2.stan", data = stan_data)
#print(fit)