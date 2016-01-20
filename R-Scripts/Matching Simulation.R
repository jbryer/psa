library(ggplot2)
library(Matching)

set.seet(2112)

n <- 20
jitter.factor <- 125

x <- runif(n)
y <- runif(n)

df <- data.frame(treat = c(rep(TRUE, n), rep(FALSE, n)),
				 id = c(1:n, 1:n),
				 x = c(x, jitter(x, factor=jitter.factor)),
				 y = c(y, jitter(y, factor=jitter.factor)),
				 stringsAsFactors = FALSE)

ggplot(df, aes(x=x, y=y, color=treat)) + geom_point() +
	geom_line(aes(group=id), color='black')

lr.out <- glm(treat ~ x + y, data=df, family=binomial())
summary(lr.out)

df$ps <- fitted(lr.out)

match.out <- Match(Tr=df$treat, X=df$ps, Weight=1)

df$match.group <- -1
df[match.out$index.treated,]$match.group <- 1:length(match.out$index.treated)
df[match.out$index.control,]$match.group <- 1:length(match.out$index.treated)

ggplot(df, aes(x=x, y=y, color=treat)) + geom_point() +
	geom_line(aes(group=id), color='grey90') + 
	geom_line(aes(group=match.group), color='blue', linetype=2)

ggplot(df, aes(x=ps, y=x, color=treat)) + geom_point()
ggplot(df, aes(x=ps, y=y, color=treat)) + geom_point()

