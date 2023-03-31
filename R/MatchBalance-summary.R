#' Summary method for MatchBalance.
#' 
#' 
#' 
#' @param object result from \code{\link{MatchBalance}}
#' @param print whether to print the result or to return using \code{invisible}.
#' @param ... currently unused.
#' @method summary MatchBalance
#' @return a list with two elements: `n.summary` and `balance`.
#' @export
summary.MatchBalance <- function(object, print = TRUE, ...) {
	treat.var <- all.vars(object$ps.out$formula)[1]
	covs <- colnames(object$df.matrix)
	
	n.treated <- nrow(object$df[object$df[,treat.var] == 1,])
	n.control <- nrow(object$df[object$df[,treat.var] == 0,])
	n.total <- n.treated + n.control
	n.treated.match <- length(unique(object$index.treated))
	n.control.match <- length(unique(object$index.control))
	n.total.match <- n.treated.match + n.control.match
	
	n.summary <- data.frame(
		Group = c('Treated', 'Control', 'Total'),
		n = c(n.treated, n.control, n.total),
		n.matched = c(n.treated.match, n.control.match, n.total.match),
		n.percent.matched = c(n.treated.match / n.treated,
							  n.control.match / n.control,
							  n.total.match/ n.total)
	)
	
	cov.bal <- data.frame(row.names=covs,
						  std.estimate=rep(as.numeric(NA), length(covs)),
						  t=rep(as.numeric(NA), length(covs)),
						  p.value=rep(as.numeric(NA), length(covs)),
						  ci.min=rep(as.numeric(NA), length(covs)),
						  ci.max=rep(as.numeric(NA), length(covs)),
						  stringsAsFactors=FALSE)
	
	for(i in covs) {
		t.out <- t.test(x=object$df.matrix[object$index.treated,i],
						y=object$df.matrix[object$index.control,i],
						paired=TRUE)
		if(!is.nan(t.out$statistic)) {
			cov.bal[i,] <- c(t.out$estimate / sd(object$df.matrix[,i]), 
							 t.out$statistic, t.out$p.value,
							 t.out$conf.int[1] / sd(object$df.matrix[,i]), 
							 t.out$conf.int[2] / sd(object$df.matrix[,i]))
		} else {
			cov.bal[i,] <- c(0, NA, 1, 0, 0)
		}
	}
	cov.bal$PercentMatched <- object$covariate.matched[row.names(cov.bal)]
	cov.bal <- cbind(abs(object$covariate.importance)[row.names(cov.bal),], 
					 cov.bal[row.names(cov.bal),])
	names(cov.bal)[1:ncol(object$covariate.importance)] <- paste0(
		'Import.', names(object$covariate.importance) )
	
	cov.bal <- cov.bal[order(cov.bal$Import.Total, decreasing=TRUE),]
	
	if(print) {
		cat('Sample sizes and number of matches:\n')
		print(n.summary, row.names=FALSE)
		
		cat('\nCovariate importance and t-tests for matched pairs:\n')
		print(cov.bal, digits=3)
	}
	
	invisible(list(
		n.summary = n.summary,
		balance = cov.bal
	))
}
