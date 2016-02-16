utils::globalVariables(c('grid.layout','grid.newpage','pushViewport','viewport',
						 'align.plots','index','covariate','value','percent',
						 'std.estimate','Covariate','p.value','ci.min','ci.max'))

#' Applied Propensity Score Analysis with R
#' 
#' @name psa-package
#' @docType package
#' @title Applied Propensity Score Analysis with R
#' @author \email{jason@@bryer.org}
#' @keywords package psa matching propensity score analysis
#' @import ggplot2
#' @import reshape2
#' @import Matching
#' @import MatchIt
#' @import PSAgraphics
#' @import granovaGG
#' @import party
#' @import shiny
#' @importFrom cowplot plot_grid
NA

#' Student data file.
#' 
#' @name students
#' @docType data
#' @format a data frame with 374 ovservations of 17 variables.
#' @keywords datasets
NA

#' Data from a study examining the effects of tutoring on English grades.
#' 
#' @name tutoring
#' @docType data
#' @format a data frame with 1,381 observations of 17 variables.
#' @keywords datasets
NA

#' Number of articles related to propensity score analysis in the Web of Science
#' database.
#' 
#' @name wos
#' @docType data
#' @format a data frame with 20 observations of 2 variables.
#' @keywords datasets
NA


.onAttach <- function(libname, pkgname) {
}
