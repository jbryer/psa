utils::globalVariables(c('ps','y'))

#' Loess plot with density distributions for propensity scores and outcomes on
#' top and right, respectively.
#'
#' @param x vector of propensity scores.
#' @param response the response variable.
#' @param treatment the treatment varaible as a logical type.
#' @param percentPoints.treat the percentage of treatment points to randomly plot.
#' @param percentPoints.control the percentage of control points to randomly plot.
#' @param points.treat.alpha the transparency level for treatment points.
#' @param points.control.alpha the transparency level for control points.
#' @param responseTitle the label to use for the y-axis (i.e. the name of the response variable)
#' @param treatmentTitle the label to use for the treatment legend.
#' @param plot.strata an integer value greater than 2 indicating the number of vertical lines to 
#'        plot corresponding to quantiles.
#' @param plot.strata.alpha the alpha level for the vertical lines.
#' @param ... other parameters passed to \code{\link{geom_smooth}} and
#'        \code{\link{stat_smooth}}.
#' @return a ggplot2 figure
#' @seealso plot.mlpsa
#' @export
#' @examples
#' \dontrun{
#' require(multilevelPSA)
#' require(party)
#' data(pisana)
#' data(pisa.psa.cols)
#' cnt = 'USA' #Can change this to USA, MEX, or CAN
#' pisana2 = pisana[pisana$CNT == cnt,]
#' pisana2$treat <- as.integer(pisana2$PUBPRIV) %% 2
#' lr.results <- glm(treat ~ ., data=pisana2[,c('treat',pisa.psa.cols)], family='binomial')
#' st = data.frame(ps=fitted(lr.results), 
#' 				math=apply(pisana2[,paste('PV', 1:5, 'MATH', sep='')], 1, mean), 
#' 				pubpriv=pisana2$treat)
#' 				st$treat = as.logical(st$pubpriv)
#' loess.plot(st$ps, response=st$math, treatment=st$treat, percentPoints.control = 0.4, 
#'            percentPoints.treat=0.4)
#' }
loess.plot <- function(x, response, treatment, 
					   responseTitle='', 
					   treatmentTitle='Treatment',
					   percentPoints.treat=.1, 
					   percentPoints.control=.01, 
					   points.treat.alpha=.1,
					   points.control.alpha=.1,
					   plot.strata,
					   plot.strata.alpha=.2,
					   ...) {
	df = data.frame(ps=x, response=response, treatment=treatment)
	df.points.treat <- df[treatment,]
	df.points.control <-  df[!treatment,]
	df.points.treat <- df.points.treat[sample(nrow(df.points.treat), 
											  nrow(df.points.treat) * percentPoints.treat),]
	df.points.control <- df.points.control[sample(nrow(df.points.control),
											      nrow(df.points.control) * percentPoints.control),]
	pmain = ggplot(df, aes(x=ps, y=response, colour=treatment))
	if(nrow(df.points.control) > 0) {
		pmain = pmain + geom_point(data=df.points.control, 
								   aes(x=ps, y=response, colour=treatment), alpha=points.control.alpha)
	}
	if(nrow(df.points.treat) > 0) {
		pmain = pmain + geom_point(data=df.points.treat, 
								   aes(x=ps, y=response, colour=treatment), alpha=points.treat.alpha)
	}
	pmain = pmain + geom_smooth(...) + ylab(responseTitle) + xlab("Propensity Score") + 
				theme(legend.position='none', legend.justification='left',
					  axis.text.y=element_blank()) + 
				scale_colour_hue(treatmentTitle) + 
				xlim(range(df$ps)) + ylim(range(df$response))
	
	if(!missing(plot.strata)) {
		vlines <- quantile(df$ps, seq(0,1,1/plot.strata), na.rm=TRUE)
		pmain <- pmain + geom_vline(xintercept=vlines, color='black', alpha=plot.strata.alpha)
	}
	
	ptop = ggplot(df, aes(x=ps, colour=treatment, group=treatment)) + 
				geom_density() + 
				theme(legend.position='none', axis.text.y=element_blank()) + 
				xlab(NULL) + ylab('Density') +
				xlim(range(df$ps))
	pright = ggplot(df, aes(x=response, colour=treatment)) + 
				geom_density() + coord_flip() + 
				theme(legend.position='none') + 
				xlab(NULL) + ylab('Density') + xlim(range(df$response))
	tmp = rbind(
		data.frame(treatment=TRUE, y=median(density(df[df$treatment,]$ps)$y), 
				   x=median(density(df[df$treatment,]$response)$y)),
		data.frame(treatment=FALSE, y=median(density(df[!df$treatment,]$ps)$y), 
				   x=median(density(df[!df$treatment,]$response)$y))
	)
	legend <- ggplot(tmp, aes(x=x,y=y,colour=treatment)) + geom_point() + 
		xlim(range(density(df$response)$y)) + 
		ylim(range(density(df$ps)$y)) +
		geom_rect(xmin=min(density(df$response)$y), xmax=max(density(df$response)$y),
				  ymin=min(density(df$ps)$y), ymax=max(density(df$ps)$y), 
				  colour='white', fill='white') +
		theme(legend.position=c(.5,.5), 
			  axis.text.x=element_blank(), axis.text.y=element_blank(),
			  axis.title.x=element_blank(), axis.title.y=element_blank(),
			  axis.ticks=element_blank(),
			  panel.background=element_blank(),
			  panel.grid.major=element_blank(),
			  panel.grid.minor=element_blank(),
			  panel.margin=element_blank()) +
		scale_colour_hue(treatmentTitle)
	grid_layout <- grid.layout(nrow=2, ncol=2, widths=c(3,1), heights=c(1,3))
	grid.newpage()
	pushViewport( viewport( layout=grid_layout ) )
	align.plots(grid_layout, 
								list(ptop, 1, 1), 
								list(pmain, 2, 1), 
								list(pright, 2, 2),
								list(legend, 1, 2))
}
