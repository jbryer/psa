## Multilevel PSA

require(multilevelPSA)

data(pisana)
data(pisa.colnames)
data(pisa.psa.cols)
str(pisana)

table(pisana$CNT, pisana$PUBPRIV, useNA='ifany')
prop.table(table(pisana$CNT, pisana$PUBPRIV, useNA='ifany'), 1) * 100

## Phase I
#Use conditional inference trees from the party package
mlctree <- mlpsa.ctree(pisana[,c('CNT','PUBPRIV',pisa.psa.cols)], 
					   formula=PUBPRIV ~ ., level2='CNT')
pisana.party <- getStrata(mlctree, pisana, level2='CNT')

#Tree heat map showing relative importance of covariates used in each tree.
tree.plot(mlctree, level2Col=pisana$CNT, 
		  colLabels=pisa.colnames[,c('Variable','ShortDesc')])

#NOTE: This is not entirely correct but is sufficient for visualization purposes
#      See mitools package for combining multiple plausible values.
pisana.party$mathscore <- apply(pisana.party[,paste0('PV',1:5,'MATH')],1,sum)/5
pisana.party$readscore <- apply(pisana.party[,paste0('PV',1:5,'READ')],1,sum)/5
pisana.party$sciescore <- apply(pisana.party[,paste0('PV',1:5,'SCIE')],1,sum)/5

## Phase II
results.psa.math <- mlpsa(response=pisana.party$mathscore, 
						  treatment=pisana.party$PUBPRIV, 
						  strata=pisana.party$strata, 
						  level2=pisana.party$CNT, minN=5)
summary(results.psa.math)
ls(results.psa.math)

results.psa.math$level2.summary[,c('level2','n','Private','Private.n','Public',
								   'Public.n','diffwtd','ci.min','ci.max','df')]
View(results.psa.math$level2.summary)
results.psa.math$overall.ci

# These are the two main plots
plot(results.psa.math)
mlpsa.difference.plot(results.psa.math)
# Specifying sd (the standard deviation) effect sizes will be plotted.
mlpsa.difference.plot(results.psa.math, sd=sd(pisana.party$mathscore))

# Or the individual components of the main plot separately
mlpsa.circ.plot(results.psa.math, legendlab='Country')
mlpsa.distribution.plot(results.psa.math, 'Public')
mlpsa.distribution.plot(results.psa.math, 'Private')
