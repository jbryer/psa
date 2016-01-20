#' Calculates balance statistics for matching.
#' 
#' @param df data frame with data to match.
#' @param formu the formula used to estimate propensity scores using logistic 
#'        regression.
#' @param formu.Y (optional) the formula used to estimate a multiple regression model with
#'        covariates. Used to estimate covariate importance.
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
#'                 of observatins with "perfect" match for each covariate.}
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
MatchBalance <- function(df, formu, formu.Y, exact.covs, tolerance = 0.25,
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

#' Print method for MatchBalance.
#' 
#' @method print MatchBalance
#' @export
print.MatchBalance <- function(x, ...) {
	
}

#' Summary method for MatchBalance.
#' 
#' @method summary MatchBalance
#' @export
summary.MatchBalance <- function(object, print=TRUE, ...) {
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

#' Plot method for MatchBalance.
#' 
#' @param x results of \code{\link{MatchBalance}}.
#' @param min.label.gap the minimum gap between x-axis labels on the top panel.
#' @return Returns a list invisibly with ggplot2 objects of the three panels.
#' @method plot MatchBalance
#' @export
plot.MatchBalance <- function(x, min.label.gap=0.05, 
							  importance=TRUE,
							  importance.sep=ifelse(ncol(x$df.matrix) > 10, ' ', '\n'), 
							  ...) {
	col.percents <- x$covariate.matched
	row.percents <- x$observation.matched
	df.cov.bal <- x$covariate.balance
	var.imp <- x$covariate.importance
	lr.out <- x$ps.out
	index.treated <- x$index.treated
	index.control <- x$index.control

	df.cov.bal$index <- as.character(1:nrow(df.cov.bal))
	df.cov.bal$ps <- fitted(lr.out)[index.treated]
	df.cov.bal.melted <- reshape2::melt(df.cov.bal, 
										id.vars=c('index','ps'), 
										variable.name='covariate')
	df.cov.bal.melted$covariate <- as.character(df.cov.bal.melted$covariate)

	df.tmp <- df.cov.bal.melted[!duplicated(df.cov.bal.melted$index),]
	df.tmp <- df.tmp[order(df.tmp$ps),]
	df.tmp$label <- ''
	df.tmp[fivenum(1:nrow(df.tmp)),]$label <- prettyNum(df.tmp[fivenum(1:nrow(df.tmp)),]$ps, 
														digits=2)
	tmp.labels <- prettyNum(df.tmp[fivenum(1:nrow(df.tmp)),]$ps, digits=2)
	names(tmp.labels) <- df.tmp[fivenum(1:nrow(df.tmp)),]$index

	df.row.percents <- data.frame(index=names(row.percents), percent=row.percents)
	df.row.percents <- df.row.percents[order(df.row.percents$percent),]
	df.row.percents$CumPercent <- 1:nrow(df.row.percents) / nrow(df.row.percents) * 100
	
	label.pos.cum <- which(!duplicated(round(df.row.percents$percent), fromLast=TRUE))
	
	label.pos <- unique(round(
		which(!duplicated(round(df.row.percents$percent))) + 
			( which(!duplicated(round(df.row.percents$percent), fromLast=TRUE)) - 
			  	which(!duplicated(round(df.row.percents$percent), fromLast=FALSE)) ) / 2))
	
	df.row.percents$CumPercentLabel <- paste0(prettyNum(
		df.row.percents$CumPercent, digits=1), '%')
	df.row.percents[-label.pos.cum,]$CumPercentLabel <- ''
	df.row.percents$index <- as.character(df.row.percents$index)
	
	# Remove overlapping labels
	for(i in length(label.pos.cum):2) {
		# If two label points are within 10% of each other, the smaller of the
		# two will be removed.
		if((label.pos.cum[i] - label.pos.cum[i-1]) < (nrow(df.row.percents) * min.label.gap)) {
			df.row.percents[label.pos.cum[i],]$CumPercentLabel <- ''
		}
	}
	
	tolerance <- x$tolerance
	tolerance.max <- min(4 * tolerance, max(df.cov.bal.melted$value))
	
	sum.out <- summary(x, print=FALSE)
	n.sum <- sum.out$n.summary
	sum <- sum.out$balance
	sum$Covariate <- row.names(sum)
	range <- max(c(abs(sum$ci.min), abs(sum$ci.max)))
	
	xlab <- paste0('Matched Pairs (n = ', prettyNum(n.sum[3,'n'], big.mark=','), '; ',
				   'n matched = ', prettyNum(n.sum[3,'n.matched'], big.mark=','), '; ',
				   round(n.sum[1, 'n.percent.matched'] * 100), '% of treated; ',
				   round(n.sum[2, 'n.percent.matched'] * 100), '% of control)')
	
	x.limits <- rev(row.names(var.imp))
	if(importance) {
		x.labels <- rev(paste0(row.names(var.imp), importance.sep, '(Import = ',
							   prettyNum(var.imp$Treat, digits=2), 
							   ifelse(is.null(var.imp$Y), '', paste0(', ',
							   							prettyNum(var.imp$Y, digits=2))), 
							   ')') )
	} else {
		x.labels <- rev(row.names(var.imp))
	}
	
	pmain <- ggplot(df.cov.bal.melted, aes(x=index, y=covariate, fill=value)) + 
		geom_tile() +
		scale_fill_gradientn(colors=c('white','white','white','maroon', 'maroon'),
							 values=c(0, tolerance, tolerance, tolerance.max, tolerance.max,
							 		 max(df.cov.bal.melted$value)),
							 rescaler = function(x,...) x,
							 oob      = identity) +
		theme(legend.position="none", axis.text.x=element_blank(),
			  axis.ticks.x=element_blank(),
			  axis.text.y=element_blank(), 
			  axis.ticks.y=element_blank(),
			  axis.title=element_text(size=10)) + 
		ylab('') + xlab('') +
		scale_x_discrete(limits=df.row.percents$index,
						 labels=df.row.percents$CumPercentLabel) +
		scale_y_discrete(limits=x.limits,
						 labels=x.labels )

	ptop <- ggplot(df.row.percents, aes(x=index, y=100-percent)) +
		geom_bar(stat='identity', position='dodge', color='maroon', fill='maroon') +
		geom_hline(yintercept=seq(0, 100, 25), color='grey50', alpha=0.5) +
		geom_vline(xintercept=label.pos.cum, color='grey50', alpha=0.5) +
		scale_x_discrete(limits=df.row.percents$index, #names(row.percents)[order(row.percents)],
						 labels=df.row.percents$CumPercentLabel) +
		xlab(xlab) + ylab('Covariate') + ylim(c(0,100)) +
		geom_text(data=df.row.percents[label.pos,],
				  aes(label=paste0(round(100-percent), '%')), size=3, vjust=-0.1) +
		theme(axis.ticks.x=element_blank(), 
			  axis.text.x=element_text(size=8),
			  panel.grid=element_blank(), 
			  axis.text.y=element_blank(), 
			  axis.ticks.y=element_blank(),
			  axis.title=element_text(size=10))

	pright <- ggplot(data.frame(index=names(col.percents), percent=col.percents), 
					 aes(x=index, y=100-percent)) +
		geom_bar(stat='identity', color='maroon', fill='maroon') +
		geom_hline(yintercept=seq(0, 100, 25), color='grey50', alpha=0.5) +
		geom_text(aes(label=paste0(round(100-percent), '%')), hjust=-0.2, size=3) +
		scale_x_discrete(limits=x.limits,
						 labels=x.labels ) +
		ylab('') + xlab('') + ylim(c(0,100)) +
		theme(axis.ticks.x=element_blank(), 
			  axis.text.y=element_text(size=8),
			  panel.grid=element_blank(),
			  axis.text.y=element_text(hjust=0),
			  axis.text.x=element_blank(),
			  axis.title=element_text(size=10)) +
		coord_flip()

	peffects <- ggplot(sum, aes(x=std.estimate, y=Covariate, color=p.value > 0.05)) + 
		geom_vline(xintercept=0, color='grey20') + 
		geom_errorbarh(aes(xmin=ci.min, xmax=ci.max), color='green') +
		geom_point() +
		xlim(c(-range, range)) + ylab('') + xlab('Standardized Estimate') +
		scale_y_discrete(limits=rev(row.names(var.imp))) +
		scale_color_manual(values=c('FALSE'='maroon','TRUE'='black'), drop=FALSE) +
		theme(legend.position='top',
			  #axis.ticks.x=element_blank(), 
			  axis.text.y=element_text(size=8),
			  panel.grid=element_blank(),
			  axis.text.y=element_text(hjust=0),
			  axis.text.x=element_text(size=10),
			  axis.title=element_text(size=10),
			  title=element_text(size=8),
			  legend.text=element_text(size=8),
			  plot.background=element_rect(fill='grey97'))
	
	p <- cowplot::plot_grid(
					   ptop + ylab('% Unmatched'), 
					   peffects,
					   pmain,
					   pright + ylab('% Unmatched'), 
					   # peffects + theme(legend.position='none', 
					   # 				 axis.text.y=element_blank(), 
					   # 				 axis.text.x=element_text(size=10)) + xlab(''), 
					   rel_widths=c(5,2), rel_heights=c(3,5), ncol=2, nrow=2)
	print(p)
	
	invisible(list(main=pmain, top=ptop, right=pright, ttests=peffects))
}
