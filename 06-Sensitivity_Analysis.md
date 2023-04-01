# Sensitivity Analysis



```r
require(rbounds)
data(lalonde, package='Matching')

Y  <- lalonde$re78   #the outcome of interest
Tr <- lalonde$treat #the treatment of interest
attach(lalonde)
# The covariates we want to match on
X = cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, re74)
# The covariates we want to obtain balance on
BalanceMat <- cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, re74,
					I(re74*re75))
detach(lalonde)

gen1 <- GenMatch(Tr=Tr, X=X, BalanceMat=BalanceMat, pop.size=50,
                  data.type.int=FALSE, print=0, replace=FALSE)
mgen1 <- Match(Y=Y, Tr=Tr, X=X, Weight.matrix=gen1, replace=FALSE)
summary(mgen1)
```

```
## 
## Estimate...  1613.6 
## SE.........  721.22 
## T-stat.....  2.2373 
## p.val......  0.025266 
## 
## Original number of observations..............  445 
## Original number of treated obs...............  185 
## Matched number of observations...............  185 
## Matched number of observations  (unweighted).  185
```

```r
rbounds::psens(x = Y[mgen1$index.treated],
	  y =Y[mgen1$index.contro],
	  Gamma = 1.5, 
	  GammaInc = .1)
```

```
## 
##  Rosenbaum Sensitivity Test for Wilcoxon Signed Rank P-Value 
##  
## Unconfounded estimate ....  0.0228 
## 
##  Gamma Lower bound Upper bound
##    1.0      0.0228      0.0228
##    1.1      0.0056      0.0716
##    1.2      0.0012      0.1640
##    1.3      0.0002      0.2970
##    1.4      0.0000      0.4516
##    1.5      0.0000      0.6030
## 
##  Note: Gamma is Odds of Differential Assignment To
##  Treatment Due to Unobserved Factors 
## 
```



```r
rbounds::hlsens(x = Y[mgen1$index.treated],
	   y = Y[mgen1$index.contro],
	   Gamma = 1.5, 
	   GammaInc = .1)
```

```
## 
##  Rosenbaum Sensitivity Test for Hodges-Lehmann Point Estimate 
##  
## Unconfounded estimate ....  1431.4 
## 
##  Gamma Lower bound Upper bound
##    1.0  1.4314e+03      1431.4
##    1.1  7.9320e+02      1547.1
##    1.2  4.9780e+02      1901.1
##    1.3  2.0850e+02      2162.1
##    1.4 -3.4140e-05      2441.0
##    1.5 -2.1990e+02      2694.4
## 
##  Note: Gamma is Odds of Differential Assignment To
##  Treatment Due to Unobserved Factors 
## 
```
