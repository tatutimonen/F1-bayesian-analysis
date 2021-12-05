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
  int count27;
}


parameters {
  real mu;
  real<lower=0> sigma;
}

model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  time ~ normal(mu, sigma);
}

generated quantities{
  real time_pred[N];
  real yrep27[count27];
  #real log_lik[total_length];
  for(j in 1:N){
    time_pred[j] = normal_rng(mu, sigma);
  }
  for(j in 1:count27){
    yrep27[j] = normal_rng(mu, sigma);
  }
  #for(j in 1:total_length){
  #  log_lik[j] =  normal_lpdf(time[j] | mu, sigma);
  #}
}
