## Sensitivity Analysis

require(rbounds)

# Data from Chapter 4 of Observational Studies (Rosenbaum, 2002)
# Matched Data of Lead Blood Levels in Children
trt <- c(38, 23, 41, 18, 37, 36, 23, 62, 31, 34, 24, 14, 21, 17, 16, 20, 15, 
		 10, 45, 39, 22, 35, 49, 48, 44, 35, 43, 39, 34, 13, 73, 25, 27)
ctrl <- c(16, 18, 18, 24, 19, 11, 10, 15, 16, 18, 18, 13, 19, 10, 16, 16, 
		  24, 13, 9, 14, 21, 19, 7, 18, 19, 12, 11, 22, 25, 16, 13, 11, 13)

psens(trt, ctrl)
hlsens(mgen1)


# Using Lalonde data
data(lalonde)

Y  <- lalonde$re78   #the outcome of interest
Tr <- lalonde$treat #the treatment of interest
attach(lalonde)
#The covariates we want to match on
X = cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, re74)
#The covariates we want to obtain balance on
BalanceMat <- cbind(age, educ, black, hisp, married, nodegr, u74, u75, re75, re74,
					I(re74*re75))
detach(lalonde)

gen1 <- GenMatch(Tr=tr, X=X, pop.size=50,
                  data.type.int=FALSE, print=0, replace=FALSE)
mgen1 <- Match(Y=Y, Tr=Tr, X=X, Weight.matrix=gen1, replace=FALSE)
summary(mgen1)

psens(mgen1, Gamma=1.5, GammaInc=.1)
hlsens(mgen1, Gamma=1.5, GammaInc=.1, .1)

