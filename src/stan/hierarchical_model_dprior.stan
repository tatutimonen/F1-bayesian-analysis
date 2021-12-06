// The input data N tells how many age pools we have
// Total length tells how many rows in the input data
// time contains the time differences to teammate
// age contains age of driver at the time of the quali where the difference happened, where each row
// corrseponds to to the row of time
// model index is age transformed to corresponding model index (26 ages = 26 models)
// rep ages contains the ages (models) for which replicated dataset is generated for predictive checking
// rep_length is the length of the replicated dataset
//

functions {
   // if(r_in(3,{1,2,3,4})) will evaluate as 1
  int r_in(int pos,int[] pos_var) {
    for (p in 1:(size(pos_var))) {
       if (pos_var[p]==pos) {
          return 1;
       } 
    }
    return 0;
  }
}

data {
  int<lower=0> N;
  int total_length;
  real time[total_length];
  int age[total_length];
  int model_index[total_length];
  int rep_ages[3];
  int rep_length;
}


parameters {
  real mu[N];
  real<lower=0> sigma[N];
  real<lower=0> tau;
  real mu_mean;
  real sigma_mean;
  real<lower=0> sigma_tau;
}

model {
  mu_mean ~ normal(0,10);    //hyperprior
  tau ~ normal(0,10);       //hyperprior
  mu ~ normal(mu_mean, tau);
  sigma_mean ~ normal(0,10); //hyperprior
  sigma_tau ~ normal(0,10); //hyperprior
  sigma ~ normal(sigma_mean, sigma_tau);
  for(j in 1:total_length){
    time[j] ~ normal(mu[model_index[j]], sigma[model_index[j]]);
  }
}

generated quantities{
  real yrep[rep_length];
  real log_lik[total_length];
  {
  int  rep_index = 1;
    for(j in 1:total_length){
      if(r_in(age[j], rep_ages)) {
        yrep[rep_index] = normal_rng(mu[model_index[j]], sigma[model_index[j]]);
        rep_index += 1;
      }
    }
  }
  for(j in 1:total_length){
    log_lik[j] = normal_lpdf(time[j] | mu[model_index[j]], sigma[model_index[j]]);
  }
}
