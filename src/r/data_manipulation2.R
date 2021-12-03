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

llfun <- function(data_i, draws, min_age) {
  # each time called internally within loo the arguments will be equal to:
  # data_i: ith row of fake_data (fake_data[i,, drop=FALSE])
  # draws: entire fake_posterior matrix
  model_index = data_i$age-min_age+1;
  dnorm(data_i, draws$mu[,model_index], draws$sigma[,model_index])
}