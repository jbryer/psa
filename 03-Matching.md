# Matching {#chapter-matching}


```r
lalonde.glm <- glm(lalonde.formu, family=binomial, data=lalonde)
ps <- fitted(lalonde.glm)  # Propensity scores
Y  <- lalonde$re78  # Dependent variable, real earnings in 1978
Tr <- lalonde$treat # Treatment indicator
```




```r
## Matching
# one-to-one matching with replacement (the "M=1" option).
# Estimating the treatment effect on the treated (default is ATT).
rr.att <- Match(Y = Y, 
				Tr = Tr, 
				X = ps,
				M = 1,
				estimand='ATT')
summary(rr.att) # The default estimate is ATT here
```

```
## 
## Estimate...  2153.3 
## AI SE......  825.4 
## T-stat.....  2.6088 
## p.val......  0.0090858 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  185 
## Matched number of observations  (unweighted).  346
```

```r
ls(rr.att)
```

```
##  [1] "caliper"           "ecaliper"          "est"              
##  [4] "est.noadj"         "estimand"          "exact"            
##  [7] "index.control"     "index.dropped"     "index.treated"    
## [10] "MatchLoopC"        "mdata"             "ndrops"           
## [13] "ndrops.matches"    "nobs"              "orig.nobs"        
## [16] "orig.treated.nobs" "orig.wnobs"        "se"               
## [19] "se.cond"           "se.standard"       "version"          
## [22] "weights"           "wnobs"
```

```r
rr.ate <- Match(Y=Y, Tr=Tr, X=ps, M=1, estimand='ATE')
summary(rr.ate)
```

```
## 
## Estimate...  2013.3 
## AI SE......  817.76 
## T-stat.....  2.4619 
## p.val......  0.013819 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  445 
## Matched number of observations  (unweighted).  756
```

```r
ls(rr.ate)
```

```
##  [1] "caliper"           "ecaliper"          "est"              
##  [4] "est.noadj"         "estimand"          "exact"            
##  [7] "index.control"     "index.dropped"     "index.treated"    
## [10] "MatchLoopC"        "mdata"             "ndrops"           
## [13] "ndrops.matches"    "nobs"              "orig.nobs"        
## [16] "orig.treated.nobs" "orig.wnobs"        "se"               
## [19] "se.cond"           "se.standard"       "version"          
## [22] "weights"           "wnobs"
```




```r
rr2 <- Match(Y = Y,
			 Tr = Tr,
			 X = ps,
			 M = 1, 
			 ties = TRUE, 
			 replace = TRUE,
			 estimand = 'ATT')
summary(rr2) # The default estimate is ATT here
```

```
## 
## Estimate...  2153.3 
## AI SE......  825.4 
## T-stat.....  2.6088 
## p.val......  0.0090858 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  185 
## Matched number of observations  (unweighted).  346
```

```r
length(unique(rr2$index.control))
```

```
## 173.00
```

```r
ls(rr2)
```

```
##  [1] "caliper"           "ecaliper"          "est"              
##  [4] "est.noadj"         "estimand"          "exact"            
##  [7] "index.control"     "index.dropped"     "index.treated"    
## [10] "MatchLoopC"        "mdata"             "ndrops"           
## [13] "ndrops.matches"    "nobs"              "orig.nobs"        
## [16] "orig.treated.nobs" "orig.wnobs"        "se"               
## [19] "se.cond"           "se.standard"       "version"          
## [22] "weights"           "wnobs"
```




```r
## Using the Matchit package
matchit.out <- matchit(lalonde.formu, data=lalonde)
summary(matchit.out)
```

```
## 
## Call:
## matchit(formula = lalonde.formu, data = lalonde)
## 
## Summary of Balance for All Data:
##           Means Treated Means Control Std. Mean Diff. Var. Ratio eCDF Mean
## distance         0.4468        0.3936          0.4533     1.2101    0.1340
## age             25.8162       25.0538          0.1066     1.0278    0.0254
## I(age^2)       717.3946      677.3154          0.0929     1.0115    0.0254
## educ            10.3459       10.0885          0.1281     1.5513    0.0287
## I(educ^2)      111.0595      104.3731          0.1701     1.6625    0.0287
## black            0.8432        0.8269          0.0449          .    0.0163
## hisp             0.0595        0.1077         -0.2040          .    0.0482
## married          0.1892        0.1538          0.0902          .    0.0353
## nodegr           0.7081        0.8346         -0.2783          .    0.1265
## re74          2095.5740     2107.0268         -0.0023     0.7381    0.0192
## I(re74^2) 28141433.9907 36667413.1577         -0.0747     0.5038    0.0192
## re75          1532.0556     1266.9092          0.0824     1.0763    0.0508
## I(re75^2) 12654752.6909 11196530.0057          0.0260     1.4609    0.0508
## u74              0.7081        0.7500         -0.0921          .    0.0419
## u75              0.6000        0.6846         -0.1727          .    0.0846
##           eCDF Max
## distance    0.2244
## age         0.0652
## I(age^2)    0.0652
## educ        0.1265
## I(educ^2)   0.1265
## black       0.0163
## hisp        0.0482
## married     0.0353
## nodegr      0.1265
## re74        0.0471
## I(re74^2)   0.0471
## re75        0.1075
## I(re75^2)   0.1075
## u74         0.0419
## u75         0.0846
## 
## Summary of Balance for Matched Data:
##           Means Treated Means Control Std. Mean Diff. Var. Ratio eCDF Mean
## distance         0.4468        0.4277          0.1627     1.2887    0.0400
## age             25.8162       25.7514          0.0091     1.0691    0.0151
## I(age^2)       717.3946      710.7568          0.0154     0.9977    0.0151
## educ            10.3459       10.2054          0.0699     1.2231    0.0162
## I(educ^2)      111.0595      107.4378          0.0921     1.3309    0.0162
## black            0.8432        0.8324          0.0297          .    0.0108
## hisp             0.0595        0.0811         -0.0914          .    0.0216
## married          0.1892        0.1946         -0.0138          .    0.0054
## nodegr           0.7081        0.7676         -0.1308          .    0.0595
## re74          2095.5740     2168.6782         -0.0150     1.0398    0.0125
## I(re74^2) 28141433.9907 27544255.1664          0.0052     1.4319    0.0125
## re75          1532.0556     1482.8937          0.0153     1.1270    0.0181
## I(re75^2) 12654752.6909 11344693.3166          0.0234     2.2884    0.0181
## u74              0.7081        0.7027          0.0119          .    0.0054
## u75              0.6000        0.5946          0.0110          .    0.0054
##           eCDF Max Std. Pair Dist.
## distance    0.1189          0.1627
## age         0.0378          0.9912
## I(age^2)    0.0378          0.9340
## educ        0.0595          0.8442
## I(educ^2)   0.0595          0.8353
## black       0.0108          0.6244
## hisp        0.0216          0.2743
## married     0.0054          0.6211
## nodegr      0.0595          0.5588
## re74        0.0324          0.6787
## I(re74^2)   0.0324          0.4400
## re75        0.0486          0.7713
## I(re75^2)   0.0486          0.4068
## u74         0.0054          0.8204
## u75         0.0054          0.7613
## 
## Sample Sizes:
##           Control Treated
## All           260     185
## Matched       185     185
## Unmatched      75       0
## Discarded       0       0
```

```r
# Same as above but calculate average treatment effect
rr.ate <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE, replace=FALSE, estimand='ATE')
summary(rr.ate) # Here the estimate is ATE
```

```
## 
## Estimate...  2130.3 
## SE.........  496.24 
## T-stat.....  4.2929 
## p.val......  1.7638e-05 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  370 
## Matched number of observations  (unweighted).  370
```

```r
## Genetic Matching
rr.gen <- GenMatch(Tr=Tr, X=ps, 
				   BalanceMatrix=lalonde[,all.vars(lalonde.formu)[-1]],
				   estimand='ATE', M=1, pop.size=16)
```

```
## 
## 
## Tue Apr  4 14:25:39 2023
## Domains:
##  0.000000e+00   <=  X1   <=    1.000000e+03 
## 
## Data Type: Floating Point
## Operators (code number, name, population) 
## 	(1) Cloning........................... 	1
## 	(2) Uniform Mutation.................. 	2
## 	(3) Boundary Mutation................. 	2
## 	(4) Non-Uniform Mutation.............. 	2
## 	(5) Polytope Crossover................ 	2
## 	(6) Simple Crossover.................. 	2
## 	(7) Whole Non-Uniform Mutation........ 	2
## 	(8) Heuristic Crossover............... 	2
## 	(9) Local-Minimum Crossover........... 	0
## 
## SOFT Maximum Number of Generations: 100
## Maximum Nonchanging Generations: 4
## Population size       : 16
## Convergence Tolerance: 1.000000e-03
## 
## Not Using the BFGS Derivative Based Optimizer on the Best Individual Each Generation.
## Not Checking Gradients before Stopping.
## Using Out of Bounds Individuals.
## 
## Maximization Problem.
## GENERATION: 0 (initializing the population)
## Lexical Fit..... 8.444065e-02  1.707692e-01  2.857138e-01  2.857138e-01  3.843318e-01  3.843318e-01  4.092561e-01  7.181139e-01  7.181139e-01  7.681208e-01  8.041696e-01  8.137610e-01  8.137610e-01  9.055825e-01  9.055825e-01  9.657997e-01  9.663530e-01  9.812627e-01  1.000000e+00  1.000000e+00  
## #unique......... 16, #Total UniqueCount: 16
## var 1:
## best............ 1.907452e+02
## mean............ 5.339215e+02
## variance........ 8.319784e+04
## 
## GENERATION: 1
## Lexical Fit..... 8.575134e-02  1.531161e-01  2.857138e-01  2.857138e-01  3.677009e-01  3.677009e-01  4.416445e-01  7.181139e-01  7.181139e-01  7.681208e-01  8.082869e-01  8.137610e-01  8.137610e-01  9.055825e-01  9.055825e-01  9.627480e-01  9.820684e-01  9.820684e-01  1.000000e+00  1.000000e+00  
## #unique......... 9, #Total UniqueCount: 25
## var 1:
## best............ 8.641506e+01
## mean............ 4.514891e+02
## variance........ 1.023311e+05
## 
## GENERATION: 2
## Lexical Fit..... 9.235231e-02  1.757822e-01  2.857138e-01  2.857138e-01  3.950411e-01  3.950411e-01  4.483849e-01  7.409596e-01  7.643859e-01  7.643859e-01  7.647535e-01  7.691713e-01  7.691713e-01  8.592751e-01  8.592751e-01  9.160976e-01  9.160976e-01  9.681165e-01  9.786492e-01  9.823810e-01  
## #unique......... 9, #Total UniqueCount: 34
## var 1:
## best............ 4.542846e+01
## mean............ 1.514238e+02
## variance........ 1.704280e+04
## 
## GENERATION: 3
## Lexical Fit..... 9.235231e-02  1.757822e-01  2.857138e-01  2.857138e-01  3.950411e-01  3.950411e-01  4.483849e-01  7.409596e-01  7.643859e-01  7.643859e-01  7.647535e-01  7.691713e-01  7.691713e-01  8.592751e-01  8.592751e-01  9.160976e-01  9.160976e-01  9.681165e-01  9.786492e-01  9.823810e-01  
## #unique......... 8, #Total UniqueCount: 42
## var 1:
## best............ 4.542846e+01
## mean............ 1.162030e+02
## variance........ 4.102611e+04
## 
## GENERATION: 4
## Lexical Fit..... 9.235231e-02  1.757822e-01  2.857138e-01  2.857138e-01  3.950411e-01  3.950411e-01  4.483849e-01  7.409596e-01  7.643859e-01  7.643859e-01  7.647535e-01  7.691713e-01  7.691713e-01  8.592751e-01  8.592751e-01  9.160976e-01  9.160976e-01  9.681165e-01  9.786492e-01  9.823810e-01  
## #unique......... 8, #Total UniqueCount: 50
## var 1:
## best............ 4.542846e+01
## mean............ 1.653093e+02
## variance........ 5.055175e+04
## 
## GENERATION: 5
## Lexical Fit..... 1.018834e-01  2.553994e-01  2.553994e-01  2.783402e-01  4.170791e-01  4.170791e-01  4.644513e-01  4.865353e-01  6.420853e-01  6.420853e-01  6.665787e-01  7.887453e-01  8.111685e-01  8.111685e-01  8.592751e-01  8.592751e-01  9.160976e-01  9.160976e-01  9.183486e-01  9.743110e-01  
## #unique......... 9, #Total UniqueCount: 59
## var 1:
## best............ 6.185244e+00
## mean............ 8.255247e+01
## variance........ 1.603073e+04
## 
## GENERATION: 6
## Lexical Fit..... 1.067431e-01  2.553994e-01  2.553994e-01  3.549996e-01  3.913630e-01  3.913630e-01  4.747623e-01  5.084810e-01  6.420853e-01  6.420853e-01  6.665787e-01  7.967582e-01  8.111685e-01  8.111685e-01  8.592751e-01  8.592751e-01  9.160976e-01  9.160976e-01  9.264048e-01  9.941933e-01  
## #unique......... 9, #Total UniqueCount: 68
## var 1:
## best............ 4.049911e+00
## mean............ 1.611220e+02
## variance........ 8.678102e+04
## 
## GENERATION: 7
## Lexical Fit..... 1.134648e-01  2.173453e-01  2.857138e-01  2.857138e-01  3.432276e-01  3.432276e-01  4.939824e-01  5.024479e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.112194e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.794830e-01  9.805886e-01  
## #unique......... 10, #Total UniqueCount: 78
## var 1:
## best............ 2.813949e+00
## mean............ 1.343474e+02
## variance........ 5.834938e+04
## 
## GENERATION: 8
## Lexical Fit..... 1.134648e-01  2.173453e-01  2.857138e-01  2.857138e-01  3.432276e-01  3.432276e-01  4.939824e-01  5.024479e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.112194e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.794830e-01  9.805886e-01  
## #unique......... 9, #Total UniqueCount: 87
## var 1:
## best............ 2.813949e+00
## mean............ 6.813214e+01
## variance........ 3.306337e+04
## 
## GENERATION: 9
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 8, #Total UniqueCount: 95
## var 1:
## best............ 2.952273e+00
## mean............ 5.478136e+01
## variance........ 9.538908e+03
## 
## GENERATION: 10
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 8, #Total UniqueCount: 103
## var 1:
## best............ 2.952273e+00
## mean............ 8.777160e+01
## variance........ 2.274155e+04
## 
## GENERATION: 11
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 9, #Total UniqueCount: 112
## var 1:
## best............ 2.952273e+00
## mean............ 3.691080e+01
## variance........ 5.119532e+03
## 
## GENERATION: 12
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 6, #Total UniqueCount: 118
## var 1:
## best............ 2.952273e+00
## mean............ 2.748877e+01
## variance........ 2.783548e+03
## 
## GENERATION: 13
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 7, #Total UniqueCount: 125
## var 1:
## best............ 2.952273e+00
## mean............ 1.177114e+02
## variance........ 5.677878e+04
## 
## GENERATION: 14
## Lexical Fit..... 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## #unique......... 9, #Total UniqueCount: 134
## var 1:
## best............ 2.952273e+00
## mean............ 7.010256e+01
## variance........ 2.756398e+04
## 
## 'wait.generations' limit reached.
## No significant improvement in 4 generations.
## 
## Solution Lexical Fitness Value:
## 1.137080e-01  2.166077e-01  2.857138e-01  2.857138e-01  3.498724e-01  3.498724e-01  4.929831e-01  5.053473e-01  6.832321e-01  6.832321e-01  7.316137e-01  7.643859e-01  7.643859e-01  8.104826e-01  9.055825e-01  9.055825e-01  9.160976e-01  9.160976e-01  9.792910e-01  9.793230e-01  
## 
## Parameters at the Solution:
## 
##  X[ 1] :	2.952273e+00
## 
## Solution Found Generation 9
## Number of Generations Run 14
## 
## Tue Apr  4 14:25:41 2023
## Total run time : 0 hours 0 minutes and 2 seconds
```

```r
rr.gen.mout <- Match(Y=Y, Tr=Tr, X=ps, estimand='ATE', Weight.matrix=rr.gen)
summary(rr.gen.mout)
```

```
## 
## Estimate...  2159 
## AI SE......  814.91 
## T-stat.....  2.6494 
## p.val......  0.0080631 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  445 
## Matched number of observations  (unweighted).  650
```

```r
## Partial exact matching
rr2 <- Matchby(Y=Y, Tr=Tr, X=ps, by=factor(lalonde$nodegr))
```

```
## 1 of 2 groups
## 2 of 2 groups
```

```r
summary(rr2)
```

```
## 
## Estimate...  2333.2 
## SE.........  682.81 
## T-stat.....  3.417 
## p.val......  0.00063307 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  185 
## Matched number of observations  (unweighted).  185
```

```r
## Partial exact matching on two covariates
rr3 <- Matchby(Y=Y, Tr=Tr, X=ps, by=lalonde[,c('nodegr','married')])
```

```
## 1 of 4 groups
## 2 of 4 groups
## 3 of 4 groups
## 4 of 4 groups
```

```r
summary(rr3)
```

```
## 
## Estimate...  1961.7 
## SE.........  701.93 
## T-stat.....  2.7947 
## p.val......  0.0051952 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  185 
## Matched number of observations  (unweighted).  185
```


