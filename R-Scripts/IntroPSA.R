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
require(PSAboot)
# require(pisa)

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

