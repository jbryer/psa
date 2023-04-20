#' Propensity score weighting plot
#' 
#' @param ps vector of propensity scores.
#' @param treatment vector of treatment indicators.
#' @param outcome vector of outcome values.
#' @param estimand the estimand to use, either ATE, ATT, ATC, or ATM.
#' @param null_hypothesis the value of the null hypothesis (typically zero). A
#'        horizontal line will be drawn to compare with regression line.
#' @param method the method to use for the regression line. Typically loess, gan, or lm.
#' @param se Display confidence interval around smooth? (TRUE by default, see level to control.)
#' @param level Level of confidence interval to use (0.95 by default).
#' @param colors vector of colors to use for control and treatment, respectively.
#' @param point_size_range range of the point sizes. Needs to be a vector of length two.
#' @param xlab label for the x-axis.
#' @param ylab label for the y-axis.
#' @param treat_lab label for the legend of group colors.
#' @param size_lab label for the legend of point sizes.
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
#' weighting_plot(ps = lalonde$ps,
#' 					treatment = lalonde$treat,
#' 					outcome = log(lalonde$re78))
#' }
weighting_plot <- function(ps, treatment, outcome, 
						   estimand = 'ATE',
						   null_hypothesis = 0,
						   method = 'loess',
						   se = TRUE,
						   level = 0.95,
						   colors = c('#fc8d62', '#66c2a5'),
						   point_size_range = c(1, 8),
						   xlab = 'Propensity Score',
						   ylab = 'Outcome',
						   treat_lab = 'Treatment',
						   size_lab = 'PS Weight',
						   plot_points = TRUE) {
	df <- data.frame(ps = ps,
					 treatment = treatment,
					 outcome = outcome)
	df$ps_weights <- psa::calculate_ps_weights(treatment = treatment,
											   ps = ps,
											   estimand = estimand)
	
	p <- ggplot(df, aes(x = ps, y = outcome)) +
		geom_hline(yintercept = null_hypothesis) +
		geom_point(aes(size = ps_weights, color = as.logical(treatment)), alpha = 0.5) +
		geom_smooth(method = method, se = se, level = level,
					formula = y ~ x, aes(weight = ps_weights)) +
		scale_size(size_lab, range = point_size_range) +
		scale_color_manual(treat_lab, values = colors) +
		xlab(xlab) + ylab(ylab)
	return(p)
}
