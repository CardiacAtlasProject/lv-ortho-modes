This directory contains necessary data files, Matlab and R script files used to calculate and visualize the clinical orthogonal modes from Left Ventricular (LV) models.

# Requirements

1. Matlab (http://www.mathworks.com)
1. Statistics and Machine Learning Matlab Toolbox

# Data

## `clinical_index.csv`

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

## `surface_points_ED.csv`

* Size: 2291 rows, 5046 columns
* Header: FALSE
* Delimiter: ','

This file contains surface sample points of the LV model at ED. There are 2291 rows that match with rows in `clinical_index.csv` file. Each row contains one LV model that consists of 2 surfaces: endocardial and epicardial surfaces. The coordinate points are stored as:

> [x1, y1, z1, x2, y2, z2, ..., xN, yN, zN]

where the first half is for endocardium, and the last half is for epicardium.

To visualize a surface, you need `surface_face.csv` file.

## `surface_points_ES.csv`

* Size: 2291 rows, 5046 columns
* Header: FALSE
* Delimiter: ','

Defines the surface sample points of the LV model at ES. See `surface_points_ED.csv` description above.

## `surface_face.csv`

* Size: 1595 rows, 3 columns
* Header: FALSE
* Delimiter: ','

Contains the triangular patches for an LV surface. There are 1595 patches that contains indices of vertices. See LV surface visualization section below.

## `mean_shape.csv`

* Size: 10092 rows, 1 columns
* Header: FALSE
* Delimiter: ','

Defines the mean shape of LV shapes from both ED (first half) and ES (second half). This data is useful to generate a clinical mode (see Visualizing a clinical mode section).

# Visualizing an LV model

You need a surface point vector (size = 5046 elements) and surface patches (defined by `surface_face.csv` file).

Note that the vector contains 2 surfaces. Hence index 1:2523 are for endocardium and index 2524:5046 are for epicardium. The number of points are then 2523/3=841 points per surface.

```matlab
% Load points and faces
ptsED = importdata('surface_points_ED.csv');
face = importdata('surface_face.csv');

% Visualize LV shape from subject #5
P = ptsED(5,:);
figure;
patch('Faces', face, 'Vertices', reshape(P(1:2523), 3, [])', 'FaceColor', 'r', 'FaceAlpha', 0.2);
hold on;
patch('Faces', face, 'Vertices', reshape(P(2524:end), 3, [])', 'FaceColor', 'b', 'FaceAlpha', 0.2);
axis equal;
```

# Generating modes

Run:

```matlab
>> GenerateOrthogonalModes;
```

The outputs are:
* `ortho-modes-nlatent_DD.csv`, where DD is the number of latent variables you specified. It contains six columns of modes without header, where columns are the same as `clinical_index.csv` columns.
* `ortho-pcscores-nlatent_DD.csv`, where DD is the number of latent variables you specified. It contains the principal scores with the same number of columns as the modes.

# Visualizing a clinical mode

Use `GenerateShapeFromMode.m` file.

For example, we want to generate clinical mode of relative wall thickness (RWT) at 10th percentile from the model distribution:

```matlab
% read the output orthogonal mode files
modes = importdata('modes/ortho-modes-nlatent_1.csv');

% generate a shape based on clinical mode #4 (RWT) at 10th percentile
S = GenerateShapeFromMode( modes(:,4), 10 );

% read patches for visualization
face = importdata('data/surface_face.csv');

% visualize the ED
figure('Name', 'RWT mode at ED pct=10');
patch('Faces',face, 'Vertices', reshape(S(1,1:2523),3,[])', 'FaceColor', 'r', 'FaceAlpha', 0.2);
hold on;
patch('Faces',face, 'Vertices', reshape(S(1,2524:end),3,[])', 'FaceColor', 'b', 'FaceAlpha', 0.2);
axis equal;

% visualize the ES
figure('Name', 'RWT mode at ES pct=10');
patch('Faces',face, 'Vertices', reshape(S(2,1:2523),3,[])', 'FaceColor', 'r', 'FaceAlpha', 0.2);
hold on;
patch('Faces',face, 'Vertices', reshape(S(2,2524:end),3,[])', 'FaceColor', 'b', 'FaceAlpha', 0.2);
axis equal;
```

# Interactive visualization
