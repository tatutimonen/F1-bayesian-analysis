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


fit_separate_id <- stan(file = "src/stan/separate_model_ids.stan", data = stan_data_id, iter=6000)
#fit_hierarchical_id <- stan(file = "src/stan/hierarchical_model_ids.stan", data = stan_data_id, iter=5000)
#fit_pooled_id <- stan(file = "src/stan/pooled_model_ids.stan", data = stan_data_id)

llfun <- function(data_i, draws) {
  model_index = data_i$model_index
  dnorm(data_i$difference, draws[[1]][,model_index], draws[[2]][,model_index], log=TRUE)
}


loo_mat_separate <- loo(extract_log_lik(fit_separate))
loo_mat_hierarchical <- loo(extract_log_lik(fit_hierarchical))
loo_mat_pooled <- loo(extract_log_lik(fit_pooled))


loo_mat_separate_id_known <- loo(extract(fit_separate_id, pars='log_lik_id')$log_lik_id)
#loo_mat_hierarchical_id_known <- loo(extract(fit_hierarchical_id, pars='log_lik_id')$log_lik_id)
#loo_mat_pooled_id_known <- loo(extract(fit_pooled_id, pars='log_lik_id')$log_lik_id)

yrep_separate <- extract(fit_separate)$yrep
yrep_hierarchical <- extract(fit_hierarchical)$yrep
yrep_pooled <- extract(fit_pooled)$yrep


yrep_separate_id_known <- extract(fit_separate_id, pars='yrep_id')$yrep_id
#yrep_hierarchical_id_known <- extract(fit_hierarchical_id, pars='yrep_id')$yrep_id

# Use yrep of any model to plot for that model
ppc_dens_overlay_grouped(y, yrep_separate_id_known[1:50,], y_rep_groups) + theme_bw(base_size=18)

mu <- extract(fit_separate_id, pars='mu')$mu


# Calculate probabilities for each age of being the best
num_ages = length(unique(ages))
probs = vector(mode= 'numeric', length = num_ages)
for (i in 1:num_ages) {
  mu1 = mu[,i]
  prob = 1
  for (j in 1:num_ages) {
    if (j != i) {
      mu2 = mu[,j]
      prob = prob * (sum(mu2>mu1)/length(mu1))
    }
  }
  probs[i] = prob
}
probs_df <- data.frame(probs/sum(probs), sort(unique(ages)))
colnames(probs_df) <-c('prob', 'age')

# Function for getting parameter of a driver based on name
find_parnames <- function(teammate_names) {
  teammate_ids <- c()
  for (name in teammate_names) {
    teammate_id <- unique(data[data$teammateName == name,]$teammateId)
    teammate_ids <- c(teammate_ids, teammate_id)
  }
  parnames <- lapply(teammate_ids, function(x) paste('a[', as.character(x), ']', sep=''))
  return(parnames)
}

unique_teammates <- data[!duplicated(data[,'teammateName']),]

drivers <- c('stroll', 'lehto', 'maldonado', 'bottas', 'irvine','raikkonen', 'hakkinen', 'max_verstappen', 'hamilton', 'michael_schumacher')
pars <- find_parnames(drivers)

params_a <- as.array(fit_separate_id, pars=pars)
mcmc_areas(params_a) + scale_y_discrete(labels = drivers)
#mcmc_areas(params_a) + scale_y_discrete(labels= c('Lance Stroll', 'JJ Lehto', 'Pastor Maldonado', 'Valtteri Bottas', 'Eddie Irvine', 'Kimi Räikkönen', 'Mika Häkkinen', 'Max Verstappen', 'Lewis Hamilton', 'Michael Schumacher')) + theme_bw(base_size=16)

y_ticks = c()

for (i in 18:43) {
  if (i%%2)
    y_ticks = c(y_ticks, bquote(mu[.(i)]))
  else
    y_ticks = c(y_ticks, '')
}

# parameters in wrong order (for plotting) when extracting with just 'mu' so need to extract everything separately in right order
#mu_numbers <- c(1:26)
#mu_names <- lapply(mu_numbers, function(x) paste('mu[', as.character(x), ']', sep=''))
#mu_pars <- as.array(fit_separate_id, pars=mu_names)
#mcmc_intervals(mu_pars) + scale_y_discrete(labels= y_ticks) + theme_bw(base_size=20)


