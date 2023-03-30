require(PSAboot)
data(tutoring, package='TriMatch')

boot.matching.1to3 <- function(Tr, Y, X, X.trans, formu, ...) {
	return(boot.matching(Tr=Tr, Y=Y, X=X, X.trans=X.trans, formu=formu, M=3, ...))
}

tutoring$treatbool <- tutoring$treat != 'Control'
covs <- tutoring[,c('Gender', 'Ethnicity', 'Military', 'ESL', 'EdMother', 'EdFather',
					'Age', 'Employment', 'Income', 'Transfer', 'GPA')]

table(tutoring$treatbool)
tutoring.boot <- PSAboot(Tr=tutoring$treatbool, 
						 Y=tutoring$Grade, 
						 X=covs, 
						 seed=2112,
						 control.sample.size=918, control.replace=TRUE,
						 treated.sample.size=224, treated.replace=TRUE,
						 methods=c('Stratification'=boot.strata,
						 		  'ctree'=boot.ctree,
						 		  'rpart'=boot.rpart,
						 		  'Matching'=boot.matching,
						 		  'Matching-1-to-3'=boot.matching.1to3,
						 		  'MatchIt'=boot.matchit) )

summary(tutoring.boot)
as.data.frame(summary(tutoring.boot))
plot(tutoring.boot)
boxplot(tutoring.boot)
boxplot(tutoring.boot, tufte=TRUE, bootstrap.ci.size=NA)
matrixplot(tutoring.boot)

tutoring.bal <- balance(tutoring.boot)
tutoring.bal
plot(tutoring.bal)
boxplot(tutoring.bal) + geom_hline(yintercept=.1, color='red')

# We can use a different function to pool the balance statistics (i.e. effect sizes).
# The default above is to use the mean, but using the maximum value will show
# the worst case for balance.
tutoring.bal2 <- balance(tutoring.boot, pool.fun=max)
tutoring.bal2
plot(tutoring.bal2)
# The pool.fun doesn't affect the boxplot
boxplot(tutoring.bal2) + geom_hline(yintercept=.1, color='red') 

# Details are available within the returned object
tutoring.bal$unadjusted
tutoring.bal$complete
tutoring.bal$pooled
