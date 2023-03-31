install.packages(c('devtools','tidyverse',
				   'Matching','MatchIt','PSAgraphics','granovaGG','PSAboot',
				   'party','shiny','cowplot'))
remotes::install_github('rstudio/rsconnect')
remotes::install_github('rstudio/bookdown')

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
# Load package and list available functions
# For the book
library(bookdown)
setwd('book')
bookdown::render_book(input = "index.Rmd", 
					  output_format = "bookdown::gitbook",
					  output_dir = '../docs')

#bookdown::render_book("index.Rmd", "bookdown::pdf_book")


library(psa)
ls('package:psa')
data(package = 'psa')

# Shiny App from installed package
psa::psa_shiny()


# Need to install from Github before deploying to shinyapps.io
devtools::install_github('jbryer/psa')


# Deploy to shinyapps.io (http://shiny.rstudio.com/articles/shinyapps.html)
library(rsconnect)
source('config.R') # R script contains secret and token
shinyapps::setAccountInfo(name='jbryer',
						  token=shinyapps.token,
						  secret=shinyapps.secret)
shinyapps::deployApp(appName='psashiny', appDir=paste0(getwd(), '/inst/shiny/psa'))


# Vignettes
browseVignettes(package='psa')
vignette('MatchBalance', package='psa')




#initGitbook('book'); setwd('..')

# For the book
library(Rgitbook)
buildGitbook('book')
openGitbook()
publishGitbook(repo='jbryer/psa')


