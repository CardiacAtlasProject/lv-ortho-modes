


This project stores R codes to generate orthogonal basis vectors from a set of 3D Left Ventricular (LV) shapes. Each basis vector is aligned to the direction of maximum variance from a clinical measurement.

More information see: https://www.cardiacatlas.org/left-ventricle-clinical-modes/

## Generating the modes

There are two sets of LV shapes in the `data` folder. Example below shows how to generate the orthogonal clinical remodelling components using ASYMPTOMATIC LV shapes.


```r
library(dplyr)
source('generate.ortho.modes.R')

# read the data, this will load X.ASYMP variable
load('data/surface_points_ASYMP.RData')

# read the clinical variables, select only ASYMP shapes
CI = read.csv('data/clinical_index.csv', header=TRUE) %>%
  filter(Group=="ASYMP") %>%
  select(EDVI,Sphericity,EF,RWT,Conicity,LS)
  
# compute modes with number of component = 1
ortho = generate.ortho.modes(X.ASYMP, CI, M=1)
```

The output `ortho` is a list that contains:
* `remodelling_components`, which are are the orthogonal unit vectors
* `remodelling_scores`, which are the projections of the data to the basis vectors

We can verify if the components are orthogonal

```r
t(ortho$remodelling_components) %*% ortho$remodelling_components
```

```
##                EDVI Sphericity      EF      RWT Conicity       LS
## EDVI        1.0e+00    1.6e-15 1.7e-14  7.8e-15 -9.0e-15 -4.4e-15
## Sphericity  1.6e-15    1.0e+00 7.2e-15  2.1e-18 -5.5e-15 -1.1e-15
## EF          1.7e-14    7.2e-15 1.0e+00  1.3e-14  1.0e-14  3.1e-14
## RWT         7.8e-15    2.1e-18 1.3e-14  1.0e+00 -3.7e-15 -5.0e-15
## Conicity   -9.0e-15   -5.5e-15 1.0e-14 -3.7e-15  1.0e+00 -2.4e-14
## LS         -4.4e-15   -1.1e-15 3.1e-14 -5.0e-15 -2.4e-14  1.0e+00
```

## Remodelling components of shape variation

A *remodellign component of shape variation* is a visualization of a shape that is generated from a model by using only one component. If there are K components, the i-th mode of shape variation is given by: x = mean_shape + lambda_i \* B_i, where *B_i* is the i-th column of the component matrix and *lambda_i* is a constant. The value of *lambda_i* is usually computed from the distribution of i-th scores.

For example, if we want to visualize the Tukey's five number summaries (minimum, lower-hinge, median, upper-hinge, and maximum) from the Ejection Fraction (EF) mode, then

```r
source('plot.shape.R')

# compute the mean shape
mean.shape = colMeans(X.ASYMP)

# compute the lambda coefficients - use R's fivenum function
lambdas = fivenum(ortho$remodelling_scores[,"EF"]) - mean(ortho$remodelling_scores[,"EF"])

# generate the remodelling_modes of EF shape variations
S = matrix(1, nrow=length(lambdas), ncol=1) %*% mean.shape + 
  matrix(lambdas, ncol=1) %*% matrix(ortho$remodelling_components[,"EF"],nrow=1)
```

Plotting the remodelling modes

```r
# get points for ED and ES surfaces
pts.ed = 1:(length(mean.shape)/2)
pts.es = (1+length(mean.shape)/2):length(mean.shape)

# plot it with rgl library
library(rgl)

mfrow3d(2, length(lambdas), sharedMouse = TRUE, byrow = FALSE)
for( i in 1:length(lambdas) ) 
{
  plot.shape(S[i, pts.ed], new.plot = FALSE)
  next3d()
  plot.shape(S[i, pts.es], new.plot = FALSE)
  if( i < length(lambdas) ) { next3d() }
}
rglwidget()
```

![Tukey's summary for Ejection Fraction modes](fivenum-EF-ASYMP-mode.png)
