################################################################################
## Install packages

install.packages(c('devtools','ggplot2','granova','granovaGG','gridExtra',
				   'Matching','MatchIt','party','PSAgraphics','rbounds','rpart'), 
				 repos='http://cran.r-project.org')
# Both the multilevelPSA and TriMatch packages are available on CRAN, but we
# will install the latest versions from Github.
install.packages(c('multilevelPSA','TriMatch'), repos='http://cran.r-project.org')
require(devtools)
install_github('multilevelPSA', 'jbryer')
install_github('TriMatch', 'jbryer')
# The pisa package is a large (~80MB) data package. It is required to reproduce 
# the full international analysis of private and public schools in the 
# multilevelPSA package. Alternatively, the North American data is included in 
# the multilevelPSA package. See demo(pisa)
#install_github('pisa', 'jbryer')

################################################################################
## Load packages and data

require(ggplot2)
require(granova)
require(granovaGG)
require(Matching)
require(MatchIt)
require(party)
require(PSAgraphics)
require(rbounds)
require(rpart)
require(multilevelPSA)
require(TriMatch)

data(lalonde, package='Matching')
data(lindner, package='PSAgraphics')

str(lalonde)
str(lindner)

################################################################################
## Phase I

## Using logistic regression for estimating propensity scores 
lalonde.formu <- treat ~ age+ educ + black + hisp + married + nodegr + re74 + re75
lalonde.glm <- glm(lalonde.formu, family=binomial, data=lalonde)

summary(lalonde.glm)

# try the stepAIC in the MASS package
?stepAIC

ps <- fitted(lalonde.glm)  # Propensity scores
Y  <- lalonde$re78  # Dependent variable, real earnings in 1978
Tr <- lalonde$treat # Treatment indicator

## Matching
# one-to-one matching with replacement (the "M=1" option).
# Estimating the treatment effect on the treated (default is ATT).
rr <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE, replace=FALSE, estimand='ATT')
summary(rr) # The default estimate is ATT here
ls(rr)

rr2 <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=TRUE, replace=TRUE, estimand='ATT')
summary(rr2) # The default estimate is ATT here
length(unique(rr2$index.control))
length(unique(rr$index.control))
ls(rr2)

## Using the Matchit package
matchit.out <- matchit(lalonde.formu, data=lalonde)
summary(matchit.out)
plot(matchit.out, type='QQ')
plot(matchit.out, type='jitter')
plot(matchit.out, type='hist')

# Same as above but calculate average treatment effect
rr.ate <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE, replace=FALSE, estimand='ATE')
summary(rr.ate) # Here the estimate is ATE

## Genetic Matching
rr.gen <- GenMatch(Tr=Tr, X=ps, 
				   BalanceMatrix=lalonde[,all.vars(lalonde.formu)[-1]],
				   estimand='ATE', M=1, pop.size=16)
rr.gen.mout <- Match(Y=Y, Tr=Tr, X=ps, estimand='ATE', Weight.matrix=rr.gen)
summary(rr.gen.mout)

## Partial exact matching
rr2 <- Matchby(Y=Y, Tr=Tr, X=ps, by=factor(lalonde$nodegr))
summary(rr2)

## Partial exact matching on two covariates
rr3 <- Matchby(Y=Y, Tr=Tr, X=ps, by=lalonde[,c('nodegr','married')])
summary(rr3)

## Stratification using a classification tree
rpart.fit <- rpart(lalonde.formu, data=lalonde)
print(rpart.fit)
strata.rpart <- rpart.fit$where
ps.rpart <- predict(rpart.fit, lalonde)
table(lalonde$treat, strata.rpart, useNA='ifany')

## Using the tree package
tree.fit <- tree(lalonde.formu, data=lalonde)
print(tree.fit)
strata.tree <- tree.fit$where
ps.tree <- predict(tree.fit)
table(lalonde$treat, strata.tree, useNA='ifany')

tmp <- data.frame(treat=factor(lalonde$treat),
				  ps.lr=fitted(lalonde.glm),
				  ps.tree=predict(tree.fit),
				  ps.rpart=predict(rpart.fit),
				  strata.rpart=factor(rpart.fit$where),
				  strata.tree=factor(tree.fit$where) )
ggplot(tmp, aes(x=ps.lr, y=treat, color=strata.tree)) + geom_jitter() + 
	scale_color_brewer(type='qual')
ggplot(tmp, aes(x=ps.tree, y=treat, color=strata.tree)) + geom_jitter() + 
	scale_color_brewer(type='qual')
ggplot(tmp, aes(x=ps.lr, y=ps.tree, color=strata)) + geom_point() +
	coord_equal(ratio=1) + scale_color_brewer(type='qual') +
	facet_grid(~ treat)


## Stratification using quintiles
strata <- cut(ps, quantile(ps, seq(0, 1, 1/5)), include.lowest=TRUE, 
			  labels=letters[1:5])
table(strata, useNA='ifany')
table(lalonde$treat, strata, useNA='ifany')

## Stratification using 10 strata
strata10 <- cut(ps, quantile(ps, seq(0, 1, 1/10)), include.lowest=TRUE, 
				labels=letters[1:10])
table(lalonde$treat, strata10, useNA='ifany')


################################################################################
## Checking balance

match.age <- data.frame(Treat=lalonde[rr$index.treated,'age'], 
						Control=lalonde[rr$index.control,'age'])
t.test(match.age$Treat, match.age$Control, paired=TRUE)

mb <- MatchBalance(lalonde.formu, data=lalonde, match.out=rr, nboots=100)

box.psa(lalonde$age, lalonde$treat, strata, xlab="Strata", balance=FALSE)
cat.psa(lalonde$nodegr, lalonde$treat, strata, xlab='Strata', balance=FALSE)

covars <- all.vars(lalonde.formu)
covars <- lalonde[,covars[2:length(covars)]]
cv.bal.psa(covars, lalonde$treat, ps, strata)

################################################################################
## Phase II

loess.psa(response=Y, treatment=Tr, propensity=ps) #from PSAgraphics
loess.plot(ps, response=Y, treatment=as.logical(Tr), 
		   method='loess', plot.strata=10) #from multilevelPSA
loess.plot(ps, response=log(Y+1), treatment=as.logical(Tr), 
		   plot.strata=10) #from multilevelPSA

## For matching methods
matches <- cbind(Treat=rr$index.treated, Control=rr$index.control)
head(matches)
matches <- data.frame(Treat=lalonde[rr$index.treated,'re78'], 
					  Control=lalonde[rr$index.control,'re78'])
head(matches)
t.test(x=matches$Treat, y=matches$Control, paired=TRUE)

granova.ds(matches) #Original dependent sample plot
granovagg.ds(matches) #ggplot2 version

## For stratification methods
# Five strata
circ.psa(lalonde$re78, lalonde$treat, strata, revc=TRUE)
# Ten strata
circ.psa(lalonde$re78, lalonde$treat, strata10, revc=TRUE)
# Classification tree
circ.psa(lalonde$re78, lalonde$treat, strata.rpart, revc=TRUE)

## With the MatchIt package
matchit.df <- data.frame(treat=lalonde[row.names(matchit.out$match.matrix),'re78'], 
						 control=lalonde[matchit.out$match.matrix[,1],'re78'])
t.test(matchit.df$treat, matchit.df$control, paired=TRUE)


################################################################################
## Multilevel PSA

data(pisana)
data(pisa.colnames)
data(pisa.psa.cols)
str(pisana)

table(pisana$CNT, pisana$PUBPRIV, useNA='ifany')
prop.table(table(pisana$CNT, pisana$PUBPRIV, useNA='ifany'), 1) * 100

## Phase I
#Use conditional inference trees from the party package
mlctree <- mlpsa.ctree(pisana[,c('CNT','PUBPRIV',pisa.psa.cols)], 
		 			   formula=PUBPRIV ~ ., level2='CNT')
pisana.party <- getStrata(mlctree, pisana, level2='CNT')

#Tree heat map showing relative importance of covariates used in each tree.
tree.plot(mlctree, level2Col=pisana$CNT, 
		  colLabels=pisa.colnames[,c('Variable','ShortDesc')])

#NOTE: This is not entirely correct but is sufficient for visualization purposes
#      See mitools package for combining multiple plausible values.
pisana.party$mathscore <- apply(pisana.party[,paste0('PV',1:5,'MATH')],1,sum)/5
pisana.party$readscore <- apply(pisana.party[,paste0('PV',1:5,'READ')],1,sum)/5
pisana.party$sciescore <- apply(pisana.party[,paste0('PV',1:5,'SCIE')],1,sum)/5

## Phase II
results.psa.math <- mlpsa(response=pisana.party$mathscore, 
						  treatment=pisana.party$PUBPRIV, 
						  strata=pisana.party$strata, 
						  level2=pisana.party$CNT, minN=5)
summary(results.psa.math)
ls(results.psa.math)

results.psa.math$level2.summary[,c('level2','n','Private','Private.n','Public',
								   'Public.n','diffwtd','ci.min','ci.max','df')]
View(results.psa.math$level2.summary)
results.psa.math$overall.ci

# These are the two main plots
plot(results.psa.math)
mlpsa.difference.plot(results.psa.math)
# Specifying sd (the standard deviation) effect sizes will be plotted.
mlpsa.difference.plot(results.psa.math, sd=sd(pisana.party$mathscore))

# Or the individual components of the main plot separately
mlpsa.circ.plot(results.psa.math, legendlab='Country')
mlpsa.distribution.plot(results.psa.math, 'Public')
mlpsa.distribution.plot(results.psa.math, 'Private')


################################################################################
## Matching of non-binary treatments

data(tutoring)
str(tutoring)

table(tutoring$treat)
# Histogram of unadjusted grades
tmp <- as.data.frame(prop.table(table(tutoring$treat, tutoring$Grade), 1))
ggplot(tmp, aes(x=Var2, y=Freq, fill=Var1)) + 
	geom_bar(position='dodge', stat='identity') +
	scale_y_continuous(labels = percent_format()) +
	xlab('Grade') + ylab('Percent') + scale_colour_hue('Treatment')

## Phase I

# Note that the dependent variable is not included in the formula. The TriMatch
# functions will replace the dependent variable depending on which pair is
# being modeled.
tutoring.formu <- ~ Gender + Ethnicity + Military + ESL + EdMother + EdFather + 
	                Age + Employment + Income + Transfer + GPA

# trips will estimate the propensity scores for each pairing of groups
tutoring.tpsa <- trips(tutoring, tutoring$treat, tutoring.formu)

plot(tutoring.tpsa, sample=c(200))

# trimatch finds matched triplets.
tutoring.matched <- trimatch(tutoring.tpsa)

# Partial exact matching
tutoring.matched2 <- trimatch(tutoring.tpsa, exact=tutoring$Level)

# Plotting the results of trimatch is a subset of the triangle plot with only
# points that were matched. There is also an additional parameter, rows, that
# will overlay matched triplets.
plot(tutoring.matched, rows=1, line.alpha=1, draw.segments=TRUE)

## Examine the unmatched students
unmatched <- unmatched(tutoring.matched)
summary(unmatched)
plot(unmatched)

## Check balance
multibalance.plot(tutoring.tpsa)

balance.plot(tutoring.matched, tutoring$Age, label='Age')
balance.plot(tutoring.matched, tutoring$Military, label='Military')

# Create a grid of figures.
bplots <- balance.plot(tutoring.matched, tutoring[,all.vars(tutoring.formu)], 
					   legend.position='none', 
					   x.axis.labels=c('C','T1','T1'), x.axis.angle=0)
bplots[['Military']] # We can plot one at at time.
summary(bplots) # Create a data frame with the statistical results
plot(bplots, cols=3, byrow=FALSE)

## Phase II
# The summary function performs a number of statistical tests including Friedman
# rank sum test, repeated measures ANOVA, and if one or both of those tests have
# p values less than 0.5 (the default, but configurable), then a pairwise Wilcox
# test and three paired t-tests will also be performed.
(sout <- summary(tutoring.matched, tutoring$Grade))
ls(sout)

boxdiff.plot(tutoring.matched, tutoring$Grade, ordering=c('Treat2','Treat1','Control'))
parallel.plot(tutoring.matched, tutoring$Grade)

# The Loess plot is imperfect with three sets of propensity scores. There is a
# model parameter to specify which model to use. Once we a model is selected
# we have propensity scores for two of the three groups. We impute a propensity
# score on that model's scale for the third group as the midpoint between
# the other two propensity scores that unit was matched to.
loess3.plot(tutoring.matched, tutoring$Grade, se=FALSE, method='loess')
# Turn on 95% confidence interval (see also the level parameter)
loess3.plot(tutoring.matched, tutoring$Grade, se=TRUE, method='loess')
# We can also pass other parameters to the loess function.
loess3.plot(tutoring.matched, tutoring$Grade, se=TRUE, method='loess', span=1)
# This is a busy plot, but since all the lines are practically vertical, the
# distance between each pair of propensity scores is minimal.
loess3.plot(tutoring.matched, tutoring$Grade, se=FALSE, method='loess', 
			plot.connections=TRUE)

# The merge function will add the outcome to the matched triplet data frame.
# This is useful for other approaches to analyzing the matched triplets.
tmatch.out <- merge(tutoring.matched, tutoring$Grade)
head(tmatch.out)
