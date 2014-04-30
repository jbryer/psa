# Applied Propensity Score Analysis with R

Author: Jason Bryer (<jason@bryer.org>)  
Website: http://jason.bryer.org/psa/  
Github Repository: https://github.com/jbryer/psa  

________________________________________________________________________________

The use of propensity score methods [@RosenbaumRubin1983] (Rosenbaum & Rubin, 1983) for estimating causal effects in observational studies or certain kinds of quasi-experiments has been increasing in the social sciences (Thoemmes & Kim, 2011) and in medical research (Austin, 2008) in the last decade. Propensity score analysis (PSA) attempts to adjust selection bias that occurs due to the lack of randomization. Analysis is typically conducted in two phases where in phase I, the probability of placement in the treatment is estimated to identify matched pairs or clusters so that in phase II, comparisons on the dependent variable can be made between matched pairs or within clusters. R (R Core Team, 2012) is ideal for conducting PSA given its wide availability of the most current statistical methods vis-à-vis add-on packages as well as its superior graphics capabilities.

## R

To reproduce the analysis described in this book you will need R. R is available for Mac, Linux, and Windows and can be downloaded at [cran.r-project.org](http://cran.r-project.org). I also recommend that you download [Rstudio](http://rstudio.com). This is an integrated development environment that makes working on R projects much easier.

If you are new to R, here are some excellent resources for learning R:

* [Quick-R](http://statmethods.net/) - A great website maintined by Robert Kabacoff. I also highly his book, [R in Action](http://www.manning.com/kabacoff/).
* [RDocumentation.org](http://www.rdocumentation.org/) - Provides a nice searchable interface for all the R packages available.

## R Packages

There are a number of R packages available for conducting propensity score analysis. We will utilize the following R packages:

* [`MatchIt`](http://gking.harvard.edu/gking/matchit) (Ho, Imai, King, & Stuart, 2011) Nonparametric Preprocessing for Parametric Causal Inference
* [`Matching`](http://sekhon.berkeley.edu/matching/) (Sekhon, 2011) Multivariate and Propensity Score Matching Software for Causal Inference
* [`multilevelPSA`](http://jason.bryer.org/multilevelPSA) (Bryer & Pruzek, 2011) Multilevel Propensity Score Analysis
* [`party`](http://cran.r-project.org/web/packages/party/index.html) (Hothorn, Hornik, & Zeileis, 2006) A Laboratory for Recursive Partytioning
* [`PSAboot`](http://jason.bryer.org/PSAboot) (Bryer, 2013) Bootstrapping for Propensity Score Analysis
* [`PSAgraphics`](http://www.jstatsoft.org/v29/i06/paper) (Helmreich & Pruzek, 2009) An R Package to Support Propensity Score Analysis
* [`rbounds`](http://www.personal.psu.edu/ljk20/rbounds%20vignette.pdf) (Keele, 2010) An Overview of rebounds: An R Package for Rosenbaum bounds sensitivity analysis with matched data.
* [`rpart`](http://cran.r-project.org/web/packages/rpart/index.html) (Therneau, Atkinson, & Ripley, 2012) Recursive Partitioning
* [`TriMatch`](http://jason.bryer.org/TriMatch) (Bryer, 2013) Propensity Score Matching for Non-Binary Treatments

The following command will install the R packages we will use in this book.

```
install.packages(c('devtools','ggplot2','granova','granovaGG','gridExtra',
				   'Matching','MatchIt','party','PSAgraphics','rbounds',
				   'rpart'), 
				 repos='http://cran.r-project.org')
devtools::install_github('multilevelPSA', 'jbryer')
devtools::install_github('TriMatch', 'jbryer')
devtools::install_github('PSAboot', 'jbryer')
```

--------------------------------------------------------------------------------

This book has been generated using [GitBook](http://gitbook.io). See [this blog post](http://jason.bryer.org/posts/2014-04-18/Gitbook_with_R_Markdown.html) for how to use Gitbook with R Markdown.

