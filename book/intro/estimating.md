


Estimating Propensity Scores
========================================================

#### Logistic Regression


```r
> lalonde.formu <- treat ~ age + educ + black + hisp + married + nodegr + re74 + 
+     re75
> lalonde.glm <- glm(lalonde.formu, family = binomial, data = lalonde)
> 
> summary(lalonde.glm)
```

```

Call:
glm(formula = lalonde.formu, family = binomial, data = lalonde)

Deviance Residuals: 
   Min      1Q  Median      3Q     Max  
-1.436  -0.990  -0.907   1.282   1.695  

Coefficients:
             Estimate Std. Error z value Pr(>|z|)   
(Intercept)  1.18e+00   1.06e+00    1.12    0.265   
age          4.70e-03   1.43e-02    0.33    0.743   
educ        -7.12e-02   7.17e-02   -0.99    0.321   
black       -2.25e-01   3.66e-01   -0.61    0.539   
hisp        -8.53e-01   5.07e-01   -1.68    0.092 . 
married      1.64e-01   2.77e-01    0.59    0.555   
nodegr      -9.04e-01   3.13e-01   -2.88    0.004 **
re74        -3.16e-05   2.58e-05   -1.22    0.221   
re75         6.16e-05   4.36e-05    1.41    0.157   
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 604.20  on 444  degrees of freedom
Residual deviance: 587.22  on 436  degrees of freedom
AIC: 605.2

Number of Fisher Scoring iterations: 4
```




```r
> ps <- fitted(lalonde.glm)  # Propensity scores
> Y <- lalonde$re78  # Dependent variable, real earnings in 1978
> Tr <- lalonde$treat  # Treatment indicator
```


#### Classification Trees


