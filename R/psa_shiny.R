#' Run the PSA shiny application.
#' 
#' @param ... other parameters passed to [shiny::runApp].
#' @export
psa_shiny <- function(...) {
	shiny::runApp(
		appDir = paste0(find.package(package='psa'), '/shiny/psa'),
		...)
}

#' Run the PSA simulation shiny application.
#' 
#' @param ... other parameters passed to [shiny::runApp].
#' @export
psa_simulation_shiny <- function(...) {
	shiny::runApp(
		appDir = paste0(find.package(package='psa'), '/shiny/psa_simulation'),
		...)
}
