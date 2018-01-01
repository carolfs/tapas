function [data] = tapas_sem_load_example_data()
%% Load example data. 
%
% Input
%
% Output
%   Data structure.
%

% aponteeduardo@gmail.com
% copyright (C) 2018
%

f = mfilename('fullpath');
[tdir, ~, ~] = fileparts(f);

% Files are delimited with a tab and skip the header
data = dlmread(fullfile(tdir, 'data', 'sbj02.csv'), '\t', 1, 0);

end
