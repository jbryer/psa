library(shiny)
library(foreign)
library(gdata)
library(tools)
library(psa)
library(Matching)
library(PSAgraphics)
library(granovaGG)
library(ggplot2)
library(multilevelPSA)
library(grid)
library(stargazer)
library(knitr)
library(randomForest)
library(party)
# library(shinyBS)
library(TriMatch)
#library(PSAboot)

##### Define the built-in datasets
data(lalonde, package='Matching')
data(lindner, package='PSAgraphics')
data(GerberGreenImai, package='Matching')
data(tutoring, package='TriMatch')

lindner$log_cardbill <- log(lindner$cardbill)
tutoring$treat <- tutoring$treat %in% c('Treat1','Treat2')

datasets <- list(
	'lindner' = list(data = lindner,
					 outcome = 'log_cardbill',
					 treat = 'abcix',
					 covariates = c('stent', 'height', 'female', 'diabetic', 'acutemi',
					 			   'ejecfrac', 'ves1proc'),
					 help.file = 'lindner.md'),
	'lalonde' = list(data = lalonde,
					 outcome = 're78',
					 treat = 'treat',
					 covariates = c('age','educ', 'black', 'hisp', 'married', 'nodegr',
					 			   're74', 're75', 'u74', 'u75'),
					 help.file = 'lalonde.md'),
	'tutoring' = list(data = tutoring,
					  outcome = 'Grade',
					  treat = 'treat',
					  covariates = c('Gender', 'Ethnicity', 'Military', 'ESL', 'EdMother',
					  			   'EdFather', 'Age', 'Employment', 'Income', 'Transfer', 'GPA'),
					  help.file = 'tutoring.md'),
	'GerberGreenImai' = list(data = GerberGreenImai,
							 outcome = 'VOTED98',
							 treat = 'PHN.C1',
							 covariates = c('PERSONS','VOTE96.1','NEW','MAJORPTY',
							 			    'AGE','WARD','AGE2'),
							 help.file = 'GerberGreenImai.md')
)

# Returns a vector fo column names from df that have two levels (e.g. logical,
# two level factor, integer with 0s and 1s, etc.).
getTwoLevelVars <- function(df) {
	cols <- c()
	for(i in seq_len(ncol(df))) {
		if(length(unique(df[,i])) == 2) {
			cols <- c(cols, names(df)[i])
		}
	}
	return(cols)
}

