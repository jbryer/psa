---
editor_options: 
  chunk_output_type: console
---
# Weighting {#chapter-weighting}

::: {.rmdtip}
**weight**  
*verb*  
1. hold (something) down by placing a heavy object on top of it.  
2. attach importance or value to.
:::

For each of the formulas below, $w$ is the weight, $Z_i$ is the treatment assignment, $Z = 1$ is treatment, $Z = 0$ is control, and $\pi_i$ is the propensity score.

## Estimate Propensity Scores




```r
data("lalonde", package = 'Matching')
lr_out <- glm(formula = lalonde.formu,
			  data = lalonde,
			  family = binomial(link = 'logit'))
lalonde$lr_ps <- fitted(lr_out)
lalonde$lr_weights <- psa::calculate_ps_weights(lalonde$treat,
												ps = lalonde$lr_ps,
												estimand = 'ATE')
```



## Average Treatment Effect (ATE)

\begin{equation}
\begin{aligned}
w_{ATE} = \frac{Z_i}{\pi_i} + \frac{1 - Z_i}{1 - \pi_i}
\end{aligned}
(\#eq:eqatew)
\end{equation}


```r
ate_weights <- psa::calculate_ps_weights(treatment = lalonde$treat,
										 ps = lalonde$lr_ps, 						  
										 estimand = 'ATE')
lm(formula = re78 ~ treat, 
   data = lalonde,
   weights = ate_weights) |> summary()
```

```
## 
## Call:
## lm(formula = re78 ~ treat, data = lalonde, weights = ate_weights)
## 
## Weighted Residuals:
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)     4556        450  10.125   <2e-16 ***
## treat           1558        637   2.446   0.0148 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 9497 on 443 degrees of freedom
## Multiple R-squared:  0.01333,	Adjusted R-squared:  0.0111 
## F-statistic: 5.983 on 1 and 443 DF,  p-value: 0.01483
```

## Average Treatment Effect Among the Treated (ATT)

\begin{equation}
\begin{aligned}
w_{ATT} = \frac{\pi_i Z_i}{\pi_i} + \frac{\pi_i (1 - Z_i)}{1 - \pi_i}
\end{aligned}
(\#eq:eqattw)
\end{equation}


```r
att_weights <- psa::calculate_ps_weights(treatment = lalonde$treat,
										 ps = lalonde$lr_ps, 
										 estimand = 'ATT')
lm(formula = re78 ~ treat, 
   data = lalonde,
   weights = att_weights) |> summary()
```

```
## 
## Call:
## lm(formula = re78 ~ treat, data = lalonde, weights = att_weights)
## 
## Weighted Residuals:
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   4557.4      454.2  10.033  < 2e-16 ***
## treat         1791.7      642.8   2.787  0.00554 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 6186 on 443 degrees of freedom
## Multiple R-squared:  0.01724,	Adjusted R-squared:  0.01502 
## F-statistic:  7.77 on 1 and 443 DF,  p-value: 0.00554
```

## Average Treatment Effect Among the Control (ATC)

\begin{equation}
\begin{aligned}
w_{ATC} = \frac{(1 - \pi_i) Z_i}{\pi_i} + \frac{(1 - e_i)(1 - Z_i)}{1 - \pi_i}
\end{aligned}
(\#eq:eqatcw)
\end{equation}


```r
atc_weights <- psa::calculate_ps_weights(treatment = lalonde$treat,
										 ps = lalonde$lr_ps, 
										 estimand = 'ATC')
lm(formula = re78 ~ treat, 
   data = lalonde,
   weights = atc_weights) |> summary()
```

```
## 
## Call:
## lm(formula = re78 ~ treat, data = lalonde, weights = atc_weights)
## 
## Weighted Residuals:
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   4554.8      446.8  10.195   <2e-16 ***
## treat         1391.0      632.6   2.199   0.0284 *  
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 7204 on 443 degrees of freedom
## Multiple R-squared:  0.0108,	Adjusted R-squared:  0.008564 
## F-statistic: 4.835 on 1 and 443 DF,  p-value: 0.0284
```

#### Average Treatment Effect Among the Evenly Matched (ATM)

\begin{equation}
\begin{aligned}
w_{ATM} = \frac{min{\pi_i, 1 - \pi_i}}{Z_i \pi_i (1 - Z_i)(1 - \pi_i)}
\end{aligned}
(\#eq:eqatmw)
\end{equation}


```r
atm_weights <- psa::calculate_ps_weights(treatment = lalonde$treat,
										 ps = lalonde$lr_ps, 
										 estimand = 'ATM')
lm(formula = re78 ~ treat, 
   data = lalonde,
   weights = atm_weights) |> summary()
```

```
## 
## Call:
## lm(formula = re78 ~ treat, data = lalonde, weights = atm_weights)
## 
## Weighted Residuals:
## 
## Coefficients:
##             Estimate Std. Error t value Pr(>|t|)    
## (Intercept)   4504.6      459.8   9.797  < 2e-16 ***
## treat         1707.7      648.8   2.632  0.00878 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## Residual standard error: 5960 on 443 degrees of freedom
## Multiple R-squared:  0.0154,	Adjusted R-squared:  0.01318 
## F-statistic: 6.928 on 1 and 443 DF,  p-value: 0.008783
```
