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
  int driver_id[max_i, N];
  int driver_count;
}


parameters {
  real mu[N];
  real<lower=0> sigma[N];
  real a[driver_count];
}


model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  a ~ normal(0,10);
  for(j in 1:N){
    for(i in 1:I[j]){
      time[i,j] ~ normal(mu[j] + a[driver_id[i,j]], sigma[j]);
    }
  }
}


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
  int driver_id[max_i, N];
  int driver_count;
}


parameters {
  real mu[N];
  real<lower=0> sigma[N];
  real a[driver_count];
}


model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  a ~ normal(0,10);
  for(j in 1:N){
    for(i in 1:I[j]){
      time[i,j] ~ normal(mu[j] + a[driver_id[i,j]], sigma[j]);
    }
  }
}


generated quantities{
  real time_pred[N];
  vector[N] log_lik[max_i];
 // Compute predictive distribution
 for (j in 1:N){
   time_pred[j] = normal_rng(mu[j]+a[driver_id[i,j]], sigma[j]);
   for (i in 1:I[j]){
     log_lik[i,j] = normal_lpdf(time[i,j] | mu[j]+ a[driver_id[i,j]], sigma[j]);
   }
 }
  
}

  
}
