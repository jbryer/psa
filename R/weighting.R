#' Calculates propensity score weights.
#' 
#' @param treatment a logical vector for treatment status.
#' @param ps numeric vector of propensity scores
#' @param estimand character string indicating which estimand to be used. Possible
#'        values are 
#'        ATE (average treatment effect), 
#'        ATT (average treatment effect for the treated), 
#'        ATC (average treatement effect for the controls), 
#'        ATM (Average Treatment Effect Among the Evenly Matchable), 
#'        ATO (Average Treatment Effect Among the Overlap Populatio)
#' 
#' @export
calculate_ps_weights <- function(treatment, ps, estimand = 'ATE') {
	weights <- NA
	if(estimand == 'ATE') {
		weights <- (treatment / ps) + ((1 - treatment) / (1 - ps))
	} else if(estimand == 'ATT') {
		weights <- ((ps * treatment) / ps) + ((ps * (1 - treatment)) / (1 - ps))
	} else if(estimand == 'ATC') {
		weights <- (((1 - ps) * treatment) / ps) + (((1 - ps) * (1 - treatment)) / (1 - ps))
	} else if(estimand == 'ATM') {
		weights <- pmin(ps, 1 - ps) / (treatment * ps + (1 - treatment) * (1 - ps))
	} else if(estimand == 'ATO') {
		weights <- (1 - ps) * treatment + ps * (1 - treatment)
	} else {
		stop(paste0('Invalid estimand specified: ', estimand))
	}
	return(weights)
}


#' Estimate the treatment effects.
#' 
#' @param treatment logical vector for treatment status.
#' @param outcome vector of outcome values.
#' @param ps vector of propensity scores.
#' @param weights vector of propensity score weights.
#' @param ... parameters passed [calculate_ps_weights()].
#' @export
treatment_effect <- function(treatment, outcome, ps, weights, ...) {
	if(missing(weights)) {
		if(missing(ps)) {
			stop('Either propensity scores or propensity score weights must be specified.')
		} else {
			weights <- calculate_ps_weights(treatment, ps, ...)
		}
	} else if(!missing(ps)) {
		warning('Both propensity scores and weights have been specified, the
				propensity score weights will be used.')
	}
	
	return( 
		(sum(treatment * outcome * weights) / 
		 	sum(treatment * weights)) + 
			(sum((1 - treatment) * outcome * weights) / 
			 	sum((1 - treatment) * weights))
	)
}
