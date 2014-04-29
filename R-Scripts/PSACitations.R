require(gdata)
require(ggplot2)

psm <- read.xls('Data/WebOfScienceResults.xlsx', sheet=1)
psa <- read.xls('Data/WebOfScienceResults.xlsx', sheet=2)
ps <- read.xls('Data/WebOfScienceResults.xlsx', sheet=3)

psm$Term <- 'Propensity Score Matching'
psa$Term <- 'Propensity Score Analysis'
ps$Term <- 'Propensity Score'

df <- rbind(psm, psa, ps)

# df.label <- df[df$Year %in% seq(max(df$Year), min(df$Year), by=-5) &
# 			   df$Term == 'Propensity Score',]
# df.label <- df[df$Term == 'Propensity Score',]
df.label <- df[df$Year == max(df$Year),]
df.label$y <- df.label$Articles
df.label[1,]$y <- df.label[1,]$y + 30
df.label[2,]$y <- df.label[2,]$y - 30

ggplot(df, aes(x=Year, y=Articles, group=Term, color=Term)) + 
	geom_path() + 
	geom_text(data=df.label, aes(label=Articles, y=y), hjust=-0.1, show_guide=FALSE) +
	#geom_text(data=df.label, aes(label=Articles), show_guide=FALSE, vjust=-.1) +
	scale_color_hue('Search Term') +
	ylab("Number of Publications") + xlab("Publication Year") +
	ggtitle('Number of PSA Publications by Year\n(source: Web of Science)') +
	theme(legend.position="bottom") + 
	scale_x_continuous(breaks=seq(min(df$Year), max(df$Year), by=1))
