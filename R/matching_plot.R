utils::globalVariables(c('treat_ps', 'control_ps', 'treat_outcome', 'control_outcome', 'ps_weights'))

#' Propensity score matching plot
#' 
#' @param ps vector of propensity scores.
#' @param treatment vector of treatment indicators.
#' @param outcome vector of outcome values.
#' @param index_treated the positions of treated matched pairs.
#' @param index_control the positions of control matched pairs.
#' @param percent_matches the percentage of matches to plot. Set to one to connect all matches.
#' @param null_hypothesis the value of the null hypothesis (typically zero). A
#'        horizontal line will be drawn to compare with regression line.
#' @param method the method to use for the regression line. Typically loess, gan, or lm.
#' @param se Display confidence interval around smooth? (TRUE by default, see level to control.)
#' @param level Level of confidence interval to use (0.95 by default).
#' @param colors vector of colors to use for control and treatment, respectively.
#' @param xlab label for the x-axis.
#' @param ylab label for the y-axis.
#' @param treat_lab label for the legend of group colors.
#' @param plot_points whether to plot the individual points.
#' @return a ggplot2 expression.
#' @export
#' @examples
#' if(require(Matching)) {
#' data(lalonde, package = 'Matching')
#' lr_out <- glm(treat ~ age + I(age^2) + educ + I(educ^2) + black + 
#'               hisp + married + nodegr + re74  + I(re74^2) + re75 + I(re75^2) +
#'               u74 + u75,
#' 			  data = lalonde, 
#' 			  family = binomial(link = 'logit'))
#' lalonde$ps <- fitted(lr_out)
#' match_out <- Matching::Match(Y = lalonde$re78,
#' 							 Tr = lalonde$treat,
#' 							 X = lalonde$ps,
#' 							 caliper = 0.1,
#' 							 replace = FALSE,
#' 							 estimand = 'ATE')
#' matching_plot(ps = lalonde$ps,
#' 			  treatment = lalonde$treat,
#' 			  outcome = log(lalonde$re78 + 1),
#' 			  index_treated = match_out$index.treated,
#' 			  index_control = match_out$index.control)
#' }
matching_plot <- function(ps, treatment, outcome, 
						  index_treated, index_control,
						  null_hypothesis = 0,
						  method = 'loess',
						  se = TRUE,
						  level = 0.95,
						  percent_matches = 1,
						  colors = c('#fc8d62', '#66c2a5'),
						  xlab = 'Propensity Score',
						  ylab = 'Outcome',
						  treat_lab = 'Treatment',
						  plot_points = TRUE) {
	if(length(index_treated) != length(index_control)) {
		stop('The lenght of index_treated and index_control must be the same.')
	}
	
	df <- data.frame(ps = ps,
					 treatment = as.logical(treatment),
					 outcome = outcome)
	df_match <- data.frame(treat_ps = ps[index_treated],
						   treat_outcome = outcome[index_treated],
						   control_ps = ps[index_control],
						   control_outcome = outcome[index_control])
	df_match$ps <- df_match$control_ps + (df_match$treat_ps - df_match$control_ps) / 2
	df_match$diff <- df_match$treat_outcome - df_match$control_outcome
	
	p <- ggplot()
	if(plot_points) {
		p <- p + geom_point(data = df, aes(x = ps, y = outcome, color = treatment), alpha = 0.5)
	}
	if(percent_matches > 0) {
		p <- p +
			geom_segment(data = df_match[sample(nrow(df_match), round(percent_matches * nrow(df_match))),],
						 aes(x = treat_ps,
						 	 xend = control_ps,
						 	 y = treat_outcome,
						 	 yend = control_outcome,
						 	 color = treat_outcome > control_outcome),
						 alpha = 0.5)
	}
	
	p <- p + geom_hline(yintercept = null_hypothesis)
	p <- p + geom_smooth(data = df_match, aes(x = ps, y = diff), 
					method = method, se = se, level = level, formula = y ~ x)
	p <- p +
		scale_color_manual(treat_lab, values = colors) +
		xlab(xlab) + ylab(ylab)
	return(p)
}
