# Load packages
library(ggplot2)
library(granovaGG)
library(granova)
library(Matching)
library(MatchIt)
library(multilevelPSA)
library(TriMatch)
library(PSAboot)
library(PSAgraphics)
library(knitr)

set.seed(2112)

# http://stackoverflow.com/questions/11228403/setting-default-number-of-decimal-places-for-printing
print.numeric<-function(x, digits = 2) { 
	formatC(x, digits = digits, format = "f")
}

# knir options
knitr::opts_chunk$set(fig.width=12, fig.height=8, fig.align='center',
					  echo=TRUE, warning=FALSE, message=FALSE)

# Set ggplot2 theme
theme_update(panel.background=element_rect(size=1, color='grey70', fill=NA) )

# Load datasets
data(lalonde, package='Matching')
data(lindner, package='PSAgraphics')
data(tutoring, package='TriMatch')
tutoring$treat2 <- tutoring$treat != 'Control'
data(pisana, package='multilevelPSA')
pisa.usa <- pisana[pisana$Country == 'United States',]

lalonde.formu <- treat ~ age + I(age^2) + educ + I(educ^2) + black +
	hisp + married + nodegr + re74  + I(re74^2) + re75 + I(re75^2) +
	u74 + u75

lindner.formu <- abcix ~ stent + height + female + diabetic + acutemi + 
	ejecfrac + ves1proc

tutoring.formu <- treat2 ~ Gender + Ethnicity + Military + ESL + EdMother +
	EdFather + Age + Employment + Income + Transfer + GPA + Level
