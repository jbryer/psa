# setwd("~/Dropbox/Projects/psa")

install.packages(c('devtools','ggplot2','reshape2','Matching','MatchIt',
				   'PSAgraphics','granovaGG','party','shiny','cowplot'))
devtools::install_github('rstudio/rsconnect')
devtools::install_github('rstudio/bookdown')

# For the book
library(bookdown)
setwd('book')
bookdown::render_book(input = "index.Rmd", 
					  output_format = "bookdown::gitbook",
					  output_dir = '../docs')

#bookdown::render_book("index.Rmd", "bookdown::pdf_book")

# For the R package
library(devtools)
document()
install(build_vignettes = FALSE)
install(build_vignettes = TRUE)
build()
check()


# Load package and list available functions
library(psa)
ls('package:psa')


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


