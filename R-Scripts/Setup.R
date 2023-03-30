################################################################################
## Install packages

install.packages(c('devtools','ggplot2','granova','granovaGG','gridExtra',
				   'Matching','MatchIt','party','PSAgraphics','rbounds','rpart'), 
				 repos='http://cran.r-project.org')
# Both the multilevelPSA and TriMatch packages are available on CRAN, but we
# will install the latest versions from Github.
devtools::install_github('multilevelPSA', 'jbryer')
devtools::install_github('TriMatch', 'jbryer')
devtools::install_github('PSAboot', 'jbryer')
# The pisa package is a large (~80MB) data package. It is required to reproduce 
# the full international analysis of private and public schools in the 
# multilevelPSA package. Alternatively, the North American data is included in 
# the multilevelPSA package. See demo(pisa)
# devtools::install_github('pisa', 'jbryer')

