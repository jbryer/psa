##### For the R package ########################################################
library(devtools)

source('data-raw/psa_citations.R') # Build the psa_citations data file

usethis::use_tidy_description()
devtools::document()
devtools::build_readme()
devtools::install(upgrade = 'never')
devtools::install(upgrade = 'never', build_vignettes = TRUE)
devtools::build_readme()
devtools::build()

devtools::check(cran = TRUE)

# Can run this if there is an error about checking the time
# Sys.setenv('_R_CHECK_SYSTEM_CLOCK_' = 0)

################################################################################
# For the bookdown site
# library(bookdown)
wd <- setwd('book')
bookdown::render_book(input = "index.Rmd", 
					  output_dir = '../docs')
setwd(wd)

library(RefManageR)
GetBibEntryWithDOI('10.1093/biomet/70.1.41')

################################################################################
# Basic package functions
library(psa)
ls('package:psa').    # List functions
data(package = 'psa') # List datasets

# Shiny App from installed package
psa::psa_shiny()

# Vignettes
browseVignettes(package='psa')
vignette('MatchBalance', package = 'psa')
vignette('Missingness', package = 'psa')
