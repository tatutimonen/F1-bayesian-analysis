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
fit2 <- stan(file = "src/stan/pooled_model2.stan", data = stan_data)

copy = data
copy$model_index = copy$age-18+1
df <- data.frame(matrix(unlist(c(copy$difference, copy$model_index)), nrow=nrow(copy), byrow=FALSE))
colnames(df) <- c('difference', 'model_index')

llfun <- function(data_i, draws) {
  model_index = data_i$model_index;
  dnorm(data_i$difference, draws[[1]], draws[[2]], log=TRUE)
}

params <- extract(fit2)
posterior_draws <- list(params$mu[(sample(1:nrow(params$mu), 500))], params$sigma[(sample(1:nrow(params$mu), 500))])

loo_3 <- loo_i(i = 3, llfun = llfun, data = copy, draws = posterior_draws, r_eff = NA)
loo_val <- loo(llfun, data = copy, draws = posterior_draws, r_eff = NA)
