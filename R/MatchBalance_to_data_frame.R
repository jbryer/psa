#' Converts the results MatchBalance to a data.frame.
#' 
#' 
#' @param mb result from [Matching::MatchBalance()].
#' @return a `data.frame`.
#' @export
#' @importFrom Matching MatchBalance
MatchBalance_to_data_frame <- function(mb) {
	after_match <- mb$AfterMatching
	df <- data.frame(
		'variable' = character(),
		'mean treatment' = numeric(),
		'mean control' = numeric(),
		'std mean diff' = numeric(),
		'mean raw eQQ diff' = numeric(),
		'med  raw eQQ diff' = numeric(),
		'max  raw eQQ diff' = numeric(),
		'mean eCDF diff' = numeric(),
		'med  eCDF diff' = numeric(),
		'max  eCDF diff' = numeric(),
		'var ratio (Tr/Co)' = numeric(),
		'T-test p-value' = numeric(),
		'KS Bootstrap p-value' = numeric(),
		'KS Naive p-value' = numeric(),
		'KS Statistic' = numeric()
	)
	for(i in seq_len(length(after_match))) {
		object <- after_match[[i]]
		if (!inherits(object, "balanceUV")) {
			warning("Object not of class 'balanceUV'")
			return(NULL)
		}
		df <- rbind(df, data.frame(
			'variable' = character(),
			'mean treatment' = object$mean.Tr,
			'mean control' = object$mean.Co,
			'std mean diff' = object$sdiff,
			'mean raw eQQ diff' = object$qqsummary.raw$meandiff,
			'med  raw eQQ diff' = object$qqsummary.raw$mediandiff,
			'max  raw eQQ diff' = object$qqsummary.raw$maxdiff,
			'mean eCDF diff' = object$qqsummary$meandiff,
			'med  eCDF diff' = object$qqsummary$mediandiff,
			'max  eCDF diff' = object$qqsummary$maxdiff,
			'var ratio (Tr/Co)' = object$var.ratio,
			'T-test p-value' = object$tt$p.value,
			'KS Bootstrap p-value' = ifelse(!is.null(object$ks) & !is.na(object$ks$ks.boot.pvalue),
											object$ks$ks.boot.pvalue, NA),
			'KS Naive p-value' = ifelse(!is.null(object$ks), object$ks$ks$p.value, NA),
			'KS Statistic' = ifelse(!is.null(object$ks), object$ks$ks$statistic, NA)
		))
	}
	return(df)
}
