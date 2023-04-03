---
editor_options: 
  chunk_output_type: console
---

# Methods for Estimating Propensity Scores {#appendix-psmodels}

This appendix provide R code for multiple statistical models for estimating propensity scores. The examples use the `lalonde` dataset with the following formula:


```r
lalonde.formu <- treat ~ age + I(age^2) + educ + I(educ^2) + black +
	hisp + married + nodegr + re74  + I(re74^2) + re75 + I(re75^2) +
	u74 + u75
```

## Logistic Regression


```r
lr_out <- glm(lalonde.formu,
			  data = lalonde,
			  family = binomial(link = logit))
lr_ps <- fitted(lr_out)
```


## Conditional Inference Trees with `party` package


```r
library(party)
ctree_out <- ctree(lalonde.formu,
				   data = lalonde)
# treeresponse(ctree_out)
```


## Recusrive Partitioning with `rpart`


```r
library(rpart)
rpart_out <- rpart(lalonde.formu,
				   data = lalonde,
				   method = 'class')
# For classification
rpart_strata <- rpart_out$where
# For matching or weighting
rpart_ps <- predict(rpart_out, type = 'prob')[,1]
```

## Bayesian Logistic Regression


```r
library(rstanarm)
stan_out <- stan_glm(lalonde.formu,
					 data = lalonde)
stan_ps <- predict(stan_out, type = 'response')
```

## Probit BART for dichotomous outcomes with Normal latents


```r
library(BART)
bart_out <- pbart(x.train = lalonde[,all.vars(lalonde.formu)[-1]],
				  y.train = lalonde[,all.vars(lalonde.formu)[1]])
```

```
## *****Into main of pbart
## *****Data:
## data:n,p,np: 445, 10, 0
## y1,yn: 1, 0
## x1,x[n*p]: 37.000000, 0.000000
## *****Number of Trees: 50
## *****Number of Cut Points: 33 ... 1
## *****burn and ndpost: 100, 1000
## *****Prior:mybeta,alpha,tau: 2.000000,0.950000,0.212132
## *****binaryOffset: -0.212829
## *****Dirichlet:sparse,theta,omega,a,b,rho,augment: 0,0,1,0.5,1,10,0
## *****nkeeptrain,nkeeptest,nkeeptreedraws: 1000,1000,1000
## *****printevery: 100
## *****skiptr,skipte,skiptreedraws: 1,1,1
## 
## MCMC
## done 0 (out of 1100)
## done 100 (out of 1100)
## done 200 (out of 1100)
## done 300 (out of 1100)
## done 400 (out of 1100)
## done 500 (out of 1100)
## done 600 (out of 1100)
## done 700 (out of 1100)
## done 800 (out of 1100)
## done 900 (out of 1100)
## done 1000 (out of 1100)
## time: 1s
## check counts
## trcnt,tecnt: 1000,0
```

```r
bart_ps <- bart_out$prob.test.mean
```

## Random Forests



```r
library(randomForest)
rf_out <- randomForest(update.formula(lalonde.formu, factor(treat) ~ .),
					   data = lalonde)
# For classification
rf_strata <- predict(rf_out, type = 'response')
# For matching or weighting
rf_ps <- predict(rf_out, type = 'prob')[,1,drop=TRUE]
```
