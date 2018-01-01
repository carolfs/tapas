function [tests] = test_tapas_sem_dora()
%% Test 
%

% aponteeduardo@gmail.com
% copyright (C) 2018
%

tests = functiontests(localfunctions);

end


function setupOnce(testCase)

NDTIME = 100;

data = tapas_sem_load_example_data();

%Filter out unreasonably short reactions

nt = size(data, 1);

y = struct('t', [], 'a', [], 'b', []);

% Subject and block
u.s = data(:, 1);
u.b = data(:, 2);

% Invalid trials are shorter than 100 ms
y.i = data(:, 7) < NDTIME;
% Shift and rescale the data
y.t = data(:, 7)/100;

% Is it a doraccade or an antisaccade
lr = zeros(nt, 1);
% Saccade to the left
lr(data(:, 6) < 640) = 1;
% Up to hear doraccades are 1 and antisaccades are 0
y.a = lr == data(:, 5);
y.a = double(y.a);

u.tt = data(:, 4);

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

testCase.TestData.data = struct('y', y, 'u', u);

testCase.TestData.htheta = tapas_sem_dora_htheta();

testCase.TestData.jm = [eye(15)
    zeros(3, 6) eye(3) zeros(3, 6)];

pars = struct();

pars.T = linspace(0.1, 1, 4).^5;
pars.nburnin = 500;
pars.niter = 500;
pars.kup = 100;
pars.mc3it = 4;
pars.verbose = 1;

testCase.TestData.pars = pars;

end

function teardownOnce(testCase)

end

function setup(testCase)

end

function teardown(testCase)

end

function test_basic_invgamma(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_invgamma_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;
tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function test_basic_wald(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_wald_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;

tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function test_basic_mixedgamma(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_mixedgamma_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;

tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function test_basic_gamma(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_gamma_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;

tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function test_basic_lognorm(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_lognorm_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;

tapas_sem_estimate(y, u, ptheta, htheta, pars);

end

function test_basic_later(testCase)

y = testCase.TestData.data.y;
u = testCase.TestData.data.u;
pars = testCase.TestData.pars;
htheta = testCase.TestData.htheta;

ptheta = tapas_sem_dora_later_ptheta(); % Choose at convinience.
%ptheta.jm = testCase.TestData.jm;

tapas_sem_estimate(y, u, ptheta, htheta, pars);

end




