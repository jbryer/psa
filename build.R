options( repos=c(CRAN='http://cran.r-project.org') )
options( stringsAsFactors=FALSE )
options( width=110 )
require(Rgitbook)
require(ggplot2)
theme_update(panel.background=element_rect(size=1, color='grey70', fill=NA) )

#initGitbook('book'); setwd('..')

buildGitbook('book')
openGitbook()
publishGitbook(repo='jbryer/psa')
