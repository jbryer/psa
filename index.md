--- 
title: "Applied Propensity Score Analysis with R"
author: "Jason Bryer, Ph.D."
date: "2023-11-13"
site: bookdown::bookdown_site
documentclass: book
url: https://psa.bryer.org
cover-image: images/cover.png
description: |
  An introduction to conducting propensity score analysis with R.
biblio-style: apalike
bibliography: [book.bib, packages.bib]
---

# Preface {-}

Last updated: November 13, 2023

<a href="https://psa.bryer.org" target="_blank"><img src="figures/cover.png" width="40%" style="float:right; padding:10px" style="display: block; margin: auto 0 auto auto;" /></a>

I was first introduced to propensity score analysis (PSA) by my late dissertation advisor Robert Pruzek in 2006 when I entered graduate school. The notion that you could get reasonable causal estimates without the need of randomization was foreign to me and at first, I was skeptical. Many years later having used PSA for many projects, not only am I convinced it is possible, I believe there are instances where this may be preferred over the randomized control trial. I have been the Principal Investigator for two Federal grants to develop and test the [Diagnostic Assessment and Achievement of College Skills (DAACS)](https://daacs.net) where have attempted to conduct large scale randomized control trials (RCT) involving thousands of students. I have found through my experiences conducting these large scale RCTs that there are numerous compromises made in delivering an intervention that compromise the generalizability of the results. Moreover, RCTs assume a single, homogenous, causal effect for everyone. In reality this is rarely true. Not all interventions are equally effective for everyone. With PSA, particularly in the stratification section, it is possible to tease out how an intervention may vary by the observed covariates.

I have taught PSA many times over the years. This "book" is my attempt to collect my notes and experiences on conducting PSA. For the most part I will emphasize the applied and provide links to references if the reader wishes to explore the theoretical in more details. Additionally, the book will make extensive use of visualizations both to explain concepts as well their use for presenting results. The `psa` R package that accompanies this book is available on Github and can be installed using the `remotes` package with the command below. By setting the `dependencies = 'Enhances'` parameter will ensure that all the R packages used in this book are installed as well. The `psa` package contains a number of datasets and utility functions used throughout the book. But it also contains a [Shiny](https://shiny.rstudio.com) application designed to conduct PSA using a graphical user interface. Details on using the application are provided in the [appendix](#psa_shiny).


```r
remotes::install_github('jbryer/psa',
						build_vignettes = TRUE,
						dependencies = 'Enhances')
```

## Status

## Contributing {.unnumbered}

This books is a work in progress and contributions are welcome. Please adhere to the [code of conduct](https://github.com/jbryer/psa/blob/master/CODE_OF_CONDUCT.md). Each page has an edit link which will take you directly to the source file on [Github](https://github.com/jbryer/psa). You can also submit feedback using the [Github Issues](https://github.com/jbryer/psa/issues) tracker.

## Acknowledgements {.unnumbered}

This website was created using [bookdown](https://bookdown.org) and is hosted by [Github](https://github.com/jbryer/psa) [pages](https://www.google.com/search?client=safari&rls=en&q=github+pages&ie=UTF-8&oe=UTF-8).

## Colophon {.unnumbered}


```r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.3.2 (2023-10-31)
##  os       Ubuntu 22.04.3 LTS
##  system   x86_64, linux-gnu
##  ui       X11
##  language (EN)
##  collate  C.UTF-8
##  ctype    C.UTF-8
##  tz       UTC
##  date     2023-11-13
##  pandoc   2.19.2 @ /usr/bin/ (via rmarkdown)
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version  date (UTC) lib source
##  abind           1.4-5    2016-07-21 [1] RSPM (R 4.3.0)
##  backports       1.4.1    2021-12-13 [1] RSPM (R 4.3.0)
##  bookdown        0.36     2023-10-16 [1] RSPM (R 4.3.0)
##  boot            1.3-28.1 2022-11-22 [2] CRAN (R 4.3.2)
##  bslib           0.5.1    2023-08-11 [1] RSPM (R 4.3.0)
##  cachem          1.0.8    2023-05-01 [1] RSPM (R 4.3.0)
##  callr           3.7.3    2022-11-02 [1] RSPM (R 4.3.0)
##  car           * 3.1-2    2023-03-30 [1] RSPM (R 4.3.0)
##  carData       * 3.0-5    2022-01-06 [1] RSPM (R 4.3.0)
##  cli             3.6.1    2023-03-23 [1] RSPM (R 4.3.0)
##  codetools       0.2-19   2023-02-01 [2] CRAN (R 4.3.2)
##  coin            1.4-3    2023-09-27 [1] RSPM (R 4.3.0)
##  colorspace      2.1-0    2023-01-23 [1] RSPM (R 4.3.0)
##  crayon          1.5.2    2022-09-29 [1] RSPM (R 4.3.0)
##  devtools        2.4.5    2022-10-11 [1] RSPM (R 4.3.0)
##  digest          0.6.33   2023-07-07 [1] RSPM (R 4.3.0)
##  downlit         0.4.3    2023-06-29 [1] RSPM (R 4.3.0)
##  dplyr         * 1.1.3    2023-09-03 [1] RSPM (R 4.3.0)
##  ellipsis        0.3.2    2021-04-29 [1] RSPM (R 4.3.0)
##  evaluate        0.23     2023-11-01 [1] RSPM (R 4.3.0)
##  ez            * 4.4-0    2016-11-02 [1] RSPM (R 4.3.0)
##  fansi           1.0.5    2023-10-08 [1] RSPM (R 4.3.0)
##  fastmap         1.1.1    2023-02-24 [1] RSPM (R 4.3.0)
##  fs              1.6.3    2023-07-20 [1] RSPM (R 4.3.0)
##  generics        0.1.3    2022-07-05 [1] RSPM (R 4.3.0)
##  ggplot2       * 3.4.4    2023-10-12 [1] RSPM (R 4.3.0)
##  ggthemes        4.2.4    2021-01-20 [1] RSPM (R 4.3.0)
##  glue            1.6.2    2022-02-24 [1] RSPM (R 4.3.0)
##  granova       * 2.2      2023-03-22 [1] RSPM (R 4.3.0)
##  granovaGG     * 1.4.0    2023-11-13 [1] Github (briandk/granovaGG@3b95715)
##  gridExtra       2.3      2017-09-09 [1] RSPM (R 4.3.0)
##  gtable          0.3.4    2023-08-21 [1] RSPM (R 4.3.0)
##  highr           0.10     2022-12-22 [1] RSPM (R 4.3.0)
##  htmltools       0.5.7    2023-11-03 [1] RSPM (R 4.3.0)
##  htmlwidgets     1.6.2    2023-03-17 [1] RSPM (R 4.3.0)
##  httpuv          1.6.12   2023-10-23 [1] RSPM (R 4.3.0)
##  jquerylib       0.1.4    2021-04-26 [1] RSPM (R 4.3.0)
##  jsonlite        1.8.7    2023-06-29 [1] RSPM (R 4.3.0)
##  knitr         * 1.45     2023-10-30 [1] RSPM (R 4.3.0)
##  later           1.3.1    2023-05-02 [1] RSPM (R 4.3.0)
##  lattice         0.21-9   2023-10-01 [2] CRAN (R 4.3.2)
##  libcoin         1.0-10   2023-09-27 [1] RSPM (R 4.3.0)
##  lifecycle       1.0.4    2023-11-07 [1] RSPM (R 4.3.0)
##  lme4            1.1-35.1 2023-11-05 [1] RSPM (R 4.3.0)
##  magrittr        2.0.3    2022-03-30 [1] RSPM (R 4.3.0)
##  MASS          * 7.3-60   2023-05-04 [2] CRAN (R 4.3.2)
##  Matching      * 4.10-14  2023-09-14 [1] RSPM (R 4.3.0)
##  MatchIt       * 4.5.5    2023-10-13 [1] RSPM (R 4.3.0)
##  Matrix          1.6-1.1  2023-09-18 [2] CRAN (R 4.3.2)
##  matrixStats     1.1.0    2023-11-07 [1] RSPM (R 4.3.0)
##  memoise         2.0.1    2021-11-26 [1] RSPM (R 4.3.0)
##  mgcv            1.9-0    2023-07-11 [2] CRAN (R 4.3.2)
##  mime            0.12     2021-09-28 [1] RSPM (R 4.3.0)
##  miniUI          0.1.1.1  2018-05-18 [1] RSPM (R 4.3.0)
##  minqa           1.2.6    2023-09-11 [1] RSPM (R 4.3.0)
##  mnormt          2.1.1    2022-09-26 [1] RSPM (R 4.3.0)
##  modeltools      0.2-23   2020-03-05 [1] RSPM (R 4.3.0)
##  multcomp        1.4-25   2023-06-20 [1] RSPM (R 4.3.0)
##  multilevelPSA * 1.2.5    2018-03-22 [1] RSPM (R 4.3.0)
##  munsell         0.5.0    2018-06-12 [1] RSPM (R 4.3.0)
##  mvtnorm         1.2-3    2023-08-25 [1] RSPM (R 4.3.0)
##  nlme            3.1-163  2023-08-09 [2] CRAN (R 4.3.2)
##  nloptr          2.0.3    2022-05-26 [1] RSPM (R 4.3.0)
##  party           1.3-13   2023-03-17 [1] RSPM (R 4.3.0)
##  pillar          1.9.0    2023-03-22 [1] RSPM (R 4.3.0)
##  pkgbuild        1.4.2    2023-06-26 [1] RSPM (R 4.3.0)
##  pkgconfig       2.0.3    2019-09-22 [1] RSPM (R 4.3.0)
##  pkgload         1.3.3    2023-09-22 [1] RSPM (R 4.3.0)
##  plyr            1.8.9    2023-10-02 [1] RSPM (R 4.3.0)
##  prettyunits     1.2.0    2023-09-24 [1] RSPM (R 4.3.0)
##  processx        3.8.2    2023-06-30 [1] RSPM (R 4.3.0)
##  profvis         0.3.8    2023-05-02 [1] RSPM (R 4.3.0)
##  promises        1.2.1    2023-08-10 [1] RSPM (R 4.3.0)
##  ps              1.7.5    2023-04-18 [1] RSPM (R 4.3.0)
##  PSAboot       * 1.3.8    2023-11-13 [1] Github (jbryer/PSAboot@f5d73cd)
##  PSAgraphics   * 2.1.2    2023-03-21 [1] RSPM (R 4.3.0)
##  psych           2.3.9    2023-09-26 [1] RSPM (R 4.3.0)
##  purrr           1.0.2    2023-08-10 [1] RSPM (R 4.3.0)
##  R6              2.5.1    2021-08-19 [1] RSPM (R 4.3.0)
##  randomForest    4.7-1.1  2022-05-23 [1] RSPM (R 4.3.0)
##  RColorBrewer    1.1-3    2022-04-03 [1] RSPM (R 4.3.0)
##  Rcpp            1.0.11   2023-07-06 [1] RSPM (R 4.3.0)
##  remotes         2.4.2.1  2023-07-18 [1] RSPM (R 4.3.0)
##  reshape         0.8.9    2022-04-12 [1] RSPM (R 4.3.0)
##  reshape2      * 1.4.4    2020-04-09 [1] RSPM (R 4.3.0)
##  rlang           1.1.2    2023-11-04 [1] RSPM (R 4.3.0)
##  rmarkdown       2.25     2023-09-18 [1] RSPM (R 4.3.0)
##  rpart         * 4.1.21   2023-10-09 [2] CRAN (R 4.3.2)
##  sandwich        3.0-2    2022-06-15 [1] RSPM (R 4.3.0)
##  sass            0.4.7    2023-07-15 [1] RSPM (R 4.3.0)
##  scales        * 1.2.1    2022-08-20 [1] RSPM (R 4.3.0)
##  sessioninfo     1.2.2    2021-12-06 [1] RSPM (R 4.3.0)
##  shiny           1.7.5.1  2023-10-14 [1] RSPM (R 4.3.0)
##  stringi         1.7.12   2023-01-11 [1] RSPM (R 4.3.0)
##  stringr         1.5.0    2022-12-02 [1] RSPM (R 4.3.0)
##  strucchange     1.5-3    2022-06-15 [1] RSPM (R 4.3.0)
##  survival        3.5-7    2023-08-14 [2] CRAN (R 4.3.2)
##  TH.data         1.1-2    2023-04-17 [1] RSPM (R 4.3.0)
##  tibble          3.2.1    2023-03-20 [1] RSPM (R 4.3.0)
##  tidyselect      1.2.0    2022-10-10 [1] RSPM (R 4.3.0)
##  TriMatch      * 0.9.9    2017-12-06 [1] RSPM (R 4.3.0)
##  urlchecker      1.0.1    2021-11-30 [1] RSPM (R 4.3.0)
##  usethis         2.2.2    2023-07-06 [1] RSPM (R 4.3.0)
##  utf8            1.2.4    2023-10-22 [1] RSPM (R 4.3.0)
##  vctrs           0.6.4    2023-10-12 [1] RSPM (R 4.3.0)
##  withr           2.5.2    2023-10-30 [1] RSPM (R 4.3.0)
##  xfun            0.41     2023-11-01 [1] RSPM (R 4.3.0)
##  xml2            1.3.5    2023-07-06 [1] RSPM (R 4.3.0)
##  xtable        * 1.8-4    2019-04-21 [1] RSPM (R 4.3.0)
##  yaml            2.3.7    2023-01-23 [1] RSPM (R 4.3.0)
##  zoo             1.8-12   2023-04-13 [1] RSPM (R 4.3.0)
## 
##  [1] /home/runner/work/_temp/Library
##  [2] /opt/R/4.3.2/lib/R/library
## 
## ──────────────────────────────────────────────────────────────────────────────
```

## License {.unnumbered}

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work by [Jason Bryer](https://bryer.org/) is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
