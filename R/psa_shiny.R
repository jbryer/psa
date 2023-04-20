#' Run the PSA shiny application.
#' 
#' @export
psa_shiny <- function() {
	shiny::runApp(paste0(find.package(package='psa'), '/shiny/psa'))
}

#' Run the PSA simulation shiny application.
#' 
#' @export
psa_simulation_shiny <- function() {
	shiny::runApp(paste0(find.package(package='psa'), '/shiny/psa_simulation'))
}
