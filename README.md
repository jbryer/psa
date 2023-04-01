
# <img src="man/figures/psa.png" align="right" width="120" align="right" /> Propensity Score Analysis with R

<!-- badges: start -->

[![R-CMD-check](https://github.com/jbryer/psa/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/jbryer/psa/actions/workflows/R-CMD-check.yaml)
[![Bookdown
Status](https://github.com/jbryer/psa/actions/workflows/bookdown.yaml/badge.svg)](https://github.com/jbryer/psa/actions/workflows/bookdown.yaml)
[![](https://img.shields.io/badge/devel%20version-0.1.0-blue.svg)](https://github.com/jbryer/psa)
[![Project Status: WIP - Initial development is in progress, but there
has not yet been a stable, usable release suitable for the
public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

Contact: [Jason Bryer](https://www.bryer.org/) (<jason@bryer.org>)  
Bookdown Site: <https://psa.bryer.org>

## Overview

The use of propensity score methods (Rosenbaum & Rubin, 1983) for
estimating causal effects in observational studies or certain kinds of
quasi-experiments has been increasing in the social sciences (Thoemmes &
Kim, 2011) and in medical research (Austin, 2008) in the last decade.
Propensity score analysis (PSA) attempts to adjust selection bias that
occurs due to the lack of randomization. Analysis is typically conducted
in two phases where in phase I, the probability of placement in the
treatment is estimated to identify matched pairs or clusters so that in
phase II, comparisons on the dependent variable can be made between
matched pairs or within clusters. R (R Core Team, 2012) is ideal for
conducting PSA given its wide availability of the most current
statistical methods vis-à-vis add-on packages as well as its superior
graphics capabilities.

This workshop will provide participants with a theoretical overview of
propensity score methods as well as illustrations and discussion of PSA
applications. Methods used in phase I of PSA (i.e. models or methods for
estimating propensity scores) include logistic regression,
classification trees, and matching. Discussions on appropriate
comparisons and estimations of effect size and confidence intervals in
phase II will also be covered. The use of graphics for diagnosing
covariate balance as well as summarizing overall results will be
emphasized.

<img src="man/figures/README-psa_citations_by_year-1.png" width="100%" />

## Getting Started

You can install the `psa` package using the `remotes` package. I
recommend setting the `dependencies = 'Enhances'` as many this will
install all the packages that are used in the examples.

``` r
remotes::install_github('jbryer/psa', build_vignettes = TRUE, dependencies = 'Enhances')
```

Run the PSA Shiny App:

``` r
library(psa)
psa::psa_shiny()
```

<img src="man/figures/psa_shiny_screenshots.gif" width="100%" />

## The `MatchBalance` Function

``` r
data(lalonde, package='Matching')
formu.lalonde <- treat ~ age + I(age^2) + educ + I(educ^2) + hisp + married + nodegr + 
    re74  + I(re74^2) + re75 + I(re75^2) + u74 + u75
mb0.lalonde <- psa::MatchBalance(df = lalonde, formu=formu.lalonde)
# summary(mb0.lalonde) # Excluded to save space
plot(mb0.lalonde)
```

<img src="man/figures/README-MatchBalance-1.png" width="100%" />

## The `loess.plot` Function

``` r
data(pisana, package = 'multilevelPSA')
data(pisa.psa.cols, package = 'multilevelPSA')
cnt <- 'USA' # Can change this to USA, MEX, or CAN
pisa_usa <- pisana[pisana$CNT == cnt,]
pisa_usa$treat <- as.integer(pisa_usa$PUBPRIV) %% 2
lr.results <- glm(treat ~ ., data=pisa_usa[,c('treat',pisa.psa.cols)], family='binomial')
st <- data.frame(ps=fitted(lr.results), 
                math=apply(pisa_usa[,paste('PV', 1:5, 'MATH', sep='')], 1, mean), 
                pubpriv=pisa_usa$treat)
st$treat = as.logical(st$pubpriv)
psa::loess.plot(x = st$ps, 
                response = st$math, 
                treatment = st$treat, 
                percentPoints.control = 0.4, 
                percentPoints.treat=0.4)
#> `geom_smooth()` using method = 'gam' and formula = 'y ~ s(x, bs = "cs")'
```

<img src="man/figures/README-loess_plot-1.png" width="100%" />

## The `merge.mids` Function

The `merge.mids` function is a convenience for merging the multiple
imputation results from the `mice::mice()` function with the full data
frame used for imputation. In the context of PSA imputation is conducted
without the including the outcome variable. This function will merge in
the outcome, along with any other variables not used in the imputation
procedure, with one of the imputed datasets. Additionally, by setting
the `shadow.matrix` parameter to `TRUE` the resulting data frame will
contain additional logical columns with the suffix `_missing` with a
value of `TRUE` if the variable was originally missing and therefore was
imputed.

## Slides

- Workshop at University at Albany, Division of Educational Psychology &
  Methodology – April 30 and May 7, 2014 [Download
  Slides](Slides/UAlbany2014/Slides.pdf?raw=true)  
- NEAIR Conference Talk – November 11, 2013 [Download
  Slides](Slides/NEAIR2013Slides/Slides.pdf?raw=true)
- Pre-conference workshop for the 2013 useR! conference – July 9, 2013
  [Download Slides](Slides/useR%202013/Slides.pdf?raw=true)

## R Scripts

The following R scripts will outline how to conduct propensity score
analysis.

- [Setup.R](R-Scripts/Setup.R) - Install R packages. This script
  generally needs to be run once per R installation.
- [IntroPSA.R](R-Scripts/IntroPSA.R) - Conducts propensity score
  analysis and matching, summarizes results, and evaluates balance using
  the National Supported Work Demonstration and Current Population
  Survey (aka lalonde data).
- [IntroPSA-Tutoring.R](R-Scripts/IntroPSA.R) - Conducts propensity
  score analysis and matching, summarizes results, and evaluates balance
  using data from a study examining student use of tutoring services in
  an online introductory writing class (from the `TriMatch` package).
- [Sensitivity.R](R-Scripts/Sensitivity.R) - Conduct a sensitivity
  analysis.
- [Missingness.R](R-Scripts/Missingness.R) - How to evaluate whether
  data is missing at random.
- [BootstrappingPSA.R](R-Scripts/BootstrappingPSA.R) - Boostrapping PSA.
- [NonBinaryPSA.R](R-Scripts/NonBinaryPSA.R) - Analysis of three groups
  (two treatments and one control)
- [MultilevelPSA.R](R-Scripts/MultilevelPSA.R) - Multilevel propensity
  score analysis.

## R Packages

There are a number of R packages available for conducting propensity
score analysis. These are the packages this workshop will make use of:

- [`MatchIt`](http://gking.harvard.edu/gking/matchit) (Ho, Imai, King, &
  Stuart, 2011) Nonparametric Preprocessing for Parametric Causal
  Inference
- [`Matching`](http://sekhon.berkeley.edu/matching/) (Sekhon, 2011)
  Multivariate and Propensity Score Matching Software for Causal
  Inference
- [`multilevelPSA`](http://jason.bryer.org/multilevelPSA) (Bryer &
  Pruzek, 2011) Multilevel Propensity Score Analysis
- [`party`](http://cran.r-project.org/web/packages/party/index.html)
  (Hothorn, Hornik, & Zeileis, 2006) A Laboratory for Recursive
  Partytioning
- [`PSAboot`](http://jason.bryer.org/PSAboot) (Bryer, 2013)
  Bootstrapping for Propensity Score Analysis
- [`PSAgraphics`](http://www.jstatsoft.org/v29/i06/paper) (Helmreich &
  Pruzek, 2009) An R Package to Support Propensity Score Analysis
- [`rbounds`](http://www.personal.psu.edu/ljk20/rbounds%20vignette.pdf)
  (Keele, 2010) An Overview of rebounds: An R Package for Rosenbaum
  bounds sensitivity analysis with matched data.
- [`rpart`](http://cran.r-project.org/web/packages/rpart/index.html)
  (Therneau, Atkinson, & Ripley, 2012) Recursive Partitioning
- [`TriMatch`](http://jason.bryer.org/TriMatch) (Bryer, 2013) Propensity
  Score Matching for Non-Binary Treatments

## References

Rosenbaum, P.R., & Rubin, D.B. (1983). [The central role of the
propensity score in observational studies for causal
effects](http://faculty.smu.edu/Millimet/classes/eco7377/papers/rosenbaum%20rubin%2083a.pdf).
*Biometrika, 70*(1), 41-55.

Rosenbaum, P.R. (2010). *Design of Observational Studies*. New York:
Springer.

Austin, P. C. (2011). Comparing paired vs non-paired statistical methods
of analyses when making inferences about absolute risk reductions in
propensity-score matched samples. *Statistics in Medicine, 30*.

Bryer, J. (2011). multilevelPSA: Multilevel propensity score analysis
\[Computer software manual\]. Retrieved from
<http://github.com/jbryer/multilevelPSA>

Bryer, J., & Pruzek, R.M. (2011). An international comparison of private
and public schools using multilevel propensity score methods and
graphics (Abstract). *Multivariate Behavioral Research, 46*(6),
1010-1011.

Helmreich, J. E., & Pruzek, R. M. (2009). PSAgraphics: An R package to
support propensity score analysis. *Journal of Statistical Software,
29*(6). Available from <http://www.jstatsoft.org/v29/i06/paper>

Ho, D.E., Imai, K., King, G., and Stuart, E.A (2011). [MatchIt:
Nonparametric Preprocessing for Parametric Causal
Inference](http://www.jstatsoft.org/v42/i08/). *Journal of Statistical
Software 42*(8).

Hothorn, T., Hornik, K., & Zeileis, A. (2006). Unbiased Recursive
Partitioning: A Conditional Inference Framework. *Journal of
Computational and Graphical Statistics, 15*(3), 651–674.

R Core Team (2012). [R: A language and environment for statistical
computing](http://www.R-project.org/). R Foundation for Statistical
Computing, Vienna, Austria. ISBN 3-900051-07-0.

Rosenbaum, P.R. (2005). Sensitivity analysis in observational studies.
In B.S. Everitt & D.C. Howell *Encyclopedia of Statistics in Behavioral
Science*, pp. 1809-1814. Chichester: John Wiley & Sons.

Rosenbaum, P.R. (2012). Testing one hypothesis twice in observational
studies. *Biometrika*.

Sekhon, J.S. (2011). [Multivariate and Propensity Score Matching
Software with Automated Balance Optimization: The Matching Package for
R](http://www.jstatsoft.org/v42/i07/). *Journal of Statistical Software,
42*(7), 1-52.

Shadish, W.R., Clark, M.H., & Steiner, P.M. (2008). Can nonrandomized
experiments yield accurate answers? A randomized experiment comparing
random and nonrandom assignments. *Journal of the American Statistical
Association, 103*(484). 1334-1356.

Stuart, E. A. (2010). Matching methods for causal inference: A review
and a look forward. *Statistical Science, 25*, 1-21.

Stuart, E.A., & Rubin, D.B. (2007). Best practices in quasi-experimental
designs: Matching methods for causal inference. Chapter 11 (pp. 155-176)
in J. Osborne (Ed.). *Best Practices in Quantitative Social Science*.
Thousand Oaks, CA: Sage Publications.

Therneau, T., Atkinson, B., & Ripley, B. (2012). [rpart: Recursive
Partitioning](http://CRAN.R-project.org/package=rpart). R package
version 4.0-1.

Thoemmes, F. J., & Kim, E. S. (2011). A systematic review of propensity
score methods in the social sciences. Multivariate Behavioral Research,
46, 90-118.

## Code of Conduct

Please note that the psa project is released with a [Contributor Code of
Conduct](https://contributor-covenant.org/version/2/1/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.
