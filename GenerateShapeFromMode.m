function S = GenerateShapeFromMode(M, pct, varargin)
% GENERATE SHAPE FROM MODE
% Re-generate an LV shape back from an orthogonal mode at a specified
% percentile from the model distribution.
%
%   S = GenerateShapeFromMode( M, pct, ... );
%
% Inputs: - M is a vector of orthogonal mode (10092x1).
%         - pct is the percentile number [0,100]
%
% Output: S is a matrix of 2x5046 that define the shape, i.e.
%             S[1,1:2523] = endocardium at ED
%             S[1,2524:end] = epicardium at ED
%             S[2,1:2523] = endocardium at ES
%             S[2,2524:end] = epicardium at ES
% 
% Notes:
% - M vector can be retrieved from the outputs of GenerateOrthogonalModes.m
%   See ortho-modes-nlatent_*.csv file.
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
if( numel(M)~=10092 ), error('Invalid mode vector size.'); end
if( pct<0 || pct>100 ), error('Percentile is out-of-range.'); end

% default option
opt.mean_shape = 'data/mean_shape.csv';

% get options
for i=1:2:length(varargin)
    if( isfield(opt,strcmpi(varargin{i})) )
        opt.(strcmpi(varargin{i})) = varargin{i+1};
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
S = MS(:) + (prctile(M,pct) - mean(M)) .* M(:);

% reshape
S = reshape(S, [], 2)';
