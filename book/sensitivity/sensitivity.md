


Sensitivity Analysis
========================================================



```r
> require(rbounds)
> data(lalonde, package = "Matching")
> 
> Y <- lalonde$re78  #the outcome of interest
> Tr <- lalonde$treat  #the treatment of interest
> attach(lalonde)
```

```
The following objects are masked from lalonde (position 3):

    age, black, educ, married, re74, re75, re78, treat
```

```r
> # The covariates we want to match on
> X = cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, re74)
> # The covariates we want to obtain balance on
> BalanceMat <- cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, 
+     re74, I(re74 * re75))
> detach(lalonde)
> 
> gen1 <- GenMatch(Tr = Tr, X = X, BalanceMat = BalanceMat, pop.size = 50, data.type.int = FALSE, 
+     print = 0, replace = FALSE)
> mgen1 <- Match(Y = Y, Tr = Tr, X = X, Weight.matrix = gen1, replace = FALSE)
> summary(mgen1)
```

```

Estimate...  1872 
SE.........  665.99 
T-stat.....  2.8108 
p.val......  0.0049413 

Original number of observations..............  445 
Original number of treated obs...............  185 
Matched number of observations...............  185 
Matched number of observations  (unweighted).  185 
```

```r
> 
> psens(mgen1, Gamma = 1.5, GammaInc = 0.1)
```

```

 Rosenbaum Sensitivity Test for Wilcoxon Signed Rank P-Value 
 
Unconfounded estimate ....  0.0037 

 Gamma Lower bound Upper bound
   1.0      0.0037      0.0037
   1.1      0.0006      0.0158
   1.2      0.0001      0.0478
   1.3      0.0000      0.1102
   1.4      0.0000      0.2063
   1.5      0.0000      0.3293

 Note: Gamma is Odds of Differential Assignment To
 Treatment Due to Unobserved Factors 
 
```

```r
> hlsens(mgen1, Gamma = 1.5, GammaInc = 0.1, 0.1)
```

```

 Rosenbaum Sensitivity Test for Hodges-Lehmann Point Estimate 
 
Unconfounded estimate ....  1725 

 Gamma Lower bound Upper bound
   1.0     1725.30        1725
   1.1     1068.20        1783
   1.2      762.67        2028
   1.3      524.17        2357
   1.4      292.17        2618
   1.5       92.47        2899

 Note: Gamma is Odds of Differential Assignment To
 Treatment Due to Unobserved Factors 
 
```


