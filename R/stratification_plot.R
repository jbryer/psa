#' Stratification Plot
#' 
#' @param ps vector of propensity scores.
#' @param treatment vector of treatment indicators.
#' @param outcome vector of outcome values.
#' @param n_strata number of strata to use.
#' @param colors vector of colors to use for control and treatment, respectively.
#' @param xlab label for the x-axis.
#' @param ylab label for the y-axis.
#' @param treat_lab label for the legend.
#' @param plot_points whether to plot the individual points.
#' @param plot_strata whether to plot the vertical lines for the strata.
#' @param label_strata whether the strata should be labeled (as letters).
#' @return a ggplot2 expression.
#' @export
#' @examples
#' data(lalonde, package = 'Matching')
#' lr_out <- glm(treat~age + I(age^2) + educ + I(educ^2) + black + 
#'               hisp + married + nodegr + re74  + I(re74^2) + re75 + I(re75^2) +
#'               u74 + u75,
#' 			  data = lalonde, 
#' 			  family = binomial(link = 'logit'))
#' lalonde$ps <- fitted(lr_out)
#' stratification_plot(ps = lalonde$ps,
#' 					treatment = lalonde$abcix,
#' 					outcome = log(lalonde$cardbill),
#' 					n_strata = 5)
stratification_plot <- function(ps, treatment, outcome, 
								n_strata = 5,
								colors = c('#fc8d62', '#66c2a5'),
								xlab = 'Propensity Score',
								ylab = 'Outcome',
								treat_lab = 'Treatment',
								plot_points = TRUE,
								plot_strata = TRUE,
								label_strata = TRUE) {
	if(!is.logical(treatment)) {
		treatment <- as.logical(treatment)
	}
	breaks <- psa::get_strata_breaks(ps, n_strata = n_strata)
	strata <- cut(x = ps, 
				  breaks = breaks$breaks, 
				  include.lowest = TRUE, 
				  labels = breaks$labels$strata)
	strata_out <- psych::describeBy(outcome,
									group = list(treatment, strata),
									mat = TRUE, skew = FALSE)
	names(strata_out)[2:3] <- c('treatment', 'strata')
	strata_out$treatment <- as.logical(strata_out$treatment)
	strata_out <- merge(strata_out, breaks$labels, by = 'strata', all = TRUE)
	p <- ggplot() +
		geom_vline(xintercept = breaks$breaks)
	if(plot_points) {
		p <- p + geom_point(data = data.frame(ps = ps, treatment = treatment, outcome = outcome),
							aes(x = ps, y = outcome, color = treatment), alpha = 0.5)
	}
	p <- p + geom_segment(data = strata_out, aes(x = xmin, xend = xmax, y = mean, yend = mean, color = treatment), size = 1)
	if(label_strata) {
		p <- p + geom_text(data = breaks$labels, aes(x = xmid, y = min(outcome), label = strata), color = 'black', vjust = 0.7, size = 4)
	}
	p <- p +
		scale_color_manual(treat_lab, values = colors) +
		xlab(xlab) + ylab(ylab)
	return(p)
}
