library(psa)

###### Using lalonde
data(lalonde, package='Matching')
formu.lalonde <- treat ~ age + I(age^2) + educ + I(educ^2) + hisp + married + nodegr + 
	re74  + I(re74^2) + re75 + I(re75^2) + u74 + u75
formu.Y.lalonde <- update.formula(formu.lalonde, re78 ~ .)

mb0.lalonde <- MatchBalance(df = lalonde, formu=formu.lalonde)
summary(mb0.lalonde)
plot(mb0.lalonde)

mb1.lalonde <- MatchBalance(df=lalonde, formu=formu.lalonde, exact.covs=c('educ'))
summary(mb1.lalonde)
plot(mb1.lalonde)

mb2.lalonde <- MatchBalance(df=lalonde, formu=formu.lalonde, exact.covs=c('educ','u75'))
summary(mb2.lalonde)
plot(mb2.lalonde)

##### Using lindner
data(lindner, package='PSAgraphics')
formu.lindner <- abcix ~ stent + height + female + diabetic + acutemi + ejecfrac + ves1proc
formu.Y.lindner <- update.formula(formu.lindner, cardbill.log ~ .)
lindner$cardbill.log <- log(lindner$cardbill)

mb0.lindner <- MatchBalance(df = lindner, formu = formu.lindner)#, formu.Y = formu.Y.lindner)
summary(mb0.lindner)
plot(mb0.lindner)

mb1.lindner <- MatchBalance(df = lindner, formu = formu.lindner, #formu.Y = formu.Y.lindner,
							exact.covs = c('ves1proc'))
summary(mb1.lindner)
plot(mb1.lindner)

mb2.lindner <- MatchBalance(df = lindner, formu = formu.lindner,# formu.Y = formu.Y.lindner,
							exact.covs = c('ves1proc','stent'))
summary(mb2.lindner)
plot(mb2.lindner)

mb2b.lindner <- MatchBalance(df = lindner, formu = formu.lindner,# formu.Y = formu.Y.lindner,
							exact.covs = c('ves1proc','ejecfrac'))
summary(mb2b.lindner)
plot(mb2b.lindner)

mb3.lindner <- MatchBalance(df = lindner, formu = formu.lindner,# formu.Y = formu.Y.lindner,
							exact.covs = c('ves1proc','stent','ejecfrac'))
summary(mb3.lindner)
plot(mb3.lindner)

