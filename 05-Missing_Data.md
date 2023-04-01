# Missing Data



```r
require(Matching)
require(mice)
data(lalonde, package='Matching')
```



```r
Tr <- lalonde$treat
Y <- lalonde$re78
X <- lalonde[,c('age','educ','black','hisp','married','nodegr','re74','re75')]
lalonde.glm <- glm(treat ~ ., family=binomial, data=cbind(treat=Tr, X))
summary(lalonde.glm)
```

```
## 
## Call:
## glm(formula = treat ~ ., family = binomial, data = cbind(treat = Tr, 
##     X))
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.4358  -0.9904  -0.9071   1.2825   1.6946  
## 
## Coefficients:
##               Estimate Std. Error z value Pr(>|z|)   
## (Intercept)  1.178e+00  1.056e+00   1.115  0.26474   
## age          4.698e-03  1.433e-02   0.328  0.74297   
## educ        -7.124e-02  7.173e-02  -0.993  0.32061   
## black       -2.247e-01  3.655e-01  -0.615  0.53874   
## hisp        -8.528e-01  5.066e-01  -1.683  0.09228 . 
## married      1.636e-01  2.769e-01   0.591  0.55463   
## nodegr      -9.035e-01  3.135e-01  -2.882  0.00395 **
## re74        -3.161e-05  2.584e-05  -1.223  0.22122   
## re75         6.161e-05  4.358e-05   1.414  0.15744   
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 604.20  on 444  degrees of freedom
## Residual deviance: 587.22  on 436  degrees of freedom
## AIC: 605.22
## 
## Number of Fisher Scoring iterations: 4
```

Create a copy of the covariates to simulate missing at random (`mar`) and not missing at random (`nmar`).


```r
lalonde.mar <- X
lalonde.nmar <- X

missing.rate <- .2 # What percent of rows will have missing data
missing.cols <- c('nodegr', 're75') # The columns we will add missing values to

# Vectors indiciating which rows are treatment and control.
treat.rows <- which(lalonde$treat == 1)
control.rows <- which(lalonde$treat == 0)
```


Add missingness to the existing data. For the not missing at random data treatment units will have twice as many missing values as the control group.


```r
set.seed(2112)
for(i in missing.cols) {
	lalonde.mar[sample(nrow(lalonde), nrow(lalonde) * missing.rate), i] <- NA
	lalonde.nmar[sample(treat.rows, length(treat.rows) * missing.rate * 2), i] <- NA
	lalonde.nmar[sample(control.rows, length(control.rows) * missing.rate), i] <- NA
}
```


The proportion of missing values for the first covariate


```r
prop.table(table(is.na(lalonde.mar[,missing.cols[1]]), lalonde$treat, useNA='ifany'))
```

```
##        
##                  0          1
##   FALSE 0.46292135 0.33707865
##   TRUE  0.12134831 0.07865169
```

```r
prop.table(table(is.na(lalonde.nmar[,missing.cols[1]]), lalonde$treat, useNA='ifany'))
```

```
##        
##                 0         1
##   FALSE 0.4674157 0.2494382
##   TRUE  0.1168539 0.1662921
```

Create a shadow matrix. This is a logical vector where each cell is TRUE if the value is missing in the original data frame.


```r
shadow.matrix.mar <- as.data.frame(is.na(lalonde.mar))
shadow.matrix.nmar <- as.data.frame(is.na(lalonde.nmar))
```

Change the column names to include "_miss" in their name.


```r
names(shadow.matrix.mar) <- names(shadow.matrix.nmar) <- paste0(names(shadow.matrix.mar), '_miss')
```

Impute the missing values using the mice package


```r
set.seed(2112)
mice.mar <- mice(lalonde.mar, m=1)
```

```
## 
##  iter imp variable
##   1   1  nodegr  re75
##   2   1  nodegr  re75
##   3   1  nodegr  re75
##   4   1  nodegr  re75
##   5   1  nodegr  re75
```

```r
mice.nmar <- mice(lalonde.nmar, m=1)
```

```
## 
##  iter imp variable
##   1   1  nodegr  re75
##   2   1  nodegr  re75
##   3   1  nodegr  re75
##   4   1  nodegr  re75
##   5   1  nodegr  re75
```

Get the imputed data set.


```r
complete.mar <- complete(mice.mar)
complete.nmar <- complete(mice.nmar)
```

Estimate the propensity scores using logistic regression.


```r
lalonde.mar.glm <- glm(treat~., data=cbind(treat=Tr, complete.mar, shadow.matrix.mar))
lalonde.nmar.glm <- glm(treat~., data=cbind(treat=Tr, complete.nmar, shadow.matrix.nmar))
```

We see that the two indicator columns from the shadow matrix are statistically significant predictors suggesting that the data is not missing at random.


```r
summary(lalonde.mar.glm)
```

```
## 
## Call:
## glm(formula = treat ~ ., data = cbind(treat = Tr, complete.mar, 
##     shadow.matrix.mar))
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -0.7073  -0.3837  -0.3079   0.5404   0.7881  
## 
## Coefficients: (6 not defined because of singularities)
##                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)       8.996e-01  2.504e-01   3.592 0.000366 ***
## age               9.447e-04  3.395e-03   0.278 0.780957    
## educ             -2.514e-02  1.706e-02  -1.474 0.141191    
## black            -3.895e-02  8.746e-02  -0.445 0.656285    
## hisp             -1.726e-01  1.156e-01  -1.493 0.136068    
## married           3.008e-02  6.671e-02   0.451 0.652326    
## nodegr           -2.672e-01  7.475e-02  -3.574 0.000390 ***
## re74             -1.059e-05  5.681e-06  -1.863 0.063076 .  
## re75              2.378e-05  1.059e-05   2.246 0.025227 *  
## age_missTRUE             NA         NA      NA       NA    
## educ_missTRUE            NA         NA      NA       NA    
## black_missTRUE           NA         NA      NA       NA    
## hisp_missTRUE            NA         NA      NA       NA    
## married_missTRUE         NA         NA      NA       NA    
## nodegr_missTRUE  -1.852e-02  5.853e-02  -0.316 0.751797    
## re74_missTRUE            NA         NA      NA       NA    
## re75_missTRUE    -3.304e-02  5.870e-02  -0.563 0.573823    
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 0.2361624)
## 
##     Null deviance: 108.09  on 444  degrees of freedom
## Residual deviance: 102.49  on 434  degrees of freedom
## AIC: 633.48
## 
## Number of Fisher Scoring iterations: 2
```

```r
summary(lalonde.nmar.glm)
```

```
## 
## Call:
## glm(formula = treat ~ ., data = cbind(treat = Tr, complete.nmar, 
##     shadow.matrix.nmar))
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -0.7597  -0.3960  -0.2154   0.4926   0.8693  
## 
## Coefficients: (6 not defined because of singularities)
##                    Estimate Std. Error t value Pr(>|t|)    
## (Intercept)       7.427e-01  2.319e-01   3.203 0.001459 ** 
## age               7.641e-04  3.254e-03   0.235 0.814441    
## educ             -2.451e-02  1.584e-02  -1.547 0.122656    
## black            -1.964e-02  8.493e-02  -0.231 0.817243    
## hisp             -1.366e-01  1.113e-01  -1.228 0.220246    
## married           4.426e-02  6.440e-02   0.687 0.492303    
## nodegr           -2.572e-01  7.143e-02  -3.601 0.000354 ***
## re74             -3.326e-06  5.324e-06  -0.625 0.532421    
## re75              4.742e-06  9.893e-06   0.479 0.631935    
## age_missTRUE             NA         NA      NA       NA    
## educ_missTRUE            NA         NA      NA       NA    
## black_missTRUE           NA         NA      NA       NA    
## hisp_missTRUE            NA         NA      NA       NA    
## married_missTRUE         NA         NA      NA       NA    
## nodegr_missTRUE   2.300e-01  4.957e-02   4.639 4.64e-06 ***
## re74_missTRUE            NA         NA      NA       NA    
## re75_missTRUE     2.246e-01  4.922e-02   4.563 6.57e-06 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for gaussian family taken to be 0.2164914)
## 
##     Null deviance: 108.090  on 444  degrees of freedom
## Residual deviance:  93.957  on 434  degrees of freedom
## AIC: 594.78
## 
## Number of Fisher Scoring iterations: 2
```

