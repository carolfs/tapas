function [ptheta] = tapas_sem_prosa_ptheta()
%% Returns the standard priors of the model.
%
% Input 
%
% Output
% ptheta -- Structure containing the priors. The prior distribution is assumed
%           to be log Gaussian, so that the prior are the means and covariance
%           matrix. It is assumed that the covariance is diagonal so only the
%           eigenvalues are returned. ptheta.jm is a projection matrix. It can
%           be replaced with a rank deficient matrix in order to project the 
%           samples to a lower dimensional space.

%
% aponteeduardo@gmail.com
% copyright (C) 2015
%

dim_theta = tapas_sem_prosa_ndims();
[ptheta] = tapas_sem_prosa_gaussian_priors();

% Projection matrix

% Likelihood function and priors

ptheta.name = '';
ptheta.llh = @tapas_sem_optimized_llh;
ptheta.lpp = @tapas_sem_prosa_lpp;
ptheta.method = []; 
ptheta.prepare = @tapas_sem_prepare_gaussian_ptheta;
ptheta.sample_priors = @tapas_sem_sample_gaussian_uniform_priors;
ptheta.ndims = dim_theta; 
ptheta.npars = 2; % It has two sets of parameters.
ptheta.jm = kron(eye(ptheta.npars), eye(dim_theta));


% Transformation of the parameters

ptheta.ptrans = @(x) x;

end
