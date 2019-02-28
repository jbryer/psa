#' Plot method for MatchBalance.
#' 
#' @param x results of \code{\link{MatchBalance}}.
#' @param min.label.gap the minimum gap between x-axis labels on the top panel.
#' @param importance include importance metric (t-statistic) in axis labels.
#' @param importance.sep a character used to separate the covariate label and importance metric.
#' @param ... currently unused.
#' @return Returns a list invisibly with ggplot2 objects of the three panels.
#' @method plot MatchBalance
#' @export
plot.MatchBalance <- function(x, 
							  min.label.gap = 0.05, 
							  importance = TRUE,
							  importance.sep = ifelse(ncol(x$df.matrix) > 10, ' ', '\n'), 
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
	
	pmain <- ggplot(df.cov.bal.melted, aes(x = index, y = covariate, fill = value)) + 
		geom_tile() +
		scale_fill_gradientn(colors = c('white','white','white','maroon', 'maroon'),
							 values = c(0, tolerance, tolerance, tolerance.max, tolerance.max,
							 		    max(df.cov.bal.melted$value)),
							 rescaler = function(x,...) x
							 # oob      = identity
							 ) +
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
			  plot.background=element_rect(fill='white'),
			  panel.background=element_rect(fill='white'),
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
			  axis.text.y=element_text(size=8, hjust=0.5),
			  panel.grid=element_blank(), 
			  plot.background=element_rect(fill='white'),
			  panel.background=element_rect(fill='white'),
#			  axis.text.y=element_text(hjust=0),
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
			  # axis.text.y=element_text(hjust=0),
			  axis.text.x=element_text(size=10),
			  axis.title=element_text(size=10),
			  title=element_text(size=8),
			  legend.text=element_text(size=8),
			  panel.background=element_rect(fill='white'),
			  plot.background=element_rect(fill='grey97'),
			  legend.background=element_rect(fill='grey97'))
	
	p <- cowplot::plot_grid(
		ptop + ylab('% Unmatched'), 
		peffects,
		pmain,
		pright + ylab('% Unmatched'), 
		rel_widths=c(5,2), rel_heights=c(3,5), ncol=2, nrow=2)
	print(p)
	
	invisible(list(main=pmain, top=ptop, right=pright, ttests=peffects))
}
