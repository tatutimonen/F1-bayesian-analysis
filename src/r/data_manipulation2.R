library(rstan)
library(loo)
library(plyr)

data = read.csv(file ="data/quali_differences_processed.csv")
data$model_index = copy$age-18+1

options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)

ages = data$age
N = length(unique(ages))
stan_data <- list(N = N, total_length = nrow(data), time = data$difference, model_index = data$model_index, age = ages, min_age = min(ages))
#fit <- stan(file = "src/stan/separate_model2.stan", data = stan_data)

llfun <- function(data_i, draws) {
  model_index = data_i$model_index;
  dnorm(data_i$difference, draws[[1]][,model_index], draws[[2]][,model_index], log=TRUE)
}

params <- extract(fit)
posterior_draws <- list(params$mu[(sample(1:nrow(params$mu), 500)),], params$sigma[(sample(1:nrow(params$mu), 500)),])

loo_3 <- loo_i(i = 3, llfun = llfun, data = data, draws = posterior_draws, r_eff = NA)
loo_val <- loo(llfun, data = data, draws = posterior_draws, r_eff = NA)
loo_val
