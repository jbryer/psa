


Missing Data
========================================================


```r
> require(Matching)
> require(mice)
> data(lalonde, package = "Matching")
```




```r
> Tr <- lalonde$treat
> Y <- lalonde$re78
> X <- lalonde[, c("age", "educ", "black", "hisp", "married", "nodegr", "re74", 
+     "re75")]
> lalonde.glm <- glm(treat ~ ., family = binomial, data = cbind(treat = Tr, X))
> summary(lalonde.glm)
```

```

Call:
glm(formula = treat ~ ., family = binomial, data = cbind(treat = Tr, 
    X))

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


Create a copy of the covariates to simulate missing at random (`mar`) and not missing at random (`nmar`).


```r
> lalonde.mar <- X
> lalonde.nmar <- X
> 
> missing.rate <- 0.2  # What percent of rows will have missing data
> missing.cols <- c("nodegr", "re75")  # The columns we will add missing values to
> 
> # Vectors indiciating which rows are treatment and control.
> treat.rows <- which(lalonde$treat == 1)
> control.rows <- which(lalonde$treat == 0)
```



Add missingness to the existing data. For the not missing at random data treatment units will have twice as many missing values as the control group.


```r
> set.seed(2112)
> for (i in missing.cols) {
+     lalonde.mar[sample(nrow(lalonde), nrow(lalonde) * missing.rate), i] <- NA
+     lalonde.nmar[sample(treat.rows, length(treat.rows) * missing.rate * 2), 
+         i] <- NA
+     lalonde.nmar[sample(control.rows, length(control.rows) * missing.rate), 
+         i] <- NA
+ }
```



The proportion of missing values for the first covariate


```r
> prop.table(table(is.na(lalonde.mar[, missing.cols[1]]), lalonde.mar$treat, useNA = "ifany"))
```

```
Error: all arguments must have the same length
```

```r
> prop.table(table(is.na(lalonde.nmar[, missing.cols[1]]), lalonde.nmar$treat, 
+     useNA = "ifany"))
```

```
Error: all arguments must have the same length
```


Create a shadow matrix. This is a logical vector where each cell is TRUE if the value is missing in the original data frame.


```r
> shadow.matrix.mar <- as.data.frame(is.na(lalonde.mar))
> shadow.matrix.nmar <- as.data.frame(is.na(lalonde.nmar))
```


Change the column names to include "_miss" in their name.


```r
> names(shadow.matrix.mar) <- names(shadow.matrix.nmar) <- paste0(names(shadow.matrix.mar), 
+     "_miss")
```


Impute the missing values using the mice package


```r
> set.seed(2112)
> mice.mar <- mice(lalonde.mar, m = 1)
```

```

 iter imp variable
  1   1  nodegr  re75
  2   1  nodegr  re75
  3   1  nodegr  re75
  4   1  nodegr  re75
  5   1  nodegr  re75
```

```r
> mice.nmar <- mice(lalonde.nmar, m = 1)
```

```

 iter imp variable
  1   1  nodegr  re75
  2   1  nodegr  re75
  3   1  nodegr  re75
  4   1  nodegr  re75
  5   1  nodegr  re75
```


Get the imputed data set.


```r
> complete.mar <- complete(mice.mar)
> complete.nmar <- complete(mice.nmar)
```


Estimate the propensity scores using logistic regression.


```r
> lalonde.mar.glm <- glm(treat ~ ., data = cbind(treat = Tr, complete.mar, shadow.matrix.mar))
> lalonde.nmar.glm <- glm(treat ~ ., data = cbind(treat = Tr, complete.nmar, shadow.matrix.nmar))
```


We see that the two indicator columns from the shadow matrix are statistically significant predictors suggesting that the data is not missing at random.


```r
> summary(lalonde.mar.glm)
```

```

Call:
glm(formula = treat ~ ., data = cbind(treat = Tr, complete.mar, 
    shadow.matrix.mar))

Deviance Residuals: 
   Min      1Q  Median      3Q     Max  
-0.668  -0.404  -0.353   0.564   0.781  

Coefficients: (6 not defined because of singularities)
                  Estimate Std. Error t value Pr(>|t|)  
(Intercept)       6.22e-01   2.52e-01    2.47    0.014 *
age               1.45e-03   3.45e-03    0.42    0.675  
educ             -7.47e-03   1.70e-02   -0.44    0.661  
black            -5.64e-02   8.90e-02   -0.63    0.526  
hisp             -2.00e-01   1.17e-01   -1.71    0.088 .
married           4.26e-02   6.66e-02    0.64    0.523  
nodegr           -1.58e-01   7.52e-02   -2.10    0.037 *
re74             -4.22e-06   5.50e-06   -0.77    0.443  
re75              7.48e-06   9.34e-06    0.80    0.423  
age_missTRUE            NA         NA      NA       NA  
educ_missTRUE           NA         NA      NA       NA  
black_missTRUE          NA         NA      NA       NA  
hisp_missTRUE           NA         NA      NA       NA  
married_missTRUE        NA         NA      NA       NA  
nodegr_missTRUE   6.32e-02   5.85e-02    1.08    0.281  
re74_missTRUE           NA         NA      NA       NA  
re75_missTRUE    -4.28e-03   5.86e-02   -0.07    0.942  
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for gaussian family taken to be 0.2418)

    Null deviance: 108.09  on 444  degrees of freedom
Residual deviance: 104.94  on 434  degrees of freedom
AIC: 644

Number of Fisher Scoring iterations: 2
```

```r
> summary(lalonde.nmar.glm)
```

```

Call:
glm(formula = treat ~ ., data = cbind(treat = Tr, complete.nmar, 
    shadow.matrix.nmar))

Deviance Residuals: 
   Min      1Q  Median      3Q     Max  
-0.909  -0.395  -0.244   0.505   0.850  

Coefficients: (6 not defined because of singularities)
                  Estimate Std. Error t value Pr(>|t|)    
(Intercept)       4.87e-01   2.39e-01    2.04    0.042 *  
age               1.81e-04   3.25e-03    0.06    0.956    
educ             -3.91e-03   1.62e-02   -0.24    0.809    
black            -4.99e-02   8.39e-02   -0.59    0.552    
hisp             -1.97e-01   1.11e-01   -1.78    0.075 .  
married           3.75e-02   6.46e-02    0.58    0.562    
nodegr           -1.54e-01   7.14e-02   -2.16    0.031 *  
re74             -7.12e-06   5.45e-06   -1.31    0.192    
re75              1.54e-05   9.65e-06    1.60    0.110    
age_missTRUE            NA         NA      NA       NA    
educ_missTRUE           NA         NA      NA       NA    
black_missTRUE          NA         NA      NA       NA    
hisp_missTRUE           NA         NA      NA       NA    
married_missTRUE        NA         NA      NA       NA    
nodegr_missTRUE   2.33e-01   4.94e-02    4.71  3.3e-06 ***
re74_missTRUE           NA         NA      NA       NA    
re75_missTRUE     2.31e-01   4.93e-02    4.70  3.6e-06 ***
---
Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1

(Dispersion parameter for gaussian family taken to be 0.2179)

    Null deviance: 108.090  on 444  degrees of freedom
Residual deviance:  94.585  on 434  degrees of freedom
AIC: 597.7

Number of Fisher Scoring iterations: 2
```


