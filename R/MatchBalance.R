#' Calculates balance statistics for matching.
#' 
#' @param df data frame with data to match.
#' @param formu the formula used to estimate propensity scores using logistic 
#'        regression.
#' @param formu.Y (optional) the formula used to estimate a multiple regression model with
#'        covariates. Used to estimate covariate importance.
#' @param index.treated a vector of integers corresponding to the rows in \code{df}
#'        for the matched treated units. That is, \code{index.treated[i]} is matched
#'        to \code{index.control[i]}.
#' @param index.control a vector of integers corresponding to the rows in \code{df}
#'        for the matched control units. That is, \code{index.treated[i]} is matched
#'        to \code{index.control[i]}.
#' @param exact.covs character vector of covariates to match exactly on. For 
#'        quantitative variables with more than two unique values, matches will 
#'        be made within quintiles.
#' @param tolerance the maximum standard deviation the difference between matches
#'        on a quantitative covariate can be to be considered matched.
#' @param n.levels maximum number of unique values in a covariate to attempt to
#'        match exactly. If the number of unique values is greater than \code{n.levels},
#'        then the covariate will be cut using quantiles and exact matches will
#'        be estimated within each quantile.
#' @param ... other parameters passed to \code{\link{Match}}.
#' @return An object of class \code{MatchBalance} with the following elements:
#'         \describe{
#'           \item{ps.out}{Results from the logistic regression model for treatment.}
#'           \item{Y.out}{Results from the multiple regression model for Y.}
#'           \item{covariate.matched}{a named numeric vector containing the percent
#'                 of observations with "perfect" match for each covariate.}
#'           \item{covariate.balance}{a named numeric vector containing the percent
#'                 of covariates with "perfect" match for each observation.}
#'           \item{covariate.importance}{a data frame with covariate importance.
#'                 Covariate importance is estimated using the sum of the absolute
#'                 t-statistic from both glm calls for treatment and outcome.}
#'           \item{index.treated}{vector containing observation row number from original
#'                 data frame for treated observations.}
#'           \item{index.control}{vector containing observatino row number from original
#'                 data frame for control observations.}
#'         }
#' @export
MatchBalance <- function(df, formu, formu.Y, exact.covs, 
						 index.treated, index.control,
						 tolerance = 0.25,
						 n.levels = 2, ...) {
	n.strata <- 5
	
	if(is.logical(class(df[,all.vars(formu)[1]]))) {
		df[,all.vars(formu)[1]] <- as.integer(df[,all.vars(formu)[1]])
	}

	lr.out <- glm(formu, family=binomial, data=df)

	glm.out <- NULL
	if(!missing(formu.Y)) {
		glm.out <- glm(formu.Y, data=lr.out$data)
	}

	var.imp <- data.frame(Treat=summary(lr.out)$coefficients[,'z value'])
	
	if(!missing(formu.Y)) {
		var.imp$Y <- summary(glm.out)$coefficients[,'t value']
		var.imp$Total <- abs(var.imp$Treat) + abs(var.imp$Y)
	} else {
		var.imp$Total <- abs(var.imp$Treat)
	}
	
	var.imp <- var.imp[-1,] # Remove intercept
	var.imp <- var.imp[order(var.imp$Total, decreasing=TRUE),,drop=FALSE]
	
	if(!missing(index.treated) & !missing(index.control)) {
		if(!missing(exact.covs)) {
			stop('Specifying exact.covs is not supported when also specifying 
				 index.treated and index.control')
		}
		if(length(index.treated) != length(index.control) &
		   length(index.treated) != nrow(df)) {
			stop('length(index.treated) != length(index.control) != nrow(df)')
		}
	} else {
		exact <- list()
		if(!missing(exact.covs)) {
			for(i in exact.covs) {
				if(is.numeric(df[,i]) & length(unique(df[,i])) > n.levels) {
					q <- quantile(df[,i], seq(0, 1, 1/n.strata))
					if(length(unique(q)) != (n.strata+5)) { 
						# breaks would not be unique so we'll treat as a qualitative covariate
						exact[[i]] <- df[,i]
					} else {
						exact[[i]] <- cut(df[,i], q, include.lowest=TRUE, 
										  labels=letters[1:n.strata])
					}
				} else {
					exact[[i]] <- df[,i]
				}
			}
		}
	
		if(length(exact) > 0) {
			match.out <- Matchby(Tr = df[,all.vars(formu)[1]],
								 X  = fitted(lr.out),
								 by = exact, 
								 print.level = 0, ... )
		} else {
			match.out <- Match(Tr = df[,all.vars(formu)[1]],
							   X  = fitted(lr.out),
							   ... )
		}
		
		index.treated <- match.out$index.treated
		index.control <- match.out$index.control
	}
	
	df.matrix <- model.matrix(formu, data=df)
	df.matrix <- df.matrix[,-1] # Remove the intercept
	
	df.cov.bal <- data.frame(row.names=1:length(index.treated))
	for(i in seq_len(ncol(df.matrix))) {
		if(is.factor(df.matrix[,i]) | 
		   is.character(df.matrix[,i]) | 
		   is.logical(df.matrix[,i])) { 
			# This should not occur. Left over from using data.frame
			df.cov.bal[,colnames(df.matrix)[i]] <- 
				df.matrix[index.treated,i] == df.matrix[index.control,i]
		} else if(is.numeric(df.matrix[,i])) {
			diff <- abs(df.matrix[index.treated,i] - df.matrix[index.control,i])
			df.cov.bal[,colnames(df.matrix)[i]] <- diff / sd(df.matrix[,i])
		} else {
			warning(paste0('Unknown column type for ', names(df)[i]))
		}
	}

	col.percents <- apply(df.cov.bal[,1:(ncol(df.cov.bal))] < tolerance, 2, sum) / 
		nrow(df.cov.bal) * 100
	row.percents <- apply(df.cov.bal[,1:(ncol(df.cov.bal))] < tolerance, 1, sum) / 
		ncol(df.cov.bal) * 100

	results <- list(
		df = df,
		df.matrix = df.matrix,
		ps.out = lr.out,
		Y.out = glm.out,
		covariate.matched = col.percents,
		observation.matched = row.percents,
		covariate.balance = df.cov.bal,
		covariate.importance = var.imp,
		index.treated = index.treated,
		index.control = index.control,
		tolerance = tolerance
	)
	
	class(results) <- 'MatchBalance'
	return(results)
}
