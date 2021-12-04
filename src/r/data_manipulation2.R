library(rstan)
library(loo)
library(plyr)

data = read.csv(file ="data/quali_differences_processed.csv")
data$teammateId = mapvalues(data$teammateId, unique(data$teammateId), 1:length(unique(data$teammateId)))
data$model_index = data$age-18+1


options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)

ages = data$age
N = length(unique(ages))
stan_data <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages), model_index=data$model_index)
stan_data_id <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages), 
                  driver_id = data$teammateId, driver_count = length(unique(data$teammateId)), model_index=data$model_index)

fit_separate <- stan(file = "src/stan/separate_model2.stan", data = stan_data)
fit_hierarchical <- stan(file = "src/stan/hierarchical_model2.stan", data = stan_data)
fit_pooled <- stan(file = "src/stan/pooled_model2.stan", data = stan_data)

fit_separate_id <- stan(file = "src/stan/separate_model_ids.stan", data = stan_data_id, iter=6000)


llfun <- function(data_i, draws) {
  model_index = data_i$model_index
  dnorm(data_i$difference, draws[[1]][,model_index], draws[[2]][,model_index], log=TRUE)
}

#params <- extract(fit_separate)
#posterior_draws <- list(params$mu[(sample(1:nrow(params$mu), 500)),], params$sigma[(sample(1:nrow(params$mu), 500)),])

#loo_func_separate <- loo(llfun, data = Data, draws = posterior_draws, r_eff = NA)

loo_mat_separate <- loo(extract_log_lik(fit_separate))
loo_mat_hierarchical <- loo(extract_log_lik(fit_hierarchical))
loo_mat_pooled <- loo(extract_log_lik(fit_pooled))

loo_mat_separate_id <- loo(extract_log_lik(fit_separate_id))

