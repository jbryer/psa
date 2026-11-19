--- 
title: "Applied Propensity Score Analysis with R"
author: "Jason Bryer, Ph.D."
date: "2026-11-19"
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

Last updated: November 19, 2026

<a href="https://psa.bryer.org" target="_blank"><img src="figures/cover.png" alt="" width="40%" style="float:right; padding:10px" style="display: block; margin: auto 0 auto auto;" /></a>

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
##  version  R version 4.6.2 (2026-10-29)
##  os       Ubuntu 26.04.1 LTS
##  system   x86_64, linux-gnu
##  ui       X11
##  language (EN)
##  collate  C.UTF-8
##  ctype    C.UTF-8
##  tz       UTC
##  date     2026-11-19
##  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
##  quarto   NA
## 
## ─ Packages ───────────────────────────────────────────────────────────────────
##  package       * version    date (UTC) lib source
##  abind           1.4-8      2024-09-12 [1] RSPM (R 4.6.0)
##  bookdown        0.48       2026-08-28 [1] RSPM (R 4.6.0)
##  bslib           0.12.0     2026-08-04 [1] RSPM (R 4.6.0)
##  cachem          1.1.0      2024-05-16 [1] RSPM (R 4.6.0)
##  car             3.1-5      2026-02-03 [1] RSPM (R 4.6.0)
##  carData         3.0-6      2026-01-30 [1] RSPM (R 4.6.0)
##  cli             3.6.6      2026-04-09 [1] RSPM (R 4.6.0)
##  codetools       0.2-20     2024-03-31 [2] CRAN (R 4.6.2)
##  coin            1.4-6      2026-09-30 [1] RSPM (R 4.6.0)
##  devtools        2.5.2      2026-04-30 [1] RSPM (R 4.6.0)
##  digest          0.6.39     2025-11-19 [1] RSPM (R 4.6.0)
##  downlit         0.4.5      2025-11-14 [1] RSPM (R 4.6.0)
##  dplyr         * 1.2.1      2026-04-03 [1] RSPM (R 4.6.0)
##  ellipsis        0.3.3      2026-04-04 [1] RSPM (R 4.6.0)
##  evaluate        1.0.5      2025-08-27 [1] RSPM (R 4.6.0)
##  farver          2.1.2      2024-05-13 [1] RSPM (R 4.6.0)
##  fastmap         1.2.0      2024-05-15 [1] RSPM (R 4.6.0)
##  Formula         1.2-6      2026-08-03 [1] RSPM (R 4.6.0)
##  fs              2.1.0      2026-04-18 [1] RSPM (R 4.6.0)
##  generics        0.1.4      2025-05-09 [1] RSPM (R 4.6.0)
##  ggplot2       * 4.0.4      2026-11-14 [1] RSPM (R 4.6.0)
##  ggthemes        7.0.0      2026-10-03 [1] RSPM (R 4.6.0)
##  glue            1.8.1      2026-04-17 [1] RSPM (R 4.6.0)
##  granova       * 2.3        2025-09-11 [1] RSPM (R 4.6.0)
##  granovaGG     * 1.4.1.9000 2026-11-19 [1] Github (briandk/granovaGG@7014d74)
##  gridExtra       2.3.1      2026-06-25 [1] RSPM (R 4.6.0)
##  gtable          0.3.6      2024-10-25 [1] RSPM (R 4.6.0)
##  htmltools       0.5.9      2025-12-04 [1] RSPM (R 4.6.0)
##  jquerylib       0.1.4      2021-04-26 [1] RSPM (R 4.6.0)
##  jsonlite        2.0.0      2025-03-27 [1] RSPM (R 4.6.0)
##  knitr         * 1.52       2026-09-06 [1] RSPM (R 4.6.0)
##  lattice         0.23-1     2026-08-12 [2] CRAN (R 4.6.2)
##  libcoin         1.0-13     2026-06-04 [1] RSPM (R 4.6.0)
##  lifecycle       1.0.5      2026-01-08 [1] RSPM (R 4.6.0)
##  magrittr        2.0.5      2026-04-04 [1] RSPM (R 4.6.0)
##  MASS          * 7.3-66     2026-07-15 [2] CRAN (R 4.6.2)
##  Matching      * 4.10-15    2024-10-14 [1] RSPM (R 4.6.0)
##  MatchIt       * 4.8.2      2026-11-01 [1] RSPM (R 4.6.0)
##  Matrix          1.7-6      2026-07-25 [2] CRAN (R 4.6.2)
##  matrixStats     1.5.0      2025-01-07 [1] RSPM (R 4.6.0)
##  memoise         2.0.1      2021-11-26 [1] RSPM (R 4.6.0)
##  mnormt          2.1.2      2026-01-27 [1] RSPM (R 4.6.0)
##  modeltools      0.2-25     2026-09-30 [1] RSPM (R 4.6.0)
##  multcomp        1.4-32     2026-08-21 [1] RSPM (R 4.6.0)
##  multilevelPSA * 1.3.1      2025-11-17 [1] RSPM (R 4.6.0)
##  mvtnorm         1.4-2      2026-07-12 [1] RSPM (R 4.6.0)
##  nlme            3.1-171    2026-09-01 [2] CRAN (R 4.6.2)
##  otel            0.3.0      2026-11-07 [1] RSPM (R 4.6.0)
##  party           1.3-23     2026-08-31 [1] RSPM (R 4.6.0)
##  pillar          1.11.1     2025-09-17 [1] RSPM (R 4.6.0)
##  pkgbuild        1.4.8      2025-05-26 [1] RSPM (R 4.6.0)
##  pkgconfig       2.0.3      2019-09-22 [1] RSPM (R 4.6.0)
##  pkgload         1.5.3      2026-06-15 [1] RSPM (R 4.6.0)
##  plyr            1.8.9      2023-10-02 [1] RSPM (R 4.6.0)
##  PSAboot       * 1.3.9      2026-11-19 [1] Github (jbryer/PSAboot@d17d5ae)
##  PSAgraphics   * 2.1.3      2024-03-05 [1] RSPM (R 4.6.0)
##  psych           2.6.9      2026-09-30 [1] RSPM (R 4.6.0)
##  purrr           1.2.2      2026-04-10 [1] RSPM (R 4.6.0)
##  R6              2.6.1      2025-02-15 [1] RSPM (R 4.6.0)
##  randomForest    4.7-1.2    2024-09-22 [1] RSPM (R 4.6.0)
##  RColorBrewer    1.1-3      2022-04-03 [1] RSPM (R 4.6.0)
##  Rcpp            1.1.2      2026-07-05 [1] RSPM (R 4.6.0)
##  reshape         0.8.10     2025-06-19 [1] RSPM (R 4.6.0)
##  reshape2      * 1.4.5      2025-11-12 [1] RSPM (R 4.6.0)
##  rlang           1.3.0      2026-07-05 [1] RSPM (R 4.6.0)
##  rmarkdown       2.32       2026-09-01 [1] RSPM (R 4.6.0)
##  rpart         * 4.1.27     2026-03-27 [2] CRAN (R 4.6.2)
##  S7              0.2.2      2026-04-22 [1] RSPM (R 4.6.0)
##  sandwich        3.1-3      2026-08-03 [1] RSPM (R 4.6.0)
##  sass            0.4.10     2025-04-11 [1] RSPM (R 4.6.0)
##  scales        * 1.4.0      2025-04-24 [1] RSPM (R 4.6.0)
##  sessioninfo     1.2.4      2026-06-04 [1] RSPM (R 4.6.0)
##  stringi         1.8.9      2026-08-04 [1] RSPM (R 4.6.0)
##  stringr         1.6.0      2025-11-04 [1] RSPM (R 4.6.0)
##  strucchange     1.6-0      2026-08-04 [1] RSPM (R 4.6.0)
##  survival        3.8-12     2026-09-09 [2] CRAN (R 4.6.2)
##  TH.data         1.1-5      2025-11-17 [1] RSPM (R 4.6.0)
##  tibble          3.3.1      2026-01-11 [1] RSPM (R 4.6.0)
##  tidyselect      1.2.1      2024-03-11 [1] RSPM (R 4.6.0)
##  TriMatch      * 1.0.2      2026-04-28 [1] RSPM (R 4.6.0)
##  usethis         3.2.2      2026-09-10 [1] RSPM (R 4.6.0)
##  vctrs           0.7.3      2026-04-11 [1] RSPM (R 4.6.0)
##  withr           3.0.3      2026-06-19 [1] RSPM (R 4.6.0)
##  xfun            0.62       2026-10-16 [1] RSPM (R 4.6.0)
##  xml2            1.6.0      2026-06-22 [1] RSPM (R 4.6.0)
##  xtable        * 1.8-8      2026-02-22 [1] RSPM (R 4.6.0)
##  yaml            2.3.12     2025-12-10 [1] RSPM (R 4.6.0)
##  zoo             1.9-1      2026-09-25 [1] RSPM (R 4.6.0)
## 
##  [1] /home/runner/work/_temp/Library
##  [2] /opt/R/4.6.2/lib/R/library
##  * ── Packages attached to the search path.
## 
## ──────────────────────────────────────────────────────────────────────────────
```


## License {.unnumbered}

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work by [Jason Bryer](https://bryer.org/) is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
