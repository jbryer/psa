### Gerber & Green Dataset used by Imai

This is the dataset used by Imai (2005) to replicate and evaluate the field experiment done by Gerber and Green (2000). The accompanying demo replicates Imai's propensity score model which is then used to estimate the causal effect of get-out-the-vote telephone calls on turnout.

This package is included with the `Matching` package:

```
data(GerberGreenImai, package='Matching')
```

A data frame with 10829 observations on the following 26 variables.

* `PERSONS` - Number persons in household
* `WARD` - Ward of residence
* `QUESTION` - Asked to commit to voting
* `MAILGRP` - Sent mail
* `PHONEGRP` - Phone batch #1
* `PERSNGRP` - Personal contact attempted
* `APPEAL` - Content of message
* `CONTACT` - Personal contact occurred
* `MAILINGS` - Number of mailings sent
* `AGE` - Age of respondent
* `MAJORPTY` - Democratic or Republican
* `VOTE96.0` - Abstained in 1996
* `VOTE96.1` - Voted in 1996
* `MAILCALL` - Phone batch #2
* `VOTED98` - Voted in 1998
* `PHNSCRPT` - Script read to phone respondents
* `DIS.MC` - Contacted by phone in batch \#2
* `DIS.PHN` - Contacted by phone in batch \#1
* `PHN.C` - Contacted by phone
* `PHNTRT1` - Phone contact attempted (no blood or blood/civic)
* `PHNTRT2` - Phone contact attempted (no blood)
* `PHN.C1` - Contact occurred in phntrt1
* `PHN.C2` - Contact occurred in phntrt2
* `NEW` - New voter
* `phone` - Contacted by phone
* `AGE2` - Age squared

The demo provided, entitled GerberGreenImai, uses Imai's propensity score model to estimate the causal effect of get-out-the-vote telephone calls on turnout. The propensity score model fails to balance age.

#### References

Gerber, Alan S. and Donald P. Green. 2000. “The Effects of Canvassing, Telephone Calls, and Direct Mail on Voter Turnout: A Field Experiment.” American Political Science Review 94: 653-663.

Gerber, Alan S. and Donald P. Green. 2005. “Correction to Gerber and Green (2000), replication of disputed findings, and reply to Imai (2005).” American Political Science Review 99: 301-313.

Imai, Kosuke. 2005. “Do Get-Out-The-Vote Calls Reduce Turnout? The Importance of Statistical Methods for Field Experiments.” American Political Science Review 99: 283-300.

Hansen, Ben B. Hansen and Jake Bowers. forthcoming. “Attributing Effects to a Cluster Randomized Get-Out-The-Vote Campaign.” Journal of the American Statistical Association.
