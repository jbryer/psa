utils::globalVariables(c('grid.layout','grid.newpage','pushViewport','viewport',
						 'align.plots','index','covariate','value','percent',
						 'std.estimate','Covariate','p.value','ci.min','ci.max',
						 'xmin', 'xmax', 'xmid', 'se'))

#' Applied Propensity Score Analysis with R
#' 
#' @name psa-package
#' @title Applied Propensity Score Analysis with R
#' @author \email{jason@@bryer.org}
#' @keywords package psa matching propensity score analysis
#' @import ggplot2
#' @import grid
#' @import reshape2
#' @import dplyr
#' @import Matching
#' @import MatchIt
#' @import shiny
#' @importFrom psych describe describeBy
#' @importFrom plyr llply
#' @importFrom cowplot plot_grid
#' @importFrom stats binomial density fitted fivenum glm median model.matrix quantile sd t.test
#' @import mice
"_PACKAGE"

#' Student data file.
#' 
#' @name students
#' @docType data
#' @format a data frame with 374 observations of 17 variables.
#' @keywords datasets
"students"

#' Data from a study examining the effects of tutoring on English grades.
#' 
#' @name tutoring
#' @docType data
#' @format a data frame with 1,381 observations of 17 variables.
#' @keywords datasets
"tutoring"

#' Number of articles related to propensity score analysis in the Web of Science
#' and Google Scholar database.
#' 
#' @name psa_citations
#' @docType data
#' @format a data frame with 92 observations of 4 variables.
#' @keywords datasets
"psa_citations"

#' Twin US births in 1989-1991.
#' 
#' This dataset contains twin births from 1980 to 1991. It is based on the Albond, Chay, and Lee (2005) paper
#' on the effects of low birth weight. The full data dictionary is available here: 
#' <https://data.nber.org/lbid/docs/LinkCO89Guide.pdf>
#' 
#' @format a data.frame with 71,345 observations of 58 variables.
#' \describe{
#'    \item{dbirwt_0, dbirwt_1}{includes the birth weights in grams of both twins in the pair}
#'    \item{mort_0, mort_1}{includes the mortality outcome for both twins}
#'    \item{adequacy}{adequacy of care}
#'    \item{alcohol}{risk factor, alcohol use}
#'    \item{anemia}{risk factor, Anemia}
#'    \item{birattnd}{medical person attending birth}
#'    \item{birmon}{birth month Jan-Dec}
#'    \item{bord_0}{birth order of lighter twin}
#'    \item{bord_1}{birth order of heavier twin}
#'    \item{brstate}{state of residence NCHS}
#'    \item{brstate_reg}{US census region of brstate}
#'    \item{cardiac}{risk factor, Cardiac}
#'    \item{chyper}{risk factor, Hypertension, chronic}
#'    \item{cigar6}{num of cigarettes /day, quantiled}
#'    \item{crace}{race of child}
#'    \item{csex}{sex of child}
#'    \item{data_year}{year: 1989, 1990 or 1991}
#'    \item{dfageq}{octile age of father}
#'    \item{diabetes}{risk factor, Diabetes}
#'    \item{dlivord_min}{number of live births before twins}
#'    \item{dmar}{married}
#'    \item{drink5}{num of drinks /week, quantiled}
#'    \item{dtotord_min}{total number of births before twins}
#'    \item{eclamp}{risk factor, Eclampsia}
#'    \item{feduc6}{education category}
#'    \item{frace}{dad race}
#'    \item{gestat10}{gestation 10 categories}
#'    \item{hemo}{risk factor Hemoglobinopathy}
#'    \item{herpes}{risk factor, Herpes}
#'    \item{hydra}{risk factor Hvdramnios/Oliqohvdramnios}
#'    \item{incervix}{risk factor, Incompetent cervix}
#'    \item{infant_id_0}{infant id of lighter twin in original df}
#'    \item{infant_id_1}{infant id of heavier twin in original df}
#'    \item{lung}{risk factor, Lung}
#'    \item{mager8}{mom age}
#'    \item{meduc6}{mom education}
#'    \item{mplbir}{mom place of birth}
#'    \item{mplbir_reg': US census region of mplbir}
#'    \item{mpre5}{trimester prenatal care begun, 4 is none}
#'    \item{mrace}{mom race}
#'    \item{nprevistq}{quintile number of prenatal visits}
#'    \item{orfath}{dad hispanic}
#'    \item{ormoth}{mom hispanic}
#'    \item{othermr}{risk factor, Other Medical Risk Factors}
#'    \item{phyper}{risk factor, Hypertension, preqnancy-associated}
#'    \item{pldel}{place of delivery}
#'    \item{pre4000}{risk factor, Previous infant 4000+ grams}
#'    \item{preterm}{risk factor, Previos pre-term or small}
#'    \item{renal}{risk factor, Renal disease}
#'    \item{rh}{risk factor, RH sensitization}
#'    \item{stoccfipb}{state of occurence FIPB}
#'    \item{stoccfipb_reg}{US census region of stoccfipb}
#'    \item{tobacco}{risk factor, tobacco use}
#'    \item{uterine}{risk factor, Uterine bleeding}
#' }
#' @references Almond, D., Chay, K.Y, & Lee, D.S. (2005). The costs of low birth weight. *The Quarterly Journal of 
#'             Economics, 120*(3), 1031-1083.
#' @source <https://www.nber.org/research/data/linked-birthinfant-death-cohort-data>
"twins"