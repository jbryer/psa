library(lubridate)
library(dplyr)
library(scholar)

# 1. Go to the Web of Science: https://www-webofscience-com.libproxy.albany.edu/wos/woscc/basic-search
# 2. Enter the search term and click "Search" button.
# 3. Click "Analyze Results" button.
# 4. Change the category to "Publication Years".
# 5. Click the "Download data table" button at the bottom of the page.
# Search terms:
# * "propensity score"
# * "propensity score analysis"
# * "propensity score matching"

wos.ps <- read.table('data-raw/wos-propensity_score.txt', 
					 header = TRUE, sep = '\t')
wos.psa <- read.table('data-raw/wos-propensity_score_analysis.txt',
					  header = TRUE, sep = '\t')
wos.psm <- read.table('data-raw/wos-propensity_score_matching.txt',
					  header = TRUE, sep = '\t')
names(wos.ps) <- names(wos.psa) <- names(wos.psm) <- c('Year', 'Citations', 'Percent')
wos.ps$Search_Term <- 'propensity score'
wos.psa$Search_Term <- 'propensity score analysis'
wos.psm$Search_Term <- 'propensity score matching'
wos <- rbind(wos.ps, wos.psa, wos.psm)
wos <- wos[,c('Year', 'Citations', 'Search_Term')]
wos <- wos |> subset(Year != year(Sys.Date()))

# Paul Rosenbaum: https://scholar.google.com/citations?user=f9ziQskAAAAJ&hl=en&oi=sra
id <- 'f9ziQskAAAAJ'

profile <- get_profile(id)
profile$name

pubs <- get_publications(id) |>	subset(journal == 'Biometrika' & year == 1983)
# View(pubs)
article_id <- pubs[1,]$pubid

cites <- get_article_cite_history(id, article_id) |>
	subset(year != year(Sys.Date()))
names(cites) <- c('Year', 'Citations', 'id')
cites$Search_Term <- 'Rosenbaum & Rubin (1983)'
cites <- cites[,c('Year', 'Citations', 'Search_Term')]

wos$Source <- 'Web of Science'
cites$Source <- 'Google Scholar'

psa_citations <- rbind(wos, cites)

save(psa_citations, file = 'data/psa_citations.rda')
