function S = GenerateShape(remodelling_component, remodelling_score, pct, varargin)
% GENERATE SHAPE FROM A REMODELLING COMPONENT
% Re-generate an LV shape back from an orthogonal mode at a specified
% percentile from the model distribution.
%
%   S = GenerateShape( remodelling_component, remodelling_score, pct, ... );
%
% Inputs: - remodelling_component is a vector of remodelling component (10092x1).
%         - remodelling_score is a vector of projection of input shapes to the modes (2291x1).
%         - pct is the percentile number [0,100]
%
% Output: S is a matrix of 2x5046 that define the shape, i.e.
%             S[1,1:2523] = endocardium at ED
%             S[1,2524:end] = epicardium at ED
%             S[2,1:2523] = endocardium at ES
%             S[2,2524:end] = epicardium at ES
% 
% Notes:
% - remodelling component and scores can be retrieved from the outputs of GenerateOrthogonalModes.m
%   See ortho-components-nlatent_*.csv and ortho-scores-nlatent_%.csv files.
% - Shape vectors are defined as [x1 y1 z1 x2 y2 z2 ... xN yN zN] Cartesian
%   coordinate values.
%
% Optional arguments:
%   - 'mean_shape', filename or the mean shape vector.
%     Default is 'data/mean_shape.csv'. This defines the mean shape vector,
%     which is 10092x1 size.
%
% Author: Avan Suinesiaputra - University of Auckland (2016)

% check the input arguments
if( numel(remodelling_component)~=10092 ), error('Invalid component vector size.'); end
if( numel(remodelling_score)~=2291 ), error('Invalid score vector size.'); end
if( pct<0 || pct>100 ), error('Percentile is out-of-range.'); end

% default option
opt.mean_shape = 'data/mean_shape.csv';

% get options
for i=1:2:length(varargin)
    if( isfield(opt,lower(varargin{i})) )
        opt.(lower(varargin{i})) = varargin{i+1};
    else
        error('Unknown option.');
    end
end

% read mean_shape
if( ischar(opt.mean_shape) )
    if( ~exist(opt.mean_shape,'file') ), error('Mean shape %s does not exist', opt.mean_shape); end
    MS = importdata(opt.mean_shape);
else
    MS = opt.mean_shape;
end
if( numel(MS)~=10092 ), error('Invalid mean shape.'); end

% generate
S = MS(:) + (prctile(remodelling_score,pct) - mean(remodelling_score)) .* remodelling_component(:);

% reshape
S = reshape(S, [], 2)';
