## Matching of non-binary treatments

require(TriMatch)
require(psych)

data(tutoring)
str(tutoring)

table(tutoring$treat)
# Histogram of unadjusted grades
tmp <- as.data.frame(prop.table(table(tutoring$treat, tutoring$Grade), 1))
ggplot(tmp, aes(x=Var2, y=Freq, fill=Var1)) + 
	geom_bar(position='dodge', stat='identity') +
	scale_y_continuous(labels = percent_format()) +
	xlab('Grade') + ylab('Percent') + scale_colour_hue('Treatment')

## Phase I

# Note that the dependent variable is not included in the formula. The TriMatch
# functions will replace the dependent variable depending on which pair is
# being modeled.
tutoring.formu <- ~ Gender + Ethnicity + Military + ESL + EdMother + EdFather + 
	Age + Employment + Income + Transfer + GPA

# trips will estimate the propensity scores for each pairing of groups
tutoring.tpsa <- trips(tutoring, tutoring$treat, tutoring.formu)

plot(tutoring.tpsa, sample=c(200))

# trimatch finds matched triplets.
tutoring.matched <- trimatch(tutoring.tpsa)

# Partial exact matching
tutoring.matched2 <- trimatch(tutoring.tpsa, exact=tutoring$Level)

# Plotting the results of trimatch is a subset of the triangle plot with only
# points that were matched. There is also an additional parameter, rows, that
# will overlay matched triplets.
plot(tutoring.matched, rows=1, line.alpha=1, draw.segments=TRUE)

## Examine the unmatched students
unmatched <- unmatched(tutoring.matched)
summary(unmatched)
plot(unmatched)

## Check balance
multibalance.plot(tutoring.tpsa)

balance.plot(tutoring.matched, tutoring$Age, label='Age')
balance.plot(tutoring.matched, tutoring$Military, label='Military')

# Create a grid of figures.
bplots <- balance.plot(tutoring.matched, tutoring[,all.vars(tutoring.formu)], 
					   legend.position='none', 
					   x.axis.labels=c('C','T1','T1'), x.axis.angle=0)
bplots[['Military']] # We can plot one at at time.
summary(bplots) # Create a data frame with the statistical results
plot(bplots, cols=3, byrow=FALSE)

## Phase II
# The summary function performs a number of statistical tests including Friedman
# rank sum test, repeated measures ANOVA, and if one or both of those tests have
# p values less than 0.5 (the default, but configurable), then a pairwise Wilcox
# test and three paired t-tests will also be performed.
(sout <- summary(tutoring.matched, tutoring$Grade))
ls(sout)

boxdiff.plot(tutoring.matched, tutoring$Grade, ordering=c('Treat2','Treat1','Control'))
parallel.plot(tutoring.matched, tutoring$Grade)

# The Loess plot is imperfect with three sets of propensity scores. There is a
# model parameter to specify which model to use. Once we a model is selected
# we have propensity scores for two of the three groups. We impute a propensity
# score on that model's scale for the third group as the midpoint between
# the other two propensity scores that unit was matched to.
loess3.plot(tutoring.matched, tutoring$Grade, se=FALSE, method='loess')
# Turn on 95% confidence interval (see also the level parameter)
loess3.plot(tutoring.matched, tutoring$Grade, se=TRUE, method='loess')
# We can also pass other parameters to the loess function.
loess3.plot(tutoring.matched, tutoring$Grade, se=TRUE, method='loess', span=1)
# This is a busy plot, but since all the lines are practically vertical, the
# distance between each pair of propensity scores is minimal.
loess3.plot(tutoring.matched, tutoring$Grade, se=FALSE, method='loess', 
			plot.connections=TRUE)

# The merge function will add the outcome to the matched triplet data frame.
# This is useful for other approaches to analyzing the matched triplets.
tmatch.out <- merge(tutoring.matched, tutoring$Grade)
head(tmatch.out)
