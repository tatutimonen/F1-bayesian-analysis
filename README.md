
## Effect of age on the performance of an F1 driver: A Bayesian Analysis

  

This is a project analyzing the effect of age on F1 drivers qualifying performance compared to his teammate.

  

----

  

### Data

We consider the difference of a driver's lap time and his teammate's lap time in the last session (Q1/Q2/Q3) they both participated in as a measure of performance. Further, the career average of  a driver's difference to his teammate is substracted from this value to get a "normalized" value that represents how well the driver did compared to his career average. 

The basic idea in the analysis was to divide this data to age groups and fit a separate/hierarchical normal model to each group and then compare the fitted parameters of these groups, mainly the mean parameter, to see how the age groups compare to each other.

  

(boxplot)

  

----

  

### Model

  

We tried a couple different models, but for this analysis we concluded the most useful one to be a separate normal model with an additional parameter accounting for the effect of teammate to be the best, which can be formulated followingly:

<p align="center">
<img src="https://latex.codecogs.com/svg.image?\begin{aligned}t_i&space;&\sim&space;\mathrm{N}(\mu_{\text{age}(i)}&space;&plus;&space;\alpha_{\text{teammate(i)}},&space;\sigma_{\text{age}(i)}),&space;\\\mu_{\text{age}(i)}&space;&\sim&space;\mathrm{N}(0,1),&space;\\\sigma_{\text{age}(i)}&space;&\sim&space;\mathrm{N}(0,1),&space;\\\alpha_{\text{teammate(i)}}&space;&\sim&space;\mathrm{N}(0,&space;0.5),\end{aligned}" title="\begin{aligned}t_i &\sim \mathrm{N}(\mu_{\text{age}(i)} + \alpha_{\text{teammate(i)}}, \sigma_{\text{age}(i)}), \\\mu_{\text{age}(i)} &\sim \mathrm{N}(0,1), \\\sigma_{\text{age}(i)} &\sim \mathrm{N}(0,1), \\\alpha_{\text{teammate(i)}} &\sim \mathrm{N}(0, 0.5),\end{aligned}" />
</p>
where <i>t<sub>i</sub></i> is the time difference on data row <i>i</i>, <i>μ<sub>age(i)</sub></i> and <i>σ<sub>age(i)</sub></i> are the mean and standard deviation parameters of the age group corresponding the driver of that row (age of that driver), and <i>α<sub>teammate(i)</sub></i> is a parameter corresponding to the teammate of the driver of that row. Each driver in the dataset has their own <i>α</i> parameter. The purpose of this parameter is to shift the expected difference to teammate based on how good the teammate is. 

  

----


### Results

  Here is a boxplot showing the probability distribution of the mean parameter for each age:

![alt text](https://github.com/timonent/bda-project/blob/main/plots/age_means.png?raw=true)

Similar trend as in the earlier boxplot of the data can be seen here. Looking at this, the performance seems to get better until the age 27 and get worse after. The posterior probability of the mean parameter of age gropu 27 being the best was around 92%. 

Here is another intresting plot showing the distribution of some selected <i>α</i> parameters:

![alt text](https://github.com/timonent/bda-project/blob/main/plots/teammate_plot.png?raw=true)
  

----

  

### Authors

  

Miro Kaarela ([mkaarela](https://github.com/mkaarela)), Roope Kausiala ([AdmiralBulldog](https://github.com/AdmiralBulldog)), Tatu Timonen ([timonent](https://github.com/timonent))
