// The input data N tells how many age pools we have
// The I tells how many samples we have for each of the ages pools.
// The max_i tells the largest value of I vector.
// The vecotr 'ages'  is of length 'N*I containing age differneces for different ages of drives
// Vector y is the scaled time difference.
// 
//
data {
  int<lower=0> N;
  int total_length;
  real time[total_length];
  int age[total_length];
  int min_age;
}


parameters {
  real mu[N];
  real<lower=0> sigma[N];

}

model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  for(j in 1:N){
    int model_index = age[j]-min_age+1;
    time[j] ~ normal(mu[model_index], sigma[model_index]);
    
  }
}

generated quantities{
  real time_pred[N];
  real log_lik[total_length];
  for(j in 1:N){
    time_pred[j] = normal_rng(mu[j], sigma[j]);
  }
  for(j in 1:total_length) {
    int model_index = age[j]-min_age+1;
    log_lik[j] = normal_lpdf(time[j] | mu[model_index], sigma[model_index]);
  }

}
