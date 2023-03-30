require(Matching)
require(mice)
require(ggplot2)
require(reshape2)

data(lalonde, package='Matching')

Tr <- lalonde$treat
Y <- lalonde$re78
X <- lalonde[,c('age','educ','black','hisp','married','nodegr','re74','re75')]

missing.rate <- .2 # What percent of rows will have missing data
missing.cols <- c('nodegr')
missing.cols <- c('nodegr', 're75') # The columns we will add missing values to

results <- data.frame(ratio=seq(1, 2, by=.05), stringsAsFactors=FALSE)
for(i in missing.cols) { results[,i] <- NA }
set.seed(2112) #NOTE: May want to remove this line
pb <- txtProgressBar(min=0, max=nrow(results), style=3)
for(j in 1:nrow(results)) {
	missing.ratio <- results[j,]$ratio
	lalonde.mar <- X
	lalonde.nmar <- X
	
	# Vectors indiciating which rows are treatment and control.
	treat.rows <- which(lalonde$treat == 1)
	control.rows <- which(lalonde$treat == 0)
	
	# Add missingness to the existing data. For the not missing at random data 
	# treatment units will have twice as many missing values as the control group.
	for(i in missing.cols) {
		lalonde.mar[sample(nrow(lalonde), nrow(lalonde) * missing.rate), i] <- NA
		lalonde.nmar[sample(treat.rows, length(treat.rows) * missing.rate * missing.ratio), i] <- NA
		lalonde.nmar[sample(control.rows, length(control.rows) * missing.rate), i] <- NA
	}
	
	# Create a shadow matrix. This is a logical vector where each cell is TRUE if the
	# value is missing in the original data frame.
	shadow.matrix.mar <- as.data.frame(is.na(lalonde.mar))
	shadow.matrix.nmar <- as.data.frame(is.na(lalonde.nmar))
	
	# Change the column names to include "_miss" in their name.
	names(shadow.matrix.mar) <- names(shadow.matrix.nmar) <- paste0(names(shadow.matrix.mar), '_miss')
	
	# Impute the missing values using the mice package
	mice.mar <- mice(lalonde.mar, m=1, printFlag=FALSE)
	mice.nmar <- mice(lalonde.nmar, m=1, printFlag=FALSE)
	
	# Get the imputed data set.
	complete.mar <- complete(mice.mar)
	complete.nmar <- complete(mice.nmar)
	
	# Estimate the propensity scores using logistic regression.
	lalonde.mar.glm <- glm(treat~., data=cbind(treat=Tr, complete.mar, shadow.matrix.mar))
	lalonde.nmar.glm <- glm(treat~., data=cbind(treat=Tr, complete.nmar, shadow.matrix.nmar))
	
	# We see that the two indicator columns from the shadow matrix are statistically
	# significant predictors suggesting that the data is not missing at random.
	sum.mar <- summary(lalonde.mar.glm)
	sum.nmar <- summary(lalonde.nmar.glm)
	for(i in missing.cols) {
		results[j,i] <- sum.nmar$coefficients[paste0(i, '_missTRUE'),4]
	}
	setTxtProgressBar(pb, j)
}
close(pb)

tmp <- melt(results, id='ratio', value.name='p.value')

ggplot(tmp, aes(x=ratio, y=p.value, group=variable, color=variable)) + 
	geom_point(size = 1) +
	geom_path() +
	geom_hline(yintercept=0.05, color='blue') +
	geom_text(label="p = 0.05", x=1.9, y=.05, color='blue', vjust=-0.3, size=4) +
	geom_hline(yintercept=0.1, color='blue') +
	geom_text(label="p = 0.1", x=1.9, y=.1, color='blue', vjust=-0.3, size=4) +
	geom_hline(yintercept=0.5, color='blue') +
	geom_text(label="p = 0.5", x=1.9, y=.5, color='blue', vjust=-0.3, size=4) +
	scale_x_continuous(breaks=seq(1, 2, .1)) +
	xlab('Ratio of missingness (treatment-to-control)') +
	ylab('p-value')
	
