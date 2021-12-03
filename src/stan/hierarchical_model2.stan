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
  int model_index[total_length];
  int min_age;
  
}


parameters {
  real mu[N];
  real<lower=0> sigma;
  real<lower=0> tau;
  real mu_mean;
}

model {
  mu_mean ~ normal(0,1);    //prior
  sigma ~ normal(0,1);     //prior
  tau ~ normal(0,1);       //prior
  mu ~ normal(mu_mean, tau);
  for(j in 1:N){
    time[j] ~ normal(mu[model_index[j]], sigma);
    
  }
}

generated quantities{
  real time_pred[N];
  for(j in 1:N){
    time_pred[j] = normal_rng(mu[j], sigma);
  }
}
