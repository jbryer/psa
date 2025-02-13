--- 
title: "Applied Propensity Score Analysis with R"
author: "Jason Bryer, Ph.D."
date: "2025-02-13"
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

Last updated: February 13, 2025

<a href="https://psa.bryer.org" target="_blank"><img src="figures/cover.png" width="40%" style="float:right; padding:10px" style="display: block; margin: auto 0 auto auto;" /></a>

I was first introduced to propensity score analysis (PSA) by my late dissertation advisor Robert Pruzek in 2006 when I entered graduate school. The notion that you could get reasonable causal estimates without the need of randomization was foreign to me and at first, I was skeptical. Many years later having used PSA for many projects, not only am I convinced it is possible, I believe there are instances where this may be preferred over the randomized control trial. I have been the Principal Investigator for two Federal grants to develop and test the [Diagnostic Assessment and Achievement of College Skills (DAACS)](https://daacs.net) where have attempted to conduct large scale randomized control trials (RCT) involving thousands of students. I have found through my experiences conducting these large scale RCTs that there are numerous compromises made in delivering an intervention that compromise the generalizability of the results. Moreover, RCTs assume a single, homogenous, causal effect for everyone. In reality this is rarely true. Not all interventions are equally effective for everyone. With PSA, particularly in the stratification section, it is possible to tease out how an intervention may vary by the observed covariates.

I have taught PSA many times over the years. This "book" is my attempt to collect my notes and experiences on conducting PSA. For the most part I will emphasize the applied and provide links to references if the reader wishes to explore the theoretical in more details. Additionally, the book will make extensive use of visualizations both to explain concepts as well their use for presenting results. The `psa` R package that accompanies this book is available on Github and can be installed using the `remotes` package with the command below. By setting the `dependencies = 'Enhances'` parameter will ensure that all the R packages used in this book are installed as well. The `psa` package contains a number of datasets and utility functions used throughout the book. But it also contains a [Shiny](https://shiny.rstudio.com) application designed to conduct PSA using a graphical user interface. Details on using the application are provided in the [appendix](#psa_shiny).


``` r
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


``` r
devtools::session_info()
```

```
## ─ Session info ───────────────────────────────────────────────────────────────
##  setting  value
##  version  R version 4.4.2 (2024-10-31)
##  os       Ubuntu 24.04.1 LTS
##  system   x86_64, linux-gnu
##  ui       X11
##  language (EN)
##  collate  C.UTF-8
##  ctype    C.UTF-8
##  tz       UTC
##  date     2025-02-13
##  pandoc   3.1.11 @ /opt/hostedtoolcache/pandoc/3.1.11/x64/ (via rmarkdown)
##  quarto   NA
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  abind           1.4-8      2024-09-12 [1] RSPM (R 4.4.0)
##  backports       1.5.0      2024-05-23 [1] RSPM (R 4.4.0)
##  bookdown        0.42       2025-01-07 [1] RSPM (R 4.4.0)
##  boot            1.3-31     2024-08-28 [2] CRAN (R 4.4.2)
##  bslib           0.9.0      2025-01-30 [1] RSPM (R 4.4.0)
##  cachem          1.1.0      2024-05-16 [1] RSPM (R 4.4.0)
##  car           * 3.1-3      2024-09-27 [1] RSPM (R 4.4.0)
##  carData       * 3.0-5      2022-01-06 [1] RSPM (R 4.4.0)
##  cli             3.6.4      2025-02-13 [1] CRAN (R 4.4.2)
##  codetools       0.2-20     2024-03-31 [2] CRAN (R 4.4.2)
##  coin            1.4-3      2023-09-27 [1] RSPM (R 4.4.0)
##  colorspace      2.1-1      2024-07-26 [1] RSPM (R 4.4.0)
##  devtools        2.4.5      2022-10-11 [1] RSPM (R 4.4.0)
##  digest          0.6.37     2024-08-19 [1] RSPM (R 4.4.0)
##  downlit         0.4.4      2024-06-10 [1] RSPM (R 4.4.0)
##  dplyr         * 1.1.4      2023-11-17 [1] RSPM (R 4.4.0)
##  ellipsis        0.3.2      2021-04-29 [1] RSPM (R 4.4.0)
##  evaluate        1.0.3      2025-01-10 [1] RSPM (R 4.4.0)
##  ez            * 4.4-0      2016-11-02 [1] RSPM (R 4.4.0)
##  fastmap         1.2.0      2024-05-15 [1] RSPM (R 4.4.0)
##  Formula         1.2-5      2023-02-24 [1] RSPM (R 4.4.0)
##  fs              1.6.5      2024-10-30 [1] RSPM (R 4.4.0)
##  generics        0.1.3      2022-07-05 [1] RSPM (R 4.4.0)
##  ggplot2       * 3.5.1      2024-04-23 [1] RSPM (R 4.4.0)
##  ggthemes        5.1.0      2024-02-10 [1] RSPM (R 4.4.0)
##  glue            1.8.0      2024-09-30 [1] RSPM (R 4.4.0)
##  granova       * 2.2        2023-03-22 [1] RSPM (R 4.4.0)
##  granovaGG     * 1.4.1.9000 2025-02-13 [1] Github (briandk/granovaGG@7014d74)
##  gridExtra       2.3        2017-09-09 [1] RSPM (R 4.4.0)
##  gtable          0.3.6      2024-10-25 [1] RSPM (R 4.4.0)
##  htmltools       0.5.8.1    2024-04-04 [1] RSPM (R 4.4.0)
##  htmlwidgets     1.6.4      2023-12-06 [1] RSPM (R 4.4.0)
##  httpuv          1.6.15     2024-03-26 [1] RSPM (R 4.4.0)
##  jquerylib       0.1.4      2021-04-26 [1] RSPM (R 4.4.0)
##  jsonlite        1.8.9      2024-09-20 [1] RSPM (R 4.4.0)
##  knitr         * 1.49       2024-11-08 [1] RSPM (R 4.4.0)
##  later           1.4.1      2024-11-27 [1] RSPM (R 4.4.0)
##  lattice         0.22-6     2024-03-20 [2] CRAN (R 4.4.2)
##  libcoin         1.0-10     2023-09-27 [1] RSPM (R 4.4.0)
##  lifecycle       1.0.4      2023-11-07 [1] RSPM (R 4.4.0)
##  lme4            1.1-36     2025-01-11 [1] RSPM (R 4.4.0)
##  magrittr        2.0.3      2022-03-30 [1] RSPM (R 4.4.0)
##  MASS          * 7.3-61     2024-06-13 [2] CRAN (R 4.4.2)
##  Matching      * 4.10-15    2024-10-14 [1] RSPM (R 4.4.0)
##  MatchIt       * 4.7.0      2025-01-12 [1] RSPM (R 4.4.0)
##  Matrix          1.7-1      2024-10-18 [2] CRAN (R 4.4.2)
##  matrixStats     1.5.0      2025-01-07 [1] RSPM (R 4.4.0)
##  memoise         2.0.1      2021-11-26 [1] RSPM (R 4.4.0)
##  mgcv            1.9-1      2023-12-21 [2] CRAN (R 4.4.2)
##  mime            0.12       2021-09-28 [1] RSPM (R 4.4.0)
##  miniUI          0.1.1.1    2018-05-18 [1] RSPM (R 4.4.0)
##  minqa           1.2.8      2024-08-17 [1] RSPM (R 4.4.0)
##  mnormt          2.1.1      2022-09-26 [1] RSPM (R 4.4.0)
##  modeltools      0.2-23     2020-03-05 [1] RSPM (R 4.4.0)
##  multcomp        1.4-28     2025-01-29 [1] RSPM (R 4.4.0)
##  multilevelPSA * 1.2.5      2018-03-22 [1] RSPM (R 4.4.0)
##  munsell         0.5.1      2024-04-01 [1] RSPM (R 4.4.0)
##  mvtnorm         1.3-3      2025-01-10 [1] RSPM (R 4.4.0)
##  nlme            3.1-166    2024-08-14 [2] CRAN (R 4.4.2)
##  nloptr          2.1.1      2024-06-25 [1] RSPM (R 4.4.0)
##  party           1.3-18     2025-01-29 [1] RSPM (R 4.4.0)
##  pillar          1.10.1     2025-01-07 [1] RSPM (R 4.4.0)
##  pkgbuild        1.4.6      2025-01-16 [1] RSPM (R 4.4.0)
##  pkgconfig       2.0.3      2019-09-22 [1] RSPM (R 4.4.0)
##  pkgload         1.4.0      2024-06-28 [1] RSPM (R 4.4.0)
##  plyr            1.8.9      2023-10-02 [1] RSPM (R 4.4.0)
##  profvis         0.4.0      2024-09-20 [1] RSPM (R 4.4.0)
##  promises        1.3.2      2024-11-28 [1] RSPM (R 4.4.0)
##  PSAboot       * 1.3.8      2025-02-13 [1] Github (jbryer/PSAboot@f5d73cd)
##  PSAgraphics   * 2.1.3      2024-03-05 [1] RSPM (R 4.4.0)
##  psych           2.4.12     2024-12-23 [1] RSPM (R 4.4.0)
##  purrr           1.0.4      2025-02-05 [1] RSPM (R 4.4.0)
##  R6              2.6.0      2025-02-12 [1] RSPM (R 4.4.0)
##  randomForest    4.7-1.2    2024-09-22 [1] RSPM (R 4.4.0)
##  rbibutils       2.3        2024-10-04 [1] RSPM (R 4.4.0)
##  RColorBrewer    1.1-3      2022-04-03 [1] RSPM (R 4.4.0)
##  Rcpp            1.0.14     2025-01-12 [1] RSPM (R 4.4.0)
##  Rdpack          2.6.2      2024-11-15 [1] RSPM (R 4.4.0)
##  reformulas      0.4.0      2024-11-03 [1] RSPM (R 4.4.0)
##  remotes         2.5.0      2024-03-17 [1] RSPM (R 4.4.0)
##  reshape         0.8.9      2022-04-12 [1] RSPM (R 4.4.0)
##  reshape2      * 1.4.4      2020-04-09 [1] RSPM (R 4.4.0)
##  rlang           1.1.5      2025-01-17 [1] RSPM (R 4.4.0)
##  rmarkdown       2.29       2024-11-04 [1] RSPM (R 4.4.0)
##  rpart         * 4.1.23     2023-12-05 [2] CRAN (R 4.4.2)
##  sandwich        3.1-1      2024-09-15 [1] RSPM (R 4.4.0)
##  sass            0.4.9      2024-03-15 [1] RSPM (R 4.4.0)
##  scales        * 1.3.0      2023-11-28 [1] RSPM (R 4.4.0)
##  sessioninfo     1.2.3      2025-02-05 [1] RSPM (R 4.4.0)
##  shiny           1.10.0     2024-12-14 [1] RSPM (R 4.4.0)
##  stringi         1.8.4      2024-05-06 [1] RSPM (R 4.4.0)
##  stringr         1.5.1      2023-11-14 [1] RSPM (R 4.4.0)
##  strucchange     1.5-4      2024-09-02 [1] RSPM (R 4.4.0)
##  survival        3.7-0      2024-06-05 [2] CRAN (R 4.4.2)
##  TH.data         1.1-3      2025-01-17 [1] RSPM (R 4.4.0)
##  tibble          3.2.1      2023-03-20 [1] RSPM (R 4.4.0)
##  tidyselect      1.2.1      2024-03-11 [1] RSPM (R 4.4.0)
##  TriMatch      * 0.9.9      2017-12-06 [1] RSPM (R 4.4.0)
##  urlchecker      1.0.1      2021-11-30 [1] RSPM (R 4.4.0)
##  usethis         3.1.0      2024-11-26 [1] RSPM (R 4.4.0)
##  vctrs           0.6.5      2023-12-01 [1] RSPM (R 4.4.0)
##  withr           3.0.2      2024-10-28 [1] RSPM (R 4.4.0)
##  xfun            0.50       2025-01-07 [1] RSPM (R 4.4.0)
##  xml2            1.3.6      2023-12-04 [1] RSPM (R 4.4.0)
##  xtable        * 1.8-4      2019-04-21 [1] RSPM (R 4.4.0)
##  yaml            2.3.10     2024-07-26 [1] RSPM (R 4.4.0)
##  zoo             1.8-12     2023-04-13 [1] RSPM (R 4.4.0)
## 
##  [1] /home/runner/work/_temp/Library
##  [2] /opt/R/4.4.2/lib/R/library
##  * ── Packages attached to the search path.
## 
## ──────────────────────────────────────────────────────────────────────────────
```

## License {.unnumbered}

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work by [Jason Bryer](https://bryer.org/) is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
