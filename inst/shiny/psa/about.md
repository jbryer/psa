**Author:** Jason Bryer, Ph.D.  
**Email:** [jason@bryer.org](mailto:jason@bryer.org)  
**Website:** [github.com/jbryer/psa](www.github.com/jbryer/psa)

This package was designed primarily for teaching purposes and is not provide an exhaustive treatment of conducting propensity score analysis. This shiny application is included in the `psa` R package and can be run locally using the following commands:

```
devtools::install_github('jbryer/psa')
psa::psa_shiny()
```

### R Packages

The core packages used to conduct the propensity score analysis include:

* [`granovaGG`: Graphical Analysis of Variance Using ggplot2](https://cran.r-project.org/web/packages/granovaGG/index.html)
* [`Matching`: Multivariate and Propensity Score Matching with Balance Optimization](https://cran.r-project.org/web/packages/Matching/index.html)
* [`multilevelPSA`: Multilevel Propensity Score Analysis](https://cran.r-project.org/web/packages/multilevelPSA/index.html)
* [`PSAboot`: Bootstrapping for Propensity Score Analysis](https://cran.r-project.org/web/packages/PSAboot/index.html)
* [`PSAgraphics`: Propensity Score Analysis Graphics](https://cran.r-project.org/web/packages/PSAgraphics/index.html)

### Supported Data Formats

Currently, this application supports uploading data files in following formats:

* `csv` - comma separated value files (see the `utils::read.csv` function)
* `xls` or `xlsx` - Microsoft Excel files (see the `gdata::readxl` function)
* `sav` - IBM SPSS files (see the `foreign::read.spss` function)


