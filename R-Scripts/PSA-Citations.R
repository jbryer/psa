library(scholar)
library(tidyverse)
library(lubridate)

##### Web of Science
# Search terms: propensity score, propensity score analysis, propensity score matching

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
wos <- wos %>% subset(Year != year(Sys.Date()))

ggplot(wos, aes(x = Year, y = Citations, color = Search_Term)) + 
	geom_path()

##### Google Scholar citations to Rosenbaum and Rubin (1983)

# Paul Rosenbaum: https://scholar.google.com/citations?user=f9ziQskAAAAJ&hl=en&oi=sra
id <- 'f9ziQskAAAAJ'

profile <- get_profile(id)
profile$name

pubs <- get_publications(id) %>%
	subset(journal == 'Biometrika' & year == 1983)
# View(pubs)
article_id <- pubs[1,]$pubid

cites <- get_article_cite_history(id, article_id) %>%
	subset(year != year(Sys.Date()))
names(cites) <- c('Year', 'Citations', 'id')
cites$Search_Term <- 'Rosenbaum & Rubin (1983)'
cites <- cites[,c('Year', 'Citations', 'Search_Term')]

##### Plot the results
citations <- rbind(wos, cites)
ggplot(citations, aes(x = Year, y = Citations, color = Search_Term)) + 
	geom_path() + geom_point() +
	scale_color_brewer('Search Term', palette = 'Set1') +
	ylab('Number of Citations') +
	theme_bw() +
	ggtitle('Number of Citations for Propensity Score Analysis',
			subtitle = 'Source: Web of Science and Google Scholar')

ggplot(citations, aes(x = Year, y = Citations, fill = Search_Term, label = Citations)) + 
	geom_bar(stat = 'identity') +
	geom_text(size = 3, hjust = -0.25) +
	scale_fill_brewer('Search Term', palette = 'Set1') +
	coord_flip() +
	theme_bw() +
	ylim(c(0, 6000)) +
	facet_wrap(~ Search_Term)
