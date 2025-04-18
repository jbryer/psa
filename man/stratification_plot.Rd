% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stratification_plot.R
\name{stratification_plot}
\alias{stratification_plot}
\title{Stratification Plot}
\usage{
stratification_plot(
  ps,
  treatment,
  outcome,
  n_strata = 5,
  level = 0.68,
  colors = c("#fc8d62", "#66c2a5"),
  se_color = "grey80",
  xlab = "Propensity Score",
  ylab = "Outcome",
  treat_lab = "Treatment",
  plot_points = TRUE,
  plot_strata = TRUE,
  label_strata = TRUE
)
}
\arguments{
\item{ps}{vector of propensity scores.}

\item{treatment}{vector of treatment indicators.}

\item{outcome}{vector of outcome values.}

\item{n_strata}{number of strata to use.}

\item{level}{Level of confidence interval to use. Set to NULL to exclude.
The default is 0.68 (for 1
standard error) since the primary purpose is to compare overlap between
the two lines. See this article for more details:
https://towardsdatascience.com/why-overlapping-confidence-intervals-mean-nothing-about-statistical-significance-48360559900a}

\item{colors}{vector of colors to use for control and treatment, respectively.}

\item{se_color}{color for the standard error bars.}

\item{xlab}{label for the x-axis.}

\item{ylab}{label for the y-axis.}

\item{treat_lab}{label for the legend.}

\item{plot_points}{whether to plot the individual points.}

\item{plot_strata}{whether to plot the vertical lines for the strata.}

\item{label_strata}{whether the strata should be labeled (as letters).}
}
\value{
a ggplot2 expression.
}
\description{
Stratification Plot
}
\examples{
if(require(Matching)) {
data(lalonde, package = 'Matching')
lr_out <- glm(treat ~ age + I(age^2) + educ + I(educ^2) + black + 
              hisp + married + nodegr + re74  + I(re74^2) + re75 + I(re75^2) +
              u74 + u75,
			  data = lalonde, 
			  family = binomial(link = 'logit'))
lalonde$ps <- fitted(lr_out)
stratification_plot(ps = lalonde$ps,
					treatment = lalonde$treat,
					outcome = log(lalonde$re78 + 1),
					n_strata = 5)
}
}
