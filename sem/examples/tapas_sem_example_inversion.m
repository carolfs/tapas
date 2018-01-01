function [results] = tapas_sem_example_inversion(model, parametric)
%% Test 
%
% fp -- Pointer to a file for the test output, defaults to 1
%
% aponteeduardo@gmail.com
% copyright (C) 2015
%

n = 0;

n = n + 1;
if nargin < n
    model = 2;
end

n = n + 1;
if nargin < n
    parametric = 'invgamma';
end

[y, u] = prepare_data();

% Parameter of the mcmc algorithm
pars = struct();

pars.T = linspace(0.1, 1, 4).^5; % Defines the number of temperatures (16)
pars.nburnin = 2000; % Number of samples in the burn in phase
pars.niter = 2000; % Number of samples
pars.kup = 100; % Number of samples drawn before diagnosis
pars.mc3it = 4; % Number of swaps between the cahins
pars.verbose = 1; % Level of verbosity
pars.samples = 1; % Store the samples

if model == 1
    fprintf(1, 'Prosa inversion\n')

    switch parametric
        case 'gamma'
            ptheta = tapas_sem_prosa_gamma_ptheta(); 
        case 'invgamma'
            ptheta = tapas_sem_prosa_invgamma_ptheta();
        case 'wald'
            ptheta = tapas_sem_prosa_wald_ptheta();
        case 'mixedgamma'
            ptheta = tapas_sem_prosa_mixed_ptheta();
        case 'later'
            ptheta = tapas_sem_prosa_later_ptheta();
        case 'lognorm'
            ptheta = tapas_sem_prosa_lognorm_ptheta();
        otherwise
            error('tapas:sem:example', 'unknown parametric');
    end

    % In most situations this does not need to be changed.
    htheta = tapas_sem_prosa_htheta();

    % This is the projection matrix that fixes the parameters across trial
    % types.
    ptheta.jm = [eye(15) 
        zeros(3, 6) eye(3) zeros(3, 6)];

end

if model == 2
    fprintf(1, 'Seri inversion\n')
    switch parametric
        case 'gamma'
            ptheta = tapas_sem_seri_gamma_ptheta(); 
        case 'invgamma'
            ptheta = tapas_sem_seri_invgamma_ptheta();
        case 'wald'
            ptheta = tapas_sem_seri_wald_ptheta();
        case 'mixedgamma'
            ptheta = tapas_sem_seri_mixed_ptheta();
        case 'later'
            ptheta = tapas_sem_seri_later_ptheta();
        case 'lognorm'
            ptheta = tapas_sem_seri_lognorm_ptheta();
        otherwise
            error('tapas:sem:example', 'unknown parametric');
    end
    htheta = tapas_sem_seri_htheta();
    % The same parameters are used in pro and antisaccade trials
    ptheta.jm = [...
        eye(19)
        zeros(3, 8) eye(3) zeros(3, 8)];
end

if model == 3

    fprintf(1, 'Dora inversion\n');

    switch parametric
        case 'gamma'
            ptheta = tapas_sem_dora_gamma_ptheta(); 
        case 'invgamma'
            ptheta = tapas_sem_dora_invgamma_ptheta();
        case 'wald'
            ptheta = tapas_sem_dora_wald_ptheta();
        case 'mixedgamma'
            ptheta = tapas_sem_dora_mixed_ptheta();
        case 'later'
            ptheta = tapas_sem_dora_later_ptheta();
        case 'lognorm'
            ptheta = tapas_sem_dora_lognorm_ptheta();
        otherwise
            error('tapas:sem:example', 'unknown parametric');
    end

    htheta = tapas_sem_dora_htheta();
    % The same parameters are used in pro and antisaccade trials
    ptheta.jm = [...
        eye(19)
        zeros(3, 8) eye(3) zeros(3, 8)];

end

results = tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function [y, u] = prepare_data()
%% Prepares the test data

NDTIME = 100;

f = mfilename('fullpath');
[tdir, ~, ~] = fileparts(f);

% Files are delimited with a tab and skip the header
d = dlmread(fullfile(tdir, 'data', 'sbj02.csv'), '\t', 1, 0);

%Filter out unreasonably short reactions

nt = size(d, 1);

y = struct('t', [], 'a', [], 'b', []);

% Subject and block
u.s = d(:, 1);
u.b = d(:, 2);

% Invalid trials are shorter than 100 ms
y.i = d(:, 7) < NDTIME;
% Shift and rescale the data
y.t = d(:, 7)/100;

% Is it a prosaccade or an antisaccade
lr = zeros(nt, 1);
% Saccade to the left
lr(d(:, 6) < 640) = 1;
% Up to hear prosaccades are 1 and antisaccades are 0
y.a = lr == d(:, 5);
y.a = double(y.a);

u.tt = d(:, 4);

% Matlab and python conventions don't aggree

t0 = y.a == 0;
t1 = y.a == 1;

y.a(t0) = 1;
y.a(t1) = 0;

t0 = u.tt == 0;
t1 = u.tt == 1;
                      

y.a = y.a(~y.i);
y.t = y.t(~y.i);

u.s = u.s(~y.i);
u.b = u.b(~y.i);
u.tt = u.tt(~y.i);

y.i = y.i(~y.i);

end
