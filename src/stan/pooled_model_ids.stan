// The input data N tells how many age pools we have
// The I tells how many samples we have for each of the ages pools.
// The max_i tells the largest value of I vector.
// The vecotr 'ages'  is of length 'N*I containing age differneces for different ages of drives
// Vector y is the scaled time difference.
// 
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
  int driver_id[total_length];
  int driver_count;
}


parameters {
  real mu;
  real<lower=0> sigma;
  real a[driver_count];
}

model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  for(j in 1:total_length){
    time[j] ~ normal(mu + a[driver_id[j]], sigma);
  }
}

generated quantities{
  real time_pred[N];
  real log_lik[total_length];
  real log_lik_id[total_length];
  for(j in 1:N){
    time_pred[j] = normal_rng(mu, sigma);
  }
  for(j in 1:total_length){
    log_lik[j] =  normal_lpdf(time[j] | mu, sigma);
  }
  for (j in 1:total_length){
    log_lik_id[j] = normal_lpdf(time[j] | mu + a[driver_id[j]], sigma);
 }
}
