### Lalonde Dataset

Dataset used by Dehejia and Wahba (1999) to evaluate propensity score matching.

This dataset is included with the `Matching` package:

```
data(lalonde, package='Matching')
```

A data frame with 445 observations on the following 12 variables.

* `age` - age in years.
* `educ` - years of schooling.
* `black` - indicator variable for blacks.
* `hisp` - indicator variable for Hispanics.
* `married` - indicator variable for martial status.
* `nodegr` - indicator variable for high school diploma.
* `re74` - real earnings in 1974.
* `re75` - real earnings in 1975.
* `re78` - real earnings in 1978.
* `u74` - indicator variable for earnings in 1974 being zero.
* `u75` - indicator variable for earnings in 1975 being zero.
* `treat` - an indicator variable for treatment status.

##### References

Dehejia, Rajeev and Sadek Wahba. 1999.“Causal Effects in Non-Experimental Studies: Re-Evaluating the Evaluation of Training Programs.” Journal of the American Statistical Association 94 (448): 1053-1062.

LaLonde, Robert. 1986. “Evaluating the Econometric Evaluations of Training Programs.” American Economic Review 76:604-620.
