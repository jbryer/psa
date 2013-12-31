### R code from vignette source '/Users/jbryer/Dropbox/School/Submissions/2013-NEAIR/PSASlides/Slides.Rnw'

###################################################
### code chunk number 1: Slides.Rnw:62-82
###################################################
options(width=70)
options(digits=2)
options(continue="   ")
options(warn=-1)

require(devtools)
require(ggplot2)
require(multilevelPSA)
require(Matching)
require(MatchIt)
require(multilevelPSA)
require(party)
require(PSAgraphics)
require(granovaGG)
require(rbound)
require(rpart)
require(TriMatch)

data(pisana)
data(tutoring)


###################################################
### code chunk number 2: Slides.Rnw:248-249
###################################################
data(tutoring)

###################################################
### code chunk number 3: Slides.Rnw:256-259
###################################################

tutoring$treatbool <- tutoring$treat != 'Control'
tutoring.formu <- treatbool ~ Gender + Ethnicity + Military + ESL + EdMother + 
	EdFather + Age + Employment + Income + Transfer + GPA
glm1 <- glm(tutoring.formu, family=binomial, data=tutoring)
summary(glm1)


###################################################
### code chunk number 4: Slides.Rnw:265-270
###################################################
ps <- fitted(glm1)  # Propensity scores
Y  <- tutoring$Grade  # Dependent variable, real earnings in 1978
Tr <- tutoring$treatbool # Treatment indicator
rr <- Match(Y=Y, Tr=Tr, X=ps, M=1, ties=FALSE)
summary(rr) # The default estimate is ATT here


###################################################
### code chunk number 5: granovaggds
###################################################

###################################################
### code chunk number 6: circpsa5
###################################################
strata <- cut(ps, quantile(ps, seq(0, 1, 1/5)), include.lowest=TRUE, labels=letters[1:5])
circ.psa(tutoring$Grade, tutoring$treatbool, strata, revc=TRUE)


###################################################
### code chunk number 7: circpsa10
###################################################
strata10 <- cut(ps, quantile(ps, seq(0, 1, 1/10)), include.lowest=TRUE, labels=letters[1:10])
circ.psa(tutoring$Grade, tutoring$treatbool, strata10, revc=TRUE)


###################################################
### code chunk number 8: loessplot
###################################################
psadf <- data.frame(ps, Y, Tr)
print(loess.plot(psadf$ps, response=psadf$Y, treatment=psadf$Tr))


###################################################
### code chunk number 9: boxpsa
###################################################
box.psa(tutoring$Age, tutoring$treatbool, strata, xlab="Strata", 
balance=FALSE)


###################################################
### code chunk number 10: catpsa
###################################################
cat.psa(tutoring$Gender, tutoring$treatbool, strata, xlab='Strata', 
balance=FALSE)


###################################################
### code chunk number 11: cvbalpsa
###################################################
covars <- all.vars(tutoring.formu)
covars <- tutoring[,covars[2:length(covars)]]
cv.bal.psa(covars[,3:11], tutoring$treatbool, ps, strata)


###################################################
### code chunk number 12: Slides.Rnw:376-385
###################################################

require(TriMatch)

data(tutoring)
formu <- ~ Gender + Ethnicity + Military + ESL + EdMother + EdFather + Age +
	       Employment + Income + Transfer + GPA

tutoring.tpsa <- trips(tutoring, tutoring$treat, formu)
tutoring.matched.n <- trimatch(tutoring.tpsa, method=OneToN, M1=5, M2=3)


###################################################
### code chunk number 13: triangleplot
###################################################
print(plot(tutoring.matched.n, rows=c(50), draw.segments=TRUE))


###################################################
### code chunk number 14: balanceplot
###################################################
print(multibalance.plot(tutoring.tpsa, grid=TRUE))


###################################################
### code chunk number 15: boxdiff
###################################################
print(boxdiff.plot(tutoring.matched.n, tutoring$Grade))

#### Bootstrapping
require(PSAboot)

table(tutoring$treatbool)
prop.table(table(tutoring$treatbool))

X <- tutoring[,all.vars(tutoring.formu)]
X <- X[,-1] # Remove the treatment indicator
Tr <- tutoring$treatbool
Y <- tutoring$Grade
#tutoring.boot <- PSAboot(Tr=Tr, Y=Y, X=X, seed=2112)
tutoring.boot <- PSAboot(Tr=Tr, Y=Y, X=X, seed=2112,
						 control.sample.size=918, control.replace=TRUE,
						 treated.sample.size=224, treated.replace=TRUE)
summary(tutoring.boot)
plot(tutoring.boot)
boxplot(tutoring.boot)
matrixplot(tutoring.boot)
