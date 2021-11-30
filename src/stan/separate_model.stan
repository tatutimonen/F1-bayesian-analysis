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
  vector[max_i] time[N];
}


parameters {
  real<lower=0> mu[N];
  real sigma[N];
}


model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  for(j in 1:N){
    for(i in 1:I[j]){
      time[i,j] ~ normal(mu[j], sigma[j]);
    }
    
  }
}

generated quantities{
  real time_pred[N];
  for(i in 1:N){
      time_pred[i] = normal_rng(mu[i], sigma[i]);
    }
}