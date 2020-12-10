#' Merge imputed dataset with original data.frame.
#' 
#' Returns a data.frame where the variables in the original (i.e. \code{y} 
#' parameter) are replaced by the imputed variables from mice (i.e. \code{x}
#' parameter).
#' 
#' @param x the results from \code{\link{mice::mice}}.
#' @param y the \code{data.frame} passed to \code{\link{mice::mice}}. This must
#'        have the same number rows, but may contain additional columns.
#' @param shadow.matrix if TRUE, addtional columns will be added indicating 
#'        whether the value was missing in the original data.frame.
#' @param shadow.suffix the suffix used for the shadow matrix.
#' @param ... parameters passed to \code{\link{mice::complete}}.
#' @export
#' @method merge mids
merge.mids <- function(x, y, 
					   shadow.matrix = FALSE, 
					   shadow.suffix = '_missing', 
					   ...) {
	df.mice <- complete(x, ...)
	
	# TODO:  Add shadow matrix parameter
	
	if(!is.data.frame(y)) {
		stop('The y parameter must be a data.frame.')
	}
	if(nrow(df.mice) != nrow(y)) {
		stop('Number of rows in data.frame and imputed dataset do not match.')
	}
	
	df <- cbind(y[,!names(y) %in% names(df.mice)],
				df.mice)

	if(shadow.matrix) {
		shadow <- as.data.frame(is.na(y[,names(y) %in% names(df.mice)]))
		names(shadow) <- paste0(names(shadow), shadow.suffix)
		df <- cbind(df, shadow)
	}
	
	return(df)
}
