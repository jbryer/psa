# Adapted from McGowan's (2019-01-17) blog post, "Understanding propensity score weighting"
# https://livefreeordichotomize.com/2019/01/17/understanding-propensity-score-weighting/

library(tidyverse)

theme_set(theme_bw())
cols <- c('#fc8d62', '#66c2a5') # http://colorbrewer2.org/#type=qualitative&scheme=Set2&n=3
set.seed(2112)

n <- 1000
treatment.effect <- 2
X <- mvtnorm::rmvnorm(n,
					  mean = c(0.5, 1),
					  sigma = matrix(c(2, 1, 1, 1), ncol = 2) )

dat <- tibble(
	x1 = X[, 1],
	x2 = X[, 2],
	treatment = as.numeric(- 0.5 + 0.25 * x1 + 0.75 * x2 + rnorm(n, 0, 1) > 0),
	outcome = treatment.effect * treatment + rnorm(n, 0, 1)
)
dat

ggplot(dat, aes(x = x1, y = x2, color = factor(treatment))) + 
	geom_point() +
	scale_color_manual('Treatment', values = cols)

# Estimate the propensity scores using logistic regression
lr.out <- glm(treatment ~ x1 + x2, data = dat, family = binomial(link = 'logit'))
summary(lr.out)

# Get the propensity scores
dat$ps <- fitted(lr.out)

ggplot(dat, aes(x = ps, y = outcome, color = factor(treatment))) + 
	geom_point() +
	geom_smooth(method = 'loess') +
	xlab('Propensity Score') +
	scale_color_manual('Treatment', values = cols)

dat2 <- dat %>% tidyr::spread(treatment, ps, sep = '_p')

ggplot(dat) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = ..count..),
				   bins = 50, fill = cols[2]) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -..count..),
				   bins = 50, fill = cols[1]) +
	geom_hline(yintercept = 0, lwd = 0.5) +
	scale_y_continuous(label = abs) 

# Calculate weights
dat <- dat %>% mutate(
	ate_weight = (treatment / ps) + ((1 - treatment) / (1 - ps)),
	att_weight = ((ps * treatment) / ps) + ((ps * (1 - treatment)) / (1 - ps)),
	atc_weight = (((1 - ps) * treatment) / ps) + (((1 - ps) * (1 - treatment)) / (1 - ps)),
	atm_weight = pmin(ps, 1 - ps) / (treatment * ps + (1 - treatment) * (1 - ps))
)
dat

# Average Treatment Effect (ATE)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = ..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = ate_weight, y = ..count..),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = ate_weight, y = -..count..),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect (ATE)')

# Average Treatment Effect Among the Treated (ATT)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = ..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = att_weight, y = ..count..),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = att_weight, y = -..count..),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Treated (ATT)')

# Average Treatment Effect Among the Controls (ACC)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = ..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = atc_weight, y = ..count..),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = atc_weight, y = -..count..),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Control (ATC)')


# Average Treatment Effect Among the Evenly Matched (ACM)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = ..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = atm_weight, y = ..count..),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -..count..),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = atm_weight, y = -..count..),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Evenly Matched (ACM)')

# Estimate the treatment effects
treatment_effect <- function(treatment, outcome, weight) {
	return( 
		(sum(treatment * outcome * weight) / 
		 sum(treatment * weight)) + 
		(sum((1 - treatment) * outcome * weight) / 
		 sum((1 - treatment) * weight))
	)
}

# ATE
treatment_effect(dat$treatment, dat$outcome, dat$ate_weight)
# ATT
treatment_effect(dat$treatment, dat$outcome, dat$att_weight)
# ATC
treatment_effect(dat$treatment, dat$outcome, dat$atc_weight)
# ATM
treatment_effect(dat$treatment, dat$outcome, dat$atm_weight)
