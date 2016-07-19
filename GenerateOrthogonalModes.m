function GenerateOrthogonalModes
% GENERATE THE ORTHOGONAL CLINICAL MODES
%
% This script generate the clinical orthogonal modes from the combined LV
% surfaces at ED and ES based on 6 clinical indices.
%
% This function will run interactively to ask users for specific inputs.
%
% Xingyu Zhang, Pau Medrano-Gracia, Alistair Young & Avan Suinesipautra
% University of Auckland - 2016

% get clinical_index values, ask user for input if necessary
clinical_index_file = ask_input_file('data','clinical_index.csv');
if( isempty(clinical_index_file) ), return; end

fprintf(1, 'Reading clinical index\n');
CI = importdata(clinical_index_file);
index_names = CI.textdata(1,2:end);  % get names from the header; column 1 is ignored
CI = CI.data;                        % get the numeric values

% the index order is important here
if( ~isequal(index_names, {'EDVI', 'Sphericity', 'EF', 'RWT', 'Conicity', 'LS'}) )
    error('ERROR: Invalid clinical index file.');
end

% get surface points at ED, ask user for input if necessary
pts_ED_file = ask_input_file('data','surface_points_ED.csv');
if( isempty(pts_ED_file) ), return; end

fprintf(1, 'Reading LV surface points at ED\n');
pts_ED = importdata(pts_ED_file);

% get surface points at ES, ask user for input if necessary
pts_ES_file = ask_input_file('data','surface_points_ES.csv');
if( isempty(pts_ES_file) ), return; end

fprintf(1, 'Reading LV surface points at ES\n');
pts_ES = importdata(pts_ES_file);

% combine ED & ES points into a single matrix
pts = [pts_ED pts_ES];

% calculate the mean shape and B0 vectors
mean_shape = mean(pts,1);
B0 = pts - repmat(mean_shape, size(pts,1),1);

clear('pts_ED', 'pts_ES');    % memory conservation

% ask for output directory
outdir = pwd;
fprintf(1, 'Output directory is %s\n', outdir);
yn = input('Do you want to change it [y/n]? ', 's');
if( strcmpi(yn,'y') )
    % select output directory
    outdir = uigetdir(outdir, 'Select output directory');
    if( ~ischar(outdir) )
        fprintf(2, 'User cancelled.\n');
        return;
    end
end

% number of latent variables
nlatent = input('Number of latent variables (1..10) = ');
if( nlatent<1 || nlatent>10 )
    error('ERROR: Number of latent variables must be between 1 and 10.');
end

% store modes, pc_scores
modes = zeros(size(pts,2), length(index_names));
pc_modes = zeros(size(pts,1), length(index_names));

% initial X
X = pts;

% run through all indices
tic;
for si=1:length(index_names)
    
    fprintf(1, 'STEP %d:\n', si);
    
    % calculate the mode
    fprintf(1, 'PLS regression with %d latent variables for %s\n', nlatent, index_names{si});
    % I don't need the rest, just the coefficients
    [~,~,~,~,BETA] = plsregress(X,CI(:,si),nlatent);
    
    % get the coefficients, excluding the intercept (first row)
    modes(:,si) = BETA(2:end,:);
    
    % normalize
    modes(:,si) = modes(:,si) ./ norm(modes(:,si));

    % calculate scores
    pc_scores(:,si) = pts * modes(:,si);
    
    % remove this mode and the previous mode(s) from the data
    B1 = zeros(size(B0));
    for i=1:si
        B1 = B1 + ( (B0 * modes(:,i)) * modes(:,i)' );
    end
    
    % now X is B0 - B1
    X = B0 - B1;
    
    toc;
    
end


% create outputs
fout_mode = fullfile(outdir, sprintf('ortho-modes-nlatent_%d.csv', nlatent));
fprintf(1, 'Writing modes to %s\n', fout_mode);
dlmwrite(fout_mode, modes, ',');

fout_pcs = fullfile(outdir, sprintf('ortho-pcscores-nlatent_%d.csv', nlatent));
fprintf(1, 'Writing principal scores to %s\n', fout_pcs);
dlmwrite(fout_pcs, pc_scores, ',');

end


% ---- AUX FILES ----

function fname = ask_input_file(folder, filename)

    % loop until the expected file exists or it's empty string (user cancels)
    fname = fullfile(folder,filename);
    while( ~exist(fname,'file') && ~isempty(fname) )
        
        fprintf(2, 'PLEASE SELECT A DIRECTORY THAT CONTAINS ''%s''.\n', filename);
        d = folder;
        
        % ask user the directory that contains filename
        d = uigetdir(d, sprintf('Select folder that contains ''%s''', filename));
        if( ~ischar(d) )
            fname = '';
            break;
        end
        
        fname = fullfile(d,filename);
        
    end
    
end
