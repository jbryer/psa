#' Calculate the balance across covariates for varying stratification sizes.
#' 
#' Cochran (1968) suggested that by stratifying with 2, 3, 4, 5, and 6 strata would reduce bias by 
#' 64%, 79%, 86%, 90%, and 92% respectively. This function, along with the accompanying `summary`
#' and `plot` functions calculates the mean difference between treatment and control groups across
#' all strata for varying number of stratifications. 
#' 
#' @references Cochran, W.G. (1968). The effectiveness of adjustment by subclassification in 
#' removing bias in observational studies. *Biometrics. 24*(2). pp 295-313. 
#' <https://doi.org/10.2307/2528036>
#' @param covariates either a vector (for one covariate) or data.frame.
#' @param treatment vector for the treatment (should be logical or integer).
#' @param ps propensity scores.
#' @param n_strata how many strata to estimate the balance.
#' @param standardize if TRUE, the covariates will be standardized before calculating differences
#'        (i.e. converted to z-scores).
#' @export
#' @rdname stratification_balance
#' @importFrom dplyr rename select mutate
#' @importFrom reshape2 dcast
#' @importFrom psych describeBy
#' @examples
#' # Create a simulated dataset
#' set.seed(2112) 
#' n <- 1000
#' treatment_effect <- 1.5
#' X <- mvtnorm::rmvnorm(n,
#'  					 mean = c(0.5, 1, 0),
#'  					 sigma = matrix(c(2, 1, 1,
#'  					   				  1, 1, 1,
#'  					   				  1, 1, 1), ncol = 3) )
#' dat <- tibble::tibble(
#' 	 x1 = X[, 1],
#' 	 x2 = X[, 2],
#' 	 x3 = X[, 3] > 0,
#' 	 treatment = as.numeric(- 0.5 + 0.25 * x1 + 0.75 * x2 + 0.05 * x3 + rnorm(n, 0, 1) > 0),
#' 	 outcome = treatment_effect * treatment + rnorm(n, 0, 1)
#' )
#' 
#' # Estimate the propensity scores
#' lr_out <- glm(treatment ~ x1 + x2 + x3, data = dat, family = binomial(link = 'logit'))
#' 
#' diff_out <- stratification_balance(
#' 	covariates = dat[,1:3],
#' 	treatment = dat$treatment,
#' 	ps = fitted(lr_out)
#' )
#' 
#' # Note that any place where the mean_difference is NA indicates that one of the groups
#' # did not have any observations. This will occur when the number of stata increase.
#' summary(diff_out) 
#' 
#' cochran_bias_reduction <-  c(.64, .79, .86, .90)
#' plot(diff_out) +
#'  	geom_hline(yintercept = 1 - cochran_bias_reduction, linetype = 2) +
#'  	annotate(geom = 'text', label = paste0(100 * cochran_bias_reduction, '%'), 
#'  			 x = 1, y = 1 - cochran_bias_reduction,
#'  			 vjust = -0.2, hjust = -0.1, size = 3)
#'
stratification_balance <- function(
		covariates,
		treatment,
		ps,
		standardize = TRUE,
		n_strata = 1:10
) {
	if(!is.data.frame(covariates)) {
		covariates <- data.frame(x = covariates)
	}
	covariates <- as.data.frame(covariates) # In case it is a tibble
	if(standardize) {
		for(x in seq_len(ncol(covariates))) {
			covariates[,x] <- (covariates[,x] - mean(covariates[,x])) / sd(covariates[,x])
		}
	}
	diff_tab <- data.frame()
	treatment <- as.integer(treatment)
	for(n in n_strata) {
		for(x in names(covariates)) {
			strata <- cut(ps, quantile(ps, probs = seq(0, 1, 1/n)), 
						  labels = LETTERS[1:n], include.lowest = TRUE)
			tab <- psych::describeBy(covariates[,x,drop=TRUE], 
										   group = list(treatment, strata), 
										   mat = TRUE, skew = FALSE) |>
				dplyr::rename(treatment = group1, strata = group2) |>
				dplyr::select(treatment, strata, mean) |>
				reshape2::dcast(strata ~ treatment, value.var = 'mean') |>
				dplyr::mutate(covariate = x, n_strata = n)
			diff_tab <- rbind(diff_tab, tab)
		}
	}
	diff_tab$diff <- abs(diff_tab[,2] - diff_tab[,3])
	class(diff_tab) <- c('stratification_balance', 'data.frame')
	return(diff_tab)
}

#' @rdname stratification_balance
#' @param object result from [stratification_balance()].
#' @param ... currently not used.
#' @return a data frame with the average difference/balance for each covariate and stratification size.
#' @method summary stratification_balance
#' @importFrom dplyr group_by summarise
summary.stratification_balance <- function(object, ...) {
	object |>
		dplyr::group_by(n_strata, covariate) |>
		dplyr::summarise(mean_difference = mean(diff, na.rm = TRUE), .groups = "drop_last")
}

#' @rdname stratification_balance
#' @param x result from [stratification_balance()].
#' @param ... currently not used.
#' @return a ggplot2 expression.
#' @method plot stratification_balance
#' @import ggplot2
plot.stratification_balance <- function(x, ...) {
	diff_out_sum <- summary(x, ...)
	ggplot(diff_out_sum, aes(x = n_strata, y = mean_difference, color = covariate)) +
		geom_path() +
		geom_point() +
		scale_x_continuous(breaks = unique(diff_out_sum$n_strata)) +
		xlab('Number of strata') + ylab('Mean difference')
}
