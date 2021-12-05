library(rstan)
library(loo)
library(plyr)
library(bayesplot)
library(ggplot2)

data = read.csv(file ="data/quali_differences_processed.csv")
data$teammateId = mapvalues(data$teammateId, unique(data$teammateId), 1:length(unique(data$teammateId)))
data$model_index = data$age-18+1


options(mc.cores = parallel::detectCores())
rstan_options(auto_write=TRUE)

ages = data$age
N = length(unique(ages))
y_rep_ages = c(18, 19, 27, 30, 41) #ages to generate replicated datasets for model evaluation
y_rep_length = sum(data$age %in% y_rep_ages)
y = data[data$age %in% y_rep_ages,]$difference

y_rep_groups = vector(mode="integer", length=y_rep_length)
rep_index = 1
for(j in 1:nrow(data)){
  if(ages[j] %in% y_rep_ages) {
    y_rep_groups[rep_index] = ages[j]
    rep_index = rep_index + 1
  }
}

stan_data <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages), model_index=data$model_index,
                  rep_ages = y_rep_ages, rep_length = y_rep_length)
stan_data_id <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages), 
                  driver_id = data$teammateId, driver_count = length(unique(data$teammateId)), model_index=data$model_index, 
                  ount27 = sum(data$age==27))

fit_separate <- stan(file = "src/stan/separate_model2.stan", data = stan_data)
#fit_hierarchical <- stan(file = "src/stan/hierarchical_model2.stan", data = stan_data)
#fit_pooled <- stan(file = "src/stan/pooled_model2.stan", data = stan_data)

#fit_separate_id <- stan(file = "src/stan/separate_model_ids.stan", data = stan_data_id, iter=6000)
#fit_hierarchical_id <- stan(file = "src/stan/hierarchical_model_ids.stan", data = stan_data_id, iter=5000)
#fit_pooled_id <- stan(file = "src/stan/pooled_model_ids.stan", data = stan_data_id)

llfun <- function(data_i, draws) {
  model_index = data_i$model_index
  dnorm(data_i$difference, draws[[1]][,model_index], draws[[2]][,model_index], log=TRUE)
}

#params <- extract(fit_separate)
#posterior_draws <- list(params$mu[(sample(1:nrow(params$mu), 500)),], params$sigma[(sample(1:nrow(params$mu), 500)),])

#loo_func_separate <- loo(llfun, data = Data, draws = posterior_draws, r_eff = NA)

#loo_mat_separate <- loo(extract_log_lik(fit_separate))
#loo_mat_hierarchical <- loo(extract_log_lik(fit_hierarchical))
#loo_mat_pooled <- loo(extract_log_lik(fit_pooled))

#loo_mat_separate_id <- loo(extract_log_lik(fit_separate_id))
#loo_mat_separate_id_known <- loo(extract(fit_separate_id, pars='log_lik_id')$log_lik_id)
#loo_mat_hierarchical_id <- loo(extract_log_lik(fit_hierarchical_id))
#loo_mat_hierarchical_id_known <- loo(extract(fit_hierarchical_id, pars='log_lik_id')$log_lik_id)
#loo_mat_pooled_id <- loo(extract_log_lik(fit_pooled_id))
#loo_mat_pooled_id_known <- loo(extract(fit_pooled_id, pars='log_lik_id')$log_lik_id)

#yrep_hierarchical <- extract(fit_hierarchical)$yrep27
#yrep_separate <- extract(fit_separate)$yrep27
#yrep_pooled <- extract(fit_pooled)$yrep27

yrep_separate <- extract(fit_separate)$yrep


