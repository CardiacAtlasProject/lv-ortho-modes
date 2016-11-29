


### `clinical_index.csv`

* Size: 2291 rows, 6 columns
* Header: TRUE
* Delimiter: ','

This file contains 5 clinical indices that we used in the paper are ordered as follows:

1. EDVI = End-Diastolic Volume Index, which is End-Diastolic Volume (in ml) divided by Body Surface Area.
* Sphericity = EDV divided by the volume of a sphere with a diameter corresponding to the major axis at ED in LV long-axis view.
* EF = Ejection Fraction, which is (EDV - ESV) / EDV, where ESV = End-Systolic Volume.
* RWT = Relative Wall Thickness = twice the posterior wall thickness divided by the ED diameter.
* Conicity = the ratio of the apical diameter (defined as the diameter of the endocardium one third above the apex) over the basal diameter at ED.
* LS = Longitudinal Shortening, which is the difference of the distance of the central basal point to the apical point at ED and ES over the distance at ED.

The extra column shows labels for each row, either asymptomatic volunteers (ASYMP, n=1991) or patients with myocardial infarction (MI, n=300).

### `surface_points_ASYMP.RData` and `surface_points_MI.RData`

* Size: 1991 or 300 rows, 10092 columns

This file contains surface sample points of the LV model at ED; one for the ASYMP and the other for the MI cohorts. Each row contains one LV model that consists of 4 surfaces: endocardial and epicardial surfaces for both ED and ES frames. The coordinate points are stored as:

> [x1, y1, z1, x2, y2, z2, ..., xN, yN, zN]

in the following order: [ED-endo ED-epi ES-endo ES-epi].

To visualize a surface, you can use `plot.shape.R` function.

### `surface_face.RData`

* Size: 1595 rows, 3 columns

Contains the triangular patches for an LV surface. There are 1595 patches that contains indices of vertices. See LV surface visualization section below.

### `mean_shape.RData`

* Size: 10092 rows, 1 columns

Defines the mean shape of LV shapes from both ED (first half) and ES (second half). This data is useful to generate a clinical mode.
