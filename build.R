
#initGitbook('book'); setwd('..')

# For the book
library(Rgitbook)
buildGitbook('book')
openGitbook()
publishGitbook(repo='jbryer/psa')

# For the R package
library(devtools)
document()
build()
install()
