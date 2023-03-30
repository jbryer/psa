# See https://www.scto.ch/dam/jcr:3803aee5-506c-4a20-91a9-63b5b772877b/SCTO_Symposium17_10_Senn.pdf
# for inspiration

library(ggplot2)
library(psych)
library(gridExtra)
# devtools::install_github("thomasp85/patchwork")
# library(patchwork)
library(purrr)
library(dplyr)

pop.mean <- 100
pop.sd <- 15
pop.es <- .3

n <- 30

set.seed(123)
thedata <- data.frame(
	id = 1:30,
	center = rnorm(n, mean = pop.mean, sd = pop.sd),
	stringsAsFactors = FALSE
)
val <- pop.sd * pop.es / 2
thedata$placebo <- thedata$center - val
thedata$treatment <- thedata$center + val
thedata$diff <- thedata$treatment - thedata$placebo
thedata$RCT_Assignment <- sample(c('placebo', 'treatment'), n, replace = TRUE)
thedata$RCT_Value <- as.numeric(apply(thedata, 1, 
					FUN = function(x) { return(x[x['RCT_Assignment']]) }))
tab.out <- describeBy(thedata$RCT_Value, group = thedata$RCT_Assignment, mat = TRUE, skew = FALSE)

p1 <- ggplot(thedata) + 
	geom_segment(aes(x = placebo, xend = treatment, y = id, yend = id)) +
	geom_point(aes(x = placebo, y = id), color = 'blue') +
	geom_point(aes(x = treatment, y = id), color = 'red') +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 3 * pop.sd, pop.mean + 3 * pop.sd) +
	ggtitle(paste0('True Counterfactual Difference = ', mean(thedata$diff)))
p2 <- ggplot(thedata, aes(x = RCT_Value, color = RCT_Assignment, y = id)) +
	geom_point() +
	scale_color_manual(values = c('placebo' = 'blue', 'treatment' = 'red')) +
	theme(legend.position = 'none') +
	geom_vline(data = tab.out, aes(xintercept = mean, color = group1)) +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 3 * pop.sd, pop.mean + 3 * pop.sd) +
	ggtitle(paste0('RCT Difference = ', round(diff(tab.out$mean), digits = 2)))
grid.arrange(p1, p2, nrow = 1)

sim.diff <- numeric(1000)
for(i in seq_along(sim.diff)) {
	treats <- sample(c(T,F), n, replace = TRUE)
	sim.diff[i] <- mean(thedata[treats,]$treatment) - mean(thedata[!treats,]$placebo)
}
ggplot(data.frame(x = sim.diff), aes(x = x)) + 
	geom_histogram(alpha = 0.5, bins = 20) +
	geom_vline(xintercept = mean(thedata$diff), color = 'red') +
	geom_vline(xintercept = mean(sim.diff))

################################################################################

set.seed(123)

generateRCTDataFrame <- function(...) {
	group.diff <- pop.sd / 4
	thedata2 <- data.frame(
		id = 1:30,
		# center = rnorm(n, mean = pop.mean, sd = pop.sd),
		stringsAsFactors = FALSE
	)
	thedata2$group <- NA
	rows <- sample(1:nrow(thedata2), nrow(thedata2) / 2)
	thedata2[rows,]$group <- 'A'
	thedata2[-rows,]$group <- 'B'
	thedata2$center <- NA
	thedata2[rows,]$center <- rnorm(length(rows), 
									mean = pop.mean + group.diff,
									sd = pop.sd)
	thedata2[-rows,]$center <- rnorm(length(rows), 
									mean = pop.mean - group.diff,
									sd = pop.sd)
	val <- pop.sd * pop.es / 2
	thedata2$placebo <- thedata2$center - val
	thedata2$treatment <- thedata2$center + val
	thedata2$diff <- thedata2$treatment - thedata2$placebo
	thedata2$RCT_Assignment <- sample(c('placebo', 'treatment'), n, replace = TRUE)
	thedata2$RCT_Value <- as.numeric(apply(thedata2, 1, 
						FUN = function(x) { return(x[x['RCT_Assignment']]) }))
	return(thedata2)
}


tab.out <- describeBy(thedata2$RCT_Value,
					  group = thedata2$RCT_Assignment, mat = TRUE, skew = FALSE)
tab.out$group <- 'both'
tab.out2 <- describeBy(thedata2$RCT_Value, 
					  group = list(thedata2$RCT_Assignment, thedata2$group), 
					  mat = TRUE, skew = FALSE)
names(tab.out2)[3] <- 'group'
# tab.out2 <- rbind(tab.out[,c('group1','group','mean')],
# 				  tab.out2[,c('group1','group','mean')])

ggplot(thedata2, aes(x = center, color = group)) +
	geom_density()

blocked.es <- (tab.out2[2,]$mean - tab.out2[1,]$mean + tab.out2[4,]$mean - tab.out2[3,]$mean) / 2

p1 <- ggplot(thedata2, aes(shape = group)) + 
	geom_segment(aes(x = placebo, xend = treatment, y = id, yend = id)) +
	geom_point(aes(x = placebo, y = id), color = 'blue') +
	geom_point(aes(x = treatment, y = id), color = 'red') +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 4 * pop.sd, pop.mean + 4 * pop.sd) +
	theme(legend.position = 'none') +
	ggtitle(paste0('True Counterfactual Difference = ', mean(thedata$diff), '\n'))
p2 <- ggplot(thedata2, aes(x = RCT_Value, color = RCT_Assignment, y = id, shape = group)) +
	geom_point() +
	scale_color_manual(values = c('placebo' = 'blue', 'treatment' = 'red')) +
	theme(legend.position = 'none') +
	geom_vline(data = tab.out2, aes(xintercept = mean, color = group1, linetype = group)) +
	ylab('') + xlab('Outcome') +
	xlim(pop.mean - 4 * pop.sd, pop.mean + 4 * pop.sd) +
	ggtitle(paste0('RCT Difference = ', round(diff(tab.out$mean), digits = 2),
				   '\n(blocked difference = ', round(blocked.es, digits = 2), ')'))
grid.arrange(p1, p2, nrow = 1)


sim.df <- data.frame(id = 1:5, stringsAsFactors = FALSE)
sim.df$df <- lapply(1:nrow(sim.df), generateRCTDataFrame)

sim.df %>% mutate(df = generateRCTDataFrame)
