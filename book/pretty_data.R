#' Creates a markdown list of all the variables in the data.frame.
#' 
#' @param df the data.frame
#' @param digits number of digits to round to.
#' @param big.mark character; if not empty used as mark between every 3 decimals before (hence big) the decimal point.
#' @param max_n_levels maximum number of levels that will be printed.
#' @return a markdown string
pretty_data <- function(df, digits = 2, big.mark = ',', max_n_levels = 10) {
	md <- ''
	for(i in 1:ncol(df)) {
		x <- df[,i,drop=TRUE]
		row <- paste0('* `', names(df)[i], '`: ')
		if(is.logical(x)) {
			tab <- table(x) |> prop.table()
			row <- paste0(row, 'Logical with ',
						  prettyNum(tab['TRUE'] * 100, digits = digits, big.mark = big.mark), '% TRUE and ', 
						  prettyNum(tab['FALSE'] * 100, digits = digits, big.mark = big.mark), '% FALSE')
		} else if(is.integer(x)) {
			row <- paste0(row, 'Integer with mean = ', 
						  prettyNum(mean(x, na.rm = TRUE), digits = digits, big.mark = big.mark), 
						  ' and SD = ', prettyNum(sd(x, na.rm = TRUE), digits = digits, big.mark = big.mark))
		} else if(is.numeric(x)) {
			row <- paste0(row, 'Numeric with mean = ', prettyNum(mean(x, na.rm = TRUE), digits = digits, big.mark = big.mark), 
						  ' and SD = ', prettyNum(sd(x, na.rm = TRUE), digits = digits, big.mark = big.mark))
		} else if(is.character(x)) {
			row <- paste0(row, 'Character with ', prettyNum(length(unique(x)), big.mark = big.mark), ' unique values')
		} else if(is.factor(x)) {
			row <- paste0(row, 'Factor with ', prettyNum(length(levels(x)), big.mark = big.mark), ' levels')
			if(length(unique(x)) < max_n_levels) {
				row <- paste0(row, ': ', paste0(unique(x), collapse = '; '))
			}
		} else {
			row <- paste0(row, class(x))
		}
		if(sum(is.na(x)) > 0) {
			row <- paste0(row, ' (', prettyNum(sum(is.na(x)), big.mark = big.mark), ' missing values)')
		}
		md <- paste0(md, row, '\n')
	}
	return(md)
}

if(FALSE) {
	data(tutoring, package='TriMatch')
	pretty_data(tutoring) |> cat()
	df <- tutoring
	str(df)
}
