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
       // can return immediately, as soon as find a match
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
  int rep_ages[5];
  int rep_length;
}

parameters {
  real mu[N];
  real<lower=0> sigma[N];

}



model {
  mu ~ normal(0,1);        //prior
  sigma ~ normal(0,1);     //prior
  for(j in 1:total_length){
    time[j] ~ normal(mu[model_index[j]], sigma[model_index[j]]);
    
  }
}



generated quantities{
  real yrep[rep_length];
  int rep_group[rep_length];
  #real log_lik[total_length];
  {
  int  rep_index = 1;
    for(j in 1:total_length){
      if(r_in(age[j], rep_ages)) {
        yrep[rep_index] = normal_rng(mu[model_index[j]], sigma[model_index[j]]);
        rep_group[rep_index] = age[j];
        rep_index += 1;
      }
    }
  }
  
  #for(j in 1:total_length){
  #  log_lik[j] =  normal_lpdf(time[j] | mu[model_index[j]], sigma[model_index[j]]);
  #}
}



