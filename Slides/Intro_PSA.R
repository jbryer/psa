################################################################################
##### Setup
# Installing the `psa` package with  dependencies = 'Enhances' should install 
# all the dependencies for the workshop. Uncomment to run the command once per
# R installation.

# remotes::install_github('jbryer/psa', build_vignettes = TRUE, dependencies = 'Enhances')

################################################################################
##### Load packages
library(multilevelPSA)
library(Matching)
library(MatchIt)
library(multilevelPSA)
library(party)
library(PSAgraphics)
library(granovaGG)
library(rbounds)
library(rpart)
library(TriMatch)
library(psa)
library(gridExtra)
library(psych)
library(tidyverse)
library(plyr)
library(knitr)
library(rmarkdown)

################################################################################
##### Set some options
cols <- palette2 <- c('#fc8d62', '#66c2a5')
theme_set(theme_bw())

################################################################################
##### Data
data(pisana)
data(tutoring)
data(psa_citations)
data(lalonde, package='Matching')

################################################################################
set.seed(2112)
pop.mean <- 100
pop.sd <- 15
pop.es <- .3
n <- 30
thedata <- data.frame(
	id = 1:30,
	center = rnorm(n, mean = pop.mean, sd = pop.sd),
	stringsAsFactors = FALSE
)
val <- pop.sd * pop.es / 2
thedata$placebo <- thedata$center - val
thedata$treatment <- thedata$center + val
thedata$diff <- thedata$treatment - thedata$placebo
thedata$RCT_Assignment <- sample(c('placebo', 'treatment'), n, replace = TRUE)
thedata$RCT_Value <- as.numeric(apply(thedata, 1, 
					FUN = function(x) { return(x[x['RCT_Assignment']]) }))
head(thedata, n = 3)
tab.out <- describeBy(thedata$RCT_Value, group = thedata$RCT_Assignment, mat = TRUE, skew = FALSE)

p1 <- ggplot(thedata) + 
	geom_segment(aes(x = placebo, xend = treatment, y = id, yend = id)) +
	geom_point(aes(x = placebo, y = id), color = 'blue') +
	geom_point(aes(x = treatment, y = id), color = 'red') +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 3 * pop.sd, pop.mean + 3 * pop.sd) +
	ggtitle(paste0('True Counterfactual Difference = ', mean(thedata$diff)))
p1b <- p1 +
	geom_vline(xintercept = mean(thedata$treatment), color = 'red') +
	geom_vline(xintercept = mean(thedata$placebo), color = 'blue')
p2 <- ggplot(thedata, aes(x = RCT_Value, color = RCT_Assignment, y = id)) +
	geom_point() +
	scale_color_manual(values = c('placebo' = 'blue', 'treatment' = 'red')) +
	theme(legend.position = 'none') +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 3 * pop.sd, pop.mean + 3 * pop.sd) +
	ggtitle('Observed values in an RCT')
p2b <- p2 + 
	geom_vline(data = tab.out, aes(xintercept = mean, color = group1)) +
	ggtitle(paste0('RCT Difference = ', round(diff(tab.out$mean), digits = 2)))

# Actual treatment effect
cowplot::plot_grid(p1, p1b)
# Estimated treatment effect from one RCT
cowplot::plot_grid(p2, p2b)

# Simulate 1,000 RCTs and display the histogram
sim.diff <- numeric(1000)
for(i in seq_along(sim.diff)) {
	treats <- sample(c(T,F), n, replace = TRUE)
	sim.diff[i] <- mean(thedata[treats,]$treatment) - mean(thedata[!treats,]$placebo)
}
ggplot(data.frame(x = sim.diff), aes(x = x)) + 
	geom_histogram(alpha = 0.5, bins = 20) +
	geom_vline(xintercept = mean(thedata$diff), color = 'red') +
	geom_vline(xintercept = mean(sim.diff)) +
	xlab('RCT Different') + ylab('Count')


################################################################################
# Simulate a dataset to visualize the various ways to estimate treatment effects
n <- 500
treatment_effect <- 1.5
X <- mvtnorm::rmvnorm(
	n,
	mean = c(0.5, 1, 0),
	sigma = matrix(c(2, 1, 1,
					 1, 1, 1,
					 1, 1, 1), 
					 ncol = 3) )
dat <- tibble(
	x1 = X[, 1],
	x2 = X[, 2],
	x3 = X[, 3] > 0,
	treatment = as.numeric(- 0.5 +
						   	0.25 * x1 + 
						   	0.75 * x2 + 
						   	0.05 * x3 + 
						   	rnorm(n, 0, 1) > 0),
	outcome = treatment_effect * treatment + 
		rnorm(n, 0, 1)
)

head(dat, n = 6)

# Scatter plot
ggplot(dat, aes(x = x1, y = x2, shape = x3, color = factor(treatment))) + 
	geom_point() + scale_color_manual('Treatment', values = cols)

# Estimate the propensity scores using logistic regression
lr.out <- glm(treatment ~ x1 + x2 + x3, data = dat, family = binomial(link='logit'))

# Get the propensity scores
dat$ps <- fitted(lr.out) 

# Stratification
breaks5 <- psa::get_strata_breaks(dat$ps)
dat$strata5 <- cut(x = dat$ps, 
				   breaks = breaks5$breaks, 
				   include.lowest = TRUE, 
				   labels = breaks5$labels$strata)

# Distribution of propensity scores with stratifications
ggplot(dat, aes(x = ps, color = as.logical(treatment))) + 
	geom_density(aes(fill = as.logical(treatment)), alpha = 0.2) +
	geom_vline(xintercept = breaks5$breaks, alpha = 0.5) +
	geom_text(data = breaks5$labels, 
			  aes(x = xmid, y = 0, label = strata),
			  color = 'black', vjust = 0.8, size = 8) +
	scale_fill_manual('Treatment', values = palette2) +
	scale_color_manual('Treatment', values = palette2) +
	xlab('Propensity Score') + ylab('Density') +
	xlim(c(0, 1)) +
	ggtitle('Density distribution of propensity scores by treatment',
			subtitle = 'Five strata represented by vertical lines')

# Visualize the mean within each strata
psa::stratification_plot(ps = dat$ps,
						 treatment = dat$treatment,
						 outcome = dat$outcome)

# Find matchings using basic options. Will discuss more later.
match_out <- Matching::Match(Y = dat$outcome,
							 Tr = dat$treatment,
							 X = dat$ps,
							 caliper = 0.1,
							 estimand = 'ATE')
dat_match <- data.frame(treat_ps = dat[match_out$index.treated,]$ps,
						treat_outcome = dat[match_out$index.treated,]$outcome,
						control_ps = dat[match_out$index.control,]$ps,
						control_outcome = dat[match_out$index.control,]$outcome)
# Display propensity scores on the x-axis and outcome on the y-axis with matched
# pairs connected.
psa::matching_plot(ps = dat$ps,
				   treatment = dat$treatment,
				   outcome = dat$outcome,
				   index_treated = match_out$index.treated,
				   index_control = match_out$index.control)

# Estimate propnesity score weights
dat <- dat |> mutate(
	ate_weight = psa::calculate_ps_weights(treatment, ps, estimand = 'ATE'),
	att_weight = psa::calculate_ps_weights(treatment, ps, estimand = 'ATT'),
	atc_weight = psa::calculate_ps_weights(treatment, ps, estimand = 'ATC'),
	atm_weight = psa::calculate_ps_weights(treatment, ps, estimand = 'ATM')
)

psa::weighting_plot(ps = dat$ps,
					treatment = dat$treatment,
					outcome = dat$outcome)
# 
ggplot(dat) +
	geom_histogram(data = dat[dat$treatment == 1,], aes(x = ps, y = after_stat(count)), bins = 50, fill = cols[2]) +
	geom_histogram(data = dat[dat$treatment == 0,], aes(x = ps, y = -after_stat(count)), bins = 50, fill = cols[1]) +
	geom_hline(yintercept = 0, lwd = 0.5) +	scale_y_continuous(label = abs) 

# Covariate balance plot
PSAgraphics::cv.bal.psa(dat[,1:3], dat$treatment, dat$ps, strata = 5)

# Balance plot for quantitative variable
PSAgraphics::box.psa(dat$x1, 
					 dat$treatment, 
					 dat$strata5)

# Balance plot for categorical variables
PSAgraphics::cat.psa(dat$x3,
					 dat$treatment,
					 dat$strata5)

dat |> head(n = 4)

# Average Treatment Effect (ATE)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = ate_weight, y = after_stat(count)),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = ate_weight, y = -after_stat(count)),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect (ATE)')

# Average Treatment Effect Among the Treated (ATT)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = att_weight, y = after_stat(count)),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = att_weight, y = -after_stat(count)),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Treated (ATT)')

# Average Treatment Effect Among the Control (ATC)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = atc_weight, y = after_stat(count)),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = atc_weight, y = -after_stat(count)),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Control (ATC)')

# Average Treatment Effect Among the Evenly Matched (ACM)
ggplot() +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, y = after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 1,],
				   aes(x = ps, weight = atm_weight, y = after_stat(count)),
				   bins = 50, 
				   fill = cols[2], alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, y = -after_stat(count)),
				   bins = 50, alpha = 0.5) +
	geom_histogram(data = dat[dat$treatment == 0,],
				   aes(x = ps, weight = atm_weight, y = -after_stat(count)),
				   bins = 50, 
				   fill = cols[1], alpha = 0.5) +
	ggtitle('Average Treatment Effect Among the Evenly Matched (ACM)')

# ATE
psa::treatment_effect(
	treatment = dat$treatment, 
	outcome = dat$outcome, 
	weights = dat$ate_weight)

lm(outcome ~ treatment, 
   data = dat, 
   weights = dat$ate_weight)

# ATT
psa::treatment_effect(
	treatment = dat$treatment, 
	outcome = dat$outcome, 
	weights = dat$att_weight)

lm(outcome ~ treatment, 
   data = dat, 
   weights = dat$att_weight)

# ATC
psa::treatment_effect(
	treatment = dat$treatment, 
	outcome = dat$outcome, 
	weights = dat$atc_weight)

lm(outcome ~ treatment, 
   data = dat, 
   weights = dat$atc_weight)

# ATM
psa::treatment_effect(
	treatment = dat$treatment, 
	outcome = dat$outcome, 
	weights = dat$atm_weight)

lm(outcome ~ treatment, 
   data = dat, 
   weights = dat$atm_weight)


################################################################################
# Example using Lalonde dataset
lalonde.formu <- treat ~ age + educ + black + hisp +
	married + nodegr + re74 + re75

# Estimate Propensity scores
glm1 <- glm(lalonde.formu, 
			data = lalonde,
			family = binomial(link = 'logit'))

# Get Propensity Scores
lalonde$ps <- fitted(glm1)

# Stratification
strata5 <- cut(lalonde$ps, 
			   quantile(lalonde$ps, seq(0, 1, 1/5)), 
			   include.lowest = TRUE, 
			   labels = letters[1:5])

summary(glm1)

covars <- all.vars(lalonde.formu)
covars <- lalonde[,covars[2:length(covars)]]
cv.bal.psa(covars, lalonde$treat, lalonde$ps, strata = 5)


box.psa(lalonde$age, lalonde$treat, strata5)

box.psa(lalonde$re74, lalonde$treat, strata5)

box.psa(lalonde$educ, lalonde$treat, strata5)

box.psa(lalonde$re75, lalonde$treat, strata5)

cat.psa(lalonde$married, lalonde$treat, strata5)

cat.psa(lalonde$hisp, lalonde$treat, strata5)

cat.psa(lalonde$black, lalonde$treat, strata5)

cat.psa(lalonde$nodegr, lalonde$treat, strata5)

psadf <- data.frame(ps = lalonde$ps, Y = lalonde$re78, Tr = lalonde$treat)
psa::loess_plot(ps = psadf[psadf$Y < 30000,]$ps, 
				outcome = psadf[psadf$Y < 30000,]$Y, 
				treatment = as.logical(psadf[psadf$Y < 30000,]$Tr))

psa::stratification_plot(ps = psadf$ps,
						 treatment = psadf$Tr,
						 outcome = psadf$Y,
						 n_strata = 5)

psa::stratification_plot(ps = psadf$ps,
						 treatment = psadf$Tr,
						 outcome = psadf$Y,
						 n_strata = 10)

circ.psa(lalonde$re78, lalonde$treat, strata5)

strata10 <- cut(lalonde$ps, 
				quantile(lalonde$ps, seq(0, 1, 1/10)), 
				include.lowest = TRUE,
				labels = letters[1:10])
circ.psa(lalonde$re78, lalonde$treat, strata10)

circ.psa(lalonde$re78, lalonde$treat, strata5)

circ.psa(lalonde$re78, lalonde$treat, strata10)

################################################################################
# Matching
rr <- Match(Y = lalonde$re78, 
			Tr = lalonde$treat, 
			X = lalonde$ps, 
			M = 1,
			estimand = 'ATT',
			ties = FALSE)
summary(rr)

matches <- data.frame(Treat = lalonde[rr$index.treated,'re78'],
					  Control = lalonde[rr$index.control,'re78'])
granovagg.ds(matches[,c('Control','Treat')], xlab = 'Treat', ylab = 'Control')

psa::MatchBalance(df = lalonde, formu = lalonde.formu,
				  formu.Y = update.formula(lalonde.formu, re78 ~ .),
				  M = 1, estimand = 'ATT', ties = FALSE) |> plot()

psa::MatchBalance(df = lalonde, formu = lalonde.formu,
				  formu.Y = update.formula(lalonde.formu, re78 ~ .),
				  exact.covs = c('nodegr'), #<<
				  M = 1, estimand = 'ATT', ties = FALSE) |> plot()

################################################################################
# Sensitivity analysis
require(rbounds)
psens(lalonde$re78[rr$index.treated], 
	  lalonde$re78[rr$index.control],
	  Gamma = 2, GammaInc = 0.1)

# Bootstrapping
library(PSAboot)
psaboot <- PSAboot(Tr = lalonde$treat,
				   Y = lalonde$re78,
				   X = lalonde,
				   formu = lalonde.formu)
summary(psaboot)

psaboot_bal <- balance(psaboot)
plot(psaboot_bal)

plot(psaboot)

boxplot(psaboot)

matrixplot(psaboot)

################################################################################
# Matching three groups (e.g. two treatments and one control)
require(TriMatch)
data(tutoring)
formu <- ~ Gender + Ethnicity + Military + ESL + EdMother + EdFather + Age +
	   Employment + Income + Transfer + GPA

tutoring.tpsa <- trips(tutoring, tutoring$treat, formu)
tutoring.matched.n <- trimatch(tutoring.tpsa, method=OneToN, M1=5, M2=3)

plot(tutoring.matched.n, rows=c(50), draw.segments=TRUE)

multibalance.plot(tutoring.tpsa, grid=TRUE)

boxdiff.plot(tutoring.matched.n, tutoring$Grade)

################################################################################
# Multilevel PSA
data(pisana)
data(pisa.colnames)
data(pisa.psa.cols)
student = pisana
mlctree = mlpsa.ctree(student[,c('CNT','PUBPRIV',pisa.psa.cols)], 
					  formula=PUBPRIV ~ ., level2='CNT')
student.party = getStrata(mlctree, student, level2='CNT')
student.party$mathscore = apply(
student.party[,paste0('PV', 1:5, 'MATH')], 1, sum) / 5

tree.plot(mlctree, level2Col=student$CNT, colLabels=pisa.colnames[,c('Variable','ShortDesc')])

results.psa.math = mlpsa(response=student.party$mathscore, 
						 treatment=student.party$PUBPRIV, strata=student.party$strata, 
						 level2=student.party$CNT, minN=5)
results.psa.math$overall.wtd
results.psa.math$overall.ci
results.psa.math$level2.summary[,c('level2','Private','Private.n', 'Public','Public.n','diffwtd','ci.min','ci.max')]

plot(results.psa.math)

mlpsa.difference.plot(results.psa.math, sd=mean(student.party$mathscore, na.rm=TRUE))

################################################################################
# Shiny application
if(interactive()) {
	psa::psa_shiny()
}

