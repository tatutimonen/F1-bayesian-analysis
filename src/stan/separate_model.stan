// The input data N tells how many age pools we have
// The I tells how many samples we have for each of the ages pools.
// The max_i tells the largest value of I vector.
// The vecotr 'ages'  is of length 'N*I containing age differneces for different ages of drives
// Vector y is the scaled time difference.
// 
//
data {
  int<lower=0> N;
  int<lower=0> I[N];
  int<lower=0> max_i;
  vector[N] time[max_i];
  int k[max_i,N];
}


parameters {
  real mu[N];
  real<lower=0> sigma[N];

}

model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  for(j in 1:N){
    for(i in 1:I[j]){
      time[k[i,j]] ~ normal(mu[j], sigma[j]);
    }
  }
}

generated quantities{
  real time_pred[N];
  vector[N] log_lik[max_i];
  for(j in 1:N){
    time_pred[j] = normal_rng(mu[j], sigma[j]);
    for (i in 1:I[j]){
      log_lik[i,j] = normal_lpdf(time[i,j] | mu[j], sigma[j]);
    }
  }

}
