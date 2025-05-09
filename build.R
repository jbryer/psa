##### For the R package ########################################################
library(devtools)

source('data-raw/psa_citations.R') # Build the psa_citations data file

usethis::use_tidy_description()
devtools::document()
devtools::install(upgrade = 'never')
devtools::install(upgrade = 'never', build_vignettes = TRUE)
devtools::build()
devtools::build_readme()

devtools::check(cran = TRUE)

# Can run this if there is an error about checking the time
# Sys.setenv('_R_CHECK_SYSTEM_CLOCK_' = 0)

# Install packages
install.packages(c('cowplot', 'dplyr', 'ggplot2', 'grid', 'Matching', 'MatchIt',
    'mice', 'plyr', 'psych', 'remotes', 'reshape2', 'shiny'))
install.packages(c('knitr', 'lubridate', 'mvtnorm', 'party', 'rmarkdown', 'stargazer'))
install.packages(c(#'granovaGG',
				   'bookdown', 'devtools', 'granova', 'GGally',
				   'multilevelPSA',
				   # 'PSAboot',
				   'PSAgraphics', 'rgenoud',
				   'scholar', 'rbounds', 'tree', 'TriMatch', 'badger', 'BART',
				   'randomForest', 'stargazer', 'gdata'))
remotes::install_github('briandk/granovaGG')
remotes::install_github('jbryer/PSAboot')

################################################################################
# For the bookdown site
# library(bookdown)
wd <- setwd('book')
bookdown::render_book(input = "index.Rmd", output_format = "bookdown::bs4_book")
 # bookdown::render_book(input = "index.Rmd", output_format = "bookdown::pdf_book")
setwd(wd)

library(RefManageR)
GetBibEntryWithDOI('10.1093/biomet/70.1.41')


################################################################################
# For the Slides
rmarkdown::render('Slides/Intro_PSA.Rmd')
renderthis::to_pdf('Slides/Intro_PSA.html',
				   complex_slides = TRUE,
				   partial_slides = FALSE)


################################################################################
# Shiny Applications
# library(psa)
psa::psa_simulation_shiny()
psa::psa_shiny()


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
