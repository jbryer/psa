#' Stratify based upon the propensity scores.
#' 
#' @param ps vector containing the propensity scores.
#' @param n_strata number of strata.
#' @param labels labels for the strata.
#' @return a list with two elements:
#' \describe{
#' \item{breaks}{a numeric vector with the breaks returned from [stats::quantile()].}
#' \item{labels}{a data frame with four columns: strata, xmin (lower bound for the stratum), 
#'           xmax (upper bound for the stratum), and xmid (midpoint of the stratum).} 
#' }
#' @importFrom stats quantile
#' @export
get_strata_breaks <- function(ps, 
							  n_strata = 5,
							  labels = LETTERS[1:n_strata]) {
	breaks <- quantile(ps, seq(0, 1, 1 / n_strata))
	df_breaks <- data.frame(
		strata = labels,
		xmin = breaks[1:(length(breaks) - 1)],
		xmax = breaks[2:length(breaks)]
	)
	df_breaks$xmid <- df_breaks$xmin + (df_breaks$xmax - df_breaks$xmin) / 2
	return(list(
		breaks = breaks,
		labels = df_breaks
	))
}
