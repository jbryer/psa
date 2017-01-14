


Randomized Experiments
========================================================

The randomized experiment has been the goals standard for estimating causal effects. Effects can be estimated using simple means between groups, or blocks in randomized block design. Randomization presumes unbiasedness and balance between groups. However, randomization is often not feasible for many reasons, especially in educational contexts.

The strong ignorability assumtion states that an outcome is independent of any observed or unobserved covariates under randomization. This is represented mathematically as:

$$({ Y }\_{ i }(1),{ Y }\_{ i }(0)) \; \bot \; { T }\_{ i }|{ X }\_{ i }=x$$

For all \\( {X}_{i} \\)

Therefore, it follows that the causal effect of a treatment is the difference in an individual’s outcome under the situation they were given the treatment and not (referred to as a counterfactual).

$${\delta}\_{i} = { Y }\_{ i1 }-{ Y }\_{ i0 }$$

However, it is impossible to directly observe \\({\delta}_{i}\\) (referred to as The Fundamental Problem of Causal Inference, Holland 1986). Rubin framed this problem as a missing data problem.


