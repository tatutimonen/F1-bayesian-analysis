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
y_rep_ages = c(19, 27, 41) #ages to generate replicated datasets for model evaluation
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
stan_data_id <- list(N = N, total_length = nrow(data), time = data$difference, age = ages, min_age = min(ages), model_index=data$model_index, 
                     rep_ages = y_rep_ages, rep_length = y_rep_length, driver_id = data$teammateId, driver_count = length(unique(data$teammateId)))

fit_separate <- stan(file = "src/stan/separate_model.stan", data = stan_data)
fit_hierarchical <- stan(file = "src/stan/hierarchical_model.stan", data = stan_data)
fit_pooled <- stan(file = "src/stan/pooled_model.stan", data = stan_data)

fit_separate_dprior <- stan(file = "src/stan/separate_model_dprior.stan", data = stan_data)
fit_hierarchical_dprior <- stan(file = "src/stan/hierarchical_model_dprior.stan", data = stan_data)
fit_pooled_dprior <- stan(file = "src/stan/pooled_model_dprior.stan", data = stan_data)

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

loo_mat_separate <- loo(extract_log_lik(fit_separate))
loo_mat_hierarchical <- loo(extract_log_lik(fit_hierarchical))
loo_mat_pooled <- loo(extract_log_lik(fit_pooled))

loo_mat_separate_dprior <- loo(extract_log_lik(fit_separate_dprior))
loo_mat_hierarchical_dprior <- loo(extract_log_lik(fit_hierarchical_dprior))
loo_mat_pooled_dprior <- loo(extract_log_lik(fit_pooled_dprior))

#loo_mat_separate_id <- loo(extract_log_lik(fit_separate_id))
#loo_mat_separate_id_known <- loo(extract(fit_separate_id, pars='log_lik_id')$log_lik_id)
#loo_mat_hierarchical_id <- loo(extract_log_lik(fit_hierarchical_id))
#loo_mat_hierarchical_id_known <- loo(extract(fit_hierarchical_id, pars='log_lik_id')$log_lik_id)
#loo_mat_pooled_id <- loo(extract_log_lik(fit_pooled_id))
#loo_mat_pooled_id_known <- loo(extract(fit_pooled_id, pars='log_lik_id')$log_lik_id)

#yrep_separate <- extract(fit_separate)$yrep
#yrep_hierarchical <- extract(fit_hierarchical)$yrep
#yrep_pooled <- extract(fit_pooled)$yrep

#yrep_separate_id <- extract(fit_separate_id, pars='yrep')$yrep
#yrep_separate_id_known <- extract(fit_separate_id, pars='yrep_id')$yrep_id

#yrep_hierarchical_id <- extract(fit_hierarchical_id, pars='yrep')$yrep
#yrep_hierarchical_id_known <- extract(fit_hierarchical_id, pars='yrep_id')$yrep_id

#ppc_dens_overlay_grouped(y, yrep_hierarchical[1:50,], y_rep_groups)

#mu_separate_id <- extract(fit_separate_id, pars='mu')$mu
#mu_hierarchical <- extract(fit_hierarchical, pars='mu')$mu

num_ages = length(unique(ages))
probs_separate_id = vector(mode= 'numeric', length = num_ages)
probs_hierarchical = vector(mode= 'numeric', length = num_ages)

for (i in 1:num_ages) {
  mu1 = mu_hierarchical[,i]
  prob = 1
  for (j in 1:num_ages) {
    if (j != i) {
      mu2 = mu_hierarchical[,j]
      prob = prob * (sum(mu[,j]>mu[,i])/length(mu[,1]))
    }
  }
  probs_hierarchical[i] = prob
}

probs_df <- data.frame(probs_hierarchical/sum(probs_hierarchical), sort(unique(ages)))
colnames(probs_df) <-c('prob', 'age')

#print(fit_separate, pars=c('mu', 'sigma'))
