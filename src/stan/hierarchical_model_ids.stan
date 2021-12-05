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
  int driver_id[total_length];
  int driver_count;
  int model_index[total_length];
}


parameters {
  real mu[N];
  real<lower=0> sigma;
  real<lower=0> tau;
  real mu_mean;
  real a[driver_count];
}


model {
  mu_mean ~ normal(0,1);    //prior
  sigma ~ normal(0,1);     //prior
  tau ~ normal(0,1);       //prior
  mu ~ normal(mu_mean, tau);     //prior
  a ~ normal(0,0.1);
  for(j in 1:total_length){
    time[j] ~ normal(mu[model_index[j]] + a[driver_id[j]], sigma);
  }
}

generated quantities{
  real time_pred[N];
  #real log_lik[total_length];
  #real log_lik_id[total_length];
 //change name to y rep
 for (j in 1:N){
   time_pred[j] = normal_rng(mu[j], sigma);
 }
 #for (j in 1:total_length){
 # log_lik[j] = normal_lpdf(time[j] | mu[model_index[j]], sigma);
 #}
 #for (j in 1:total_length){
#   log_lik_id[j] = normal_lpdf(time[j] | mu[model_index[j]] + a[driver_id[j]], sigma);
 #}
}
