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
require(tree)
require(TriMatch)
require(PSAboot)

data(tutoring)
str(tutoring)

# The tutoring example has treatment with three levels: Treat1, Treat2, and Control.
# We'll convert this to a two level treatment for this example. 
tutoring$treat2 <- tutoring$treat != 'Control'
table(tutoring$treat, tutoring$treat2, useNA='ifany')

################################################################################
## Phase I

## Using logistic regression for estimating propensity scores 
tutoring.formu <- treat2 ~ Gender + Ethnicity + Military + ESL + EdMother +
	EdFather + Age + Employment + Income + Transfer + GPA
tutoring.glm <- glm(tutoring.formu, family=binomial, data=tutoring)

summary(tutoring.glm)

# try the stepAIC in the MASS package
?stepAIC

ps <- fitted(tutoring.glm)  # Propensity scores
Y  <- tutoring$Grade  # Dependent variable, real earnings in 1978
Tr <- tutoring$treat2 # Treatment indicator

# Check the distributions of propensity scores to ensure we have good overlap
ggplot(data.frame(ps=ps, Y=Y, Tr=Tr), aes(x=ps, color=Tr)) + geom_density()

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

rr3 <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=TRUE, replace=FALSE, estimand='ATT')
summary(rr3) # The default estimate is ATT here

## Using the Matchit package
matchit.out <- matchit(tutoring.formu, data=tutoring)
summary(matchit.out)

# Same as above but calculate average treatment effect
rr.ate <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE, replace=FALSE, estimand='ATE')
summary(rr.ate) # Here the estimate is ATE

## Genetic Matching
rr.gen <- GenMatch(Tr=Tr, X=ps, 
				   BalanceMatrix=model.matrix(tutoring.formu, tutoring)[,-1],
				   estimand='ATE', M=1, pop.size=16) #pop.size=16 only for speed, should be larger
rr.gen.mout <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE, estimand='ATE', Weight.matrix=rr.gen)
summary(rr.gen.mout)

## Partial exact matching
rr2 <- Matchby(Y=Y, Tr=Tr, X=ps, by=factor(tutoring$Course))
summary(rr2)

## Partial exact matching on two covariates
rr3 <- Matchby(Y=Y, Tr=Tr, X=ps, by=tutoring[,c('Course','Gender')])
summary(rr3)

## Stratification using a classification tree
rpart.fit <- rpart(tutoring.formu, data=tutoring)
print(rpart.fit)
par(xpd = TRUE) # This fixes an issue that would clip the text
plot(rpart.fit, uniform=TRUE); text(rpart.fit, use.n=TRUE, all=TRUE, cex=.8)
par(xpd = FALSE) # Reset to default value
strata.rpart <- rpart.fit$where
ps.rpart <- predict(rpart.fit, tutoring)

# Let's try the logistic regression again
glm.out2 <- glm(treat2 ~ Gender + Ethnicity + Military + ESL + EdMother + EdFather + 
					Age + Employment + Income + Transfer + GPA + Transfer * Gender,
				data=tutoring, family=binomial)
summary(glm.out2)

# We see the results are the same vis-à-vis stratification perspective, but the
# interpretation is a bit different. The predict function gives the class
# probability which is the conditional probability of being in the treatment in
# this example, whereas the "where" object give the class label.
table(strata.rpart, ps.rpart) 

table(tutoring$treat2, strata.rpart, useNA='ifany')

## Stratification using the party package (conditional inference trees)
ctree.fit <- ctree(tutoring.formu, data=tutoring)
print(ctree.fit)
plot(ctree.fit)
strata.ctree <- where(ctree.fit)
ps.ctree <- predict(ctree.fit)
table(tutoring$treat2, strata.ctree, useNA='ifany')

## Using the tree package
tree.fit <- tree(tutoring.formu, data=tutoring)
print(tree.fit)
strata.tree <- tree.fit$where
ps.tree <- predict(tree.fit)
table(tutoring$treat2, strata.tree, useNA='ifany')

tmp <- data.frame(treat=factor(tutoring$treat2),
				  ps.lr=fitted(tutoring.glm),
				  ps.tree=predict(tree.fit),
				  ps.rpart=predict(rpart.fit),
				  strata.rpart=factor(rpart.fit$where),
				  strata.tree=factor(tree.fit$where) )

# The relationship between the propensity scores estimated using logistic
# regression and a classificaiton tree.
ggplot(tmp, aes(x=ps.lr, y=treat, color=strata.tree)) + geom_jitter() + 
	scale_color_brewer(type='qual')
# The relationship between the conditional probability and classification.
ggplot(tmp, aes(x=ps.tree, y=treat, color=strata.tree)) + geom_jitter() + 
	scale_color_brewer(type='qual')
# Same as above, but separate out treatment and control. Here, we see there are
# control units in strata 11 (with propensity scores near 1).
ggplot(tmp, aes(x=ps.lr, y=ps.tree, color=strata.tree)) + geom_point() +
	coord_equal(ratio=1) + scale_color_brewer(type='qual') +
	facet_grid(~ treat)


## Stratification using quintiles
strata <- cut(ps, quantile(ps, seq(0, 1, 1/5)), include.lowest=TRUE, 
			  labels=letters[1:5])
table(strata, useNA='ifany')
table(tutoring$treat2, strata, useNA='ifany')

## Stratification using 10 strata
strata10 <- cut(ps, quantile(ps, seq(0, 1, 1/10)), include.lowest=TRUE, 
				labels=letters[1:10])
table(tutoring$treat2, strata10, useNA='ifany')


################################################################################
## Checking balance

match.age <- data.frame(Treat=tutoring[rr$index.treated,'Age'], 
						Control=tutoring[rr$index.control,'Age'])
t.test(match.age$Treat, match.age$Control, paired=TRUE)

mb <- MatchBalance(tutoring.formu, data=tutoring, match.out=rr, nboots=100)

box.psa(tutoring$Age, tutoring$treat2, strata, xlab="Strata", balance=FALSE)
cat.psa(tutoring$Gender, tutoring$treat2, strata, xlab='Strata', balance=FALSE)
cat.psa(tutoring$Ethnicity, tutoring$treat2, strata, xlab='Strata', balance=FALSE)

covars <- all.vars(tutoring.formu)
covars <- cv.trans.psa(tutoring[,covars[2:length(covars)]])[[1]]
cv.bal.psa(covars, tutoring$treat2, ps, strata)

################################################################################
## Phase II

loess.psa(response=Y, treatment=Tr, propensity=ps) #from PSAgraphics
loess_plot(ps, response=Y, treatment=as.logical(Tr), 
		   method='loess', plot.strata=10) #from multilevelPSA

## For matching methods
matches <- cbind(Treat=rr$index.treated, Control=rr$index.control)
head(matches)
matches <- data.frame(Treat=tutoring[rr$index.treated,'Grade'], 
					  Control=tutoring[rr$index.control,'Grade'])
head(matches)
t.test(x=matches$Treat, y=matches$Control, paired=TRUE)

granova.ds(matches) #Original dependent sample plot
granovagg.ds(matches) #ggplot2 version

## For stratification methods
# Five strata
circ.psa(tutoring$Grade, tutoring$treat2, strata, revc=TRUE)
# Ten strata
circ.psa(tutoring$Grade, tutoring$treat2, strata10, revc=TRUE)
# Classification tree
circ.psa(tutoring$Grade, tutoring$treat2, strata.tree, revc=TRUE)

## With the MatchIt package
matchit.df <- data.frame(treat=tutoring[row.names(matchit.out$match.matrix),'Grade'], 
						 control=tutoring[matchit.out$match.matrix[,1],'Grade'])
t.test(matchit.df$treat, matchit.df$control, paired=TRUE)

