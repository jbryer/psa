### Data on 996 initial Percutaneous Coronary Interventions (PCIs) performed in 1997 at the Lindner Center, Christ Hospital, Cincinnati.

Data from an observational study of 996 patients receiving a PCI at Ohio Heart Health in 1997 and followed for at least 6 months by the staff of the Lindner Center. This is a landmark dataset in the literature on propensity score adjustment for treatment selection bias due to practice of evidence based medicine; patients receiving abciximab tended to be more severely diseased than those who did not receive a IIb/IIIa cascade blocker.

This package is included with the `PSAgraphics` package:

```
data(lindner, package='PSAgraphics')
```

A data frame with 996 observations on the following 10 variables, no NAs.

* `lifepres` - Mean life years preserved due to survival for at least 6 months following PCI; numeric value of either 11.4 or 0.
* `cardbill` - Cardiac related costs incurred within 6 months of patient's initial PCI; numeric value in 1998 dollars; costs were truncated by death for the 26 patients with lifepres == 0.
* `abcix` - Numeric treatment selection indicator; 0 implies usual PCI care alone; 1 implies usual PCI care deliberately augmented by either planned or rescue treatment with abciximab.
* `stent` - Coronary stent deployment; numeric, with 1 meaning YES and 0 meaning NO.
* `height` - Height in centimeters; numeric integer from 108 to 196.
* `female` - Female gender; numeric, with 1 meaning YES and 0 meaning NO.
* `diabetic` - Diabetes mellitus diagnosis; numeric, with 1 meaning YES and 0 meaning NO.
* `acutemi` - Acute myocardial infarction within the previous 7 days; numeric, with 1 meaning YES and 0 meaning NO.
* `ejecfrac` - Left ejection fraction; numeric value from 0 percent to 90 percent.
* `ves1proc` - Number of vessels involved in the patient's initial PCI procedure; numeric integer from 0 to 5.

#### Source

Package USPS, by R. L. Obenchain.
