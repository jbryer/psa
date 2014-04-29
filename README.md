# Introduction to Propensity Score Methods with R

##### Slides

* Workshop at University at Albany, Division of Educational Psychology & Methodology -- April 30 and May 7, 2014 [Download Slides](Slides/UAlbany2014/Slides.pdf)  
* NEAIR Conference Talk -- November 11, 2013 [Download Slides](Slides/NEAIR2013Slides/Slides.pdf)
* Pre-conference workshop for the 2013 useR! conference -- July 9, 2013 [Download Slides](Slides/useR 2013/Slides.pdf)  

[Jason Bryer](http://jason.bryer.org) ([jason@bryer.org](mailto:jason@bryer.org))

## Overview

The use of propensity score methods (Rosenbaum & Rubin, 1983) for estimating causal effects in observational studies or certain kinds of quasi-experiments has been increasing in the social sciences (Thoemmes & Kim, 2011) and in medical research (Austin, 2008) in the last decade. Propensity score analysis (PSA) attempts to adjust selection bias that occurs due to the lack of randomization. Analysis is typically conducted in two phases where in phase I, the probability of placement in the treatment is estimated to identify matched pairs or clusters so that in phase II, comparisons on the dependent variable can be made between matched pairs or within clusters. R (R Core Team, 2012) is ideal for conducting PSA given its wide availability of the most current statistical methods vis-à-vis add-on packages as well as its superior graphics capabilities.

This workshop will provide participants with a theoretical overview of propensity score methods as well as illustrations and discussion of PSA applications. Methods used in phase I of PSA (i.e. models or methods for estimating propensity scores) include logistic regression, classification trees, and matching. Discussions on appropriate comparisons and estimations of effect size and confidence intervals in phase II will also be covered. The use of graphics for diagnosing covariate balance as well as summarizing overall results will be emphasized. Lastly, the extension of PSA methods for multilevel data will also be presented.


## Outline

* Theretical overview of propensity score methods
* Phase I of PSA - Adjusting for selection bias by modeling treatment placement
	* Stratification using logistic regression and classification trees; also random forests
	* Propensity score matching
	* Checking covariate balance
* Phase II of PSA - Estimating effects re: response variables
	* Dependent sample tests and confidence intervals. 
	* Visualizing results
* Advanced Topics
	* Sensitivity analysis
	* PSA with Missing Data
	* Bootstrapping for PSA
	* Analysis of non-binary treatments
	* Analysis of multilevel data

## R Scripts

The following R scripts will outline how to conduct propensity score analysis.

* [Setup.R](R-Scripts/Setup.R) - Install R packages. This script generally needs to be run once per R installation.
* [IntroPSA.R](R-Scripts/IntroPSA.R) - Conducts propensity score analysis and matching, summarizes results, and evaluates balance.
* [Sensitivity.R](R-Scripts/Sensitivity.R) - Conduct a sensitivity analysis.
* [Missingness.R](R-Scripts/Missingness.R) - How to evaluate whether data is missing at random.
* [BootstrappingPSA.R](R-Scripts/BootstrappingPSA.R) - Boostrapping PSA.
* [NonBinaryPSA.R](R-Scripts/NonBinaryPSA.R) - Analysis of three groups (two treatments and one control)
* [MultilevelPSA.R](R-Scripts/MultilevelPSA.R) - Multilevel propensity score analysis.

## R Packages

There are a number of R packages available for conducting propensity score analysis. These are the packages this workshop will make use of:

* [`MatchIt`](http://gking.harvard.edu/gking/matchit) (Ho, Imai, King, & Stuart, 2011) Nonparametric Preprocessing for Parametric Causal Inference
* [`Matching`](http://sekhon.berkeley.edu/matching/) (Sekhon, 2011) Multivariate and Propensity Score Matching Software for Causal Inference
* [`multilevelPSA`](http://jason.bryer.org/multilevelPSA) (Bryer & Pruzek, 2011) Multilevel Propensity Score Analysis
* [`party`](http://cran.r-project.org/web/packages/party/index.html) (Hothorn, Hornik, & Zeileis, 2006) A Laboratory for Recursive Partytioning
* [`PSAboot`](http://jason.bryer.org/PSAboot) (Bryer, 2013) Bootstrapping for Propensity Score Analysis
* [`PSAgraphics`](http://www.jstatsoft.org/v29/i06/paper) (Helmreich & Pruzek, 2009) An R Package to Support Propensity Score Analysis
* [`rbounds`](http://www.personal.psu.edu/ljk20/rbounds%20vignette.pdf) (Keele, 2010) An Overview of rebounds: An R Package for Rosenbaum bounds sensitivity analysis with matched data.
* [`rpart`](http://cran.r-project.org/web/packages/rpart/index.html) (Therneau, Atkinson, & Ripley, 2012) Recursive Partitioning
* [`TriMatch`](http://jason.bryer.org/TriMatch) (Bryer, 2013) Propensity Score Matching for Non-Binary Treatments

## References

Rosenbaum, P.R., & Rubin, D.B. (1983). [The central role of the propensity score in observational studies for causal effects](http://faculty.smu.edu/Millimet/classes/eco7377/papers/rosenbaum%20rubin%2083a.pdf). *Biometrika, 70*(1), 41-55.

Rosenbaum, P.R. (2010). *Design of Observational Studies*. New York: Springer.

Austin, P. C. (2011). Comparing paired vs non-paired statistical methods of analyses when making inferences about absolute risk reductions in propensity-score matched samples. *Statistics in Medicine, 30*.

Bryer, J. (2011). multilevelPSA: Multilevel propensity score analysis [Computer software manual]. Retrieved from http://github.com/jbryer/multilevelPSA 

Bryer, J., & Pruzek, R.M. (2011). An international comparison of private and public schools using multilevel propensity score methods and graphics (Abstract). *Multivariate Behavioral Research, 46*(6), 1010-1011.

Helmreich, J. E., & Pruzek, R. M. (2009). PSAgraphics: An R package to support propensity score analysis. *Journal of Statistical Software, 29*(6). Available from http://www.jstatsoft.org/v29/i06/paper

Ho, D.E., Imai, K., King, G., and Stuart, E.A (2011). [MatchIt: Nonparametric Preprocessing for Parametric Causal Inference](http://www.jstatsoft.org/v42/i08/). *Journal of Statistical Software 42*(8).

Hothorn, T., Hornik, K., & Zeileis, A. (2006). Unbiased Recursive Partitioning: A Conditional Inference Framework. *Journal of Computational and Graphical Statistics, 15*(3), 651--674.

R Core Team (2012). [R: A language and environment for statistical computing](http://www.R-project.org/). R Foundation for Statistical Computing, Vienna, Austria. ISBN 3-900051-07-0.

Rosenbaum, P.R. (2005). Sensitivity analysis in observational studies. In B.S. Everitt & D.C. Howell *Encyclopedia of Statistics in Behavioral Science*, pp. 1809-1814. Chichester: John Wiley & Sons.

Rosenbaum, P.R. (2012). Testing one hypothesis twice in observational studies. *Biometrika*.

Sekhon, J.S. (2011). [Multivariate and Propensity Score Matching Software with Automated Balance Optimization: The Matching Package for R](http://www.jstatsoft.org/v42/i07/). *Journal of Statistical Software, 42*(7), 1-52.
  
Shadish, W.R., Clark, M.H., & Steiner, P.M. (2008). Can nonrandomized experiments yield accurate answers? A randomized experiment comparing random and nonrandom assignments. *Journal of the American Statistical Association, 103*(484). 1334-1356.

Stuart, E. A. (2010). Matching methods for causal inference: A review and a look forward. *Statistical Science, 25*, 1-21.

Stuart, E.A., & Rubin, D.B. (2007). Best practices in quasi-experimental designs: Matching methods for causal inference. Chapter 11 (pp. 155-176) in J. Osborne (Ed.). *Best Practices in Quantitative Social Science*. Thousand Oaks, CA: Sage Publications.

Therneau, T., Atkinson, B., & Ripley, B. (2012). [rpart: Recursive Partitioning](http://CRAN.R-project.org/package=rpart). R package version 4.0-1. 
  
Thoemmes, F. J., & Kim, E. S. (2011). A systematic review of propensity score methods in the social sciences. Multivariate Behavioral Research, 46, 90-118.



