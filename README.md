# Left Ventricular Orthogonal Clinical Modes

This directory contains necessary data files, Matlab and R script files used to calculate and visualize the clinical remodelling components from Left Ventricular (LV) models.

More information: https://www.cardiacatlas.org/left-ventricle-clinical-modes/

## Requirements

1. Matlab (http://www.mathworks.com)
1. Statistics and Machine Learning Matlab Toolbox

## Generating remodelling components

To generate remodelling components with nlatent=1, run:

```matlab
>> [comps, scores] = GenerateOrthogonalModes('./data/', 1, './output/');
```

If the last argument, which is the output directory, is given, then the outputs are:
* `ortho-components-nlatent_DD.csv`, where DD is the number of latent variables you specified. It contains six columns of components without header, where columns are the same as `clinical_index.csv` columns.
* `ortho-scores-nlatent_DD.csv`, where DD is the number of latent variables you specified. It contains the projections with the same number of columns as the components.

## Visualizing a remodelling component

Use `GenerateShapeFromMode.m` file.

For example, we want to generate a remodelling component of relative wall thickness (RWT) at 10th percentile from the model distribution:

```matlab
% read the output orthogonal mode files
components = importdata('output/ortho-components-nlatent_1.csv');
scores = importdata('output/ortho-scores-nlatent_1.csv');

% generate a shape based on clinical mode #4 (RWT) at 10th percentile
S = GenerateShape( components(:,4), scores(:,4), 90 );

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

## Interactive visualization

Run:

```matlab
>> OrthogonalModeViewer( './data/', 1 );
```

Arguments are the data directory and the number of latent variables.
