# README

aponteeduardo@gmail.com
copyright (C) 2015-2017

# The SERIA model

The [SERIA model](http://www.biorxiv.org/content/early/2017/06/08/109090)
is a formal statistical model of the probability of a 
pro- or antisaccade and its reaction time. The currente toolbox includes an 
inference method based on the Metropolis-Hasting algorithm implemented in
MATLAB.

After installation (see below), you can run an example using

~~~~
tapas_init();
tapas_sem_example_invesion(1);
~~~~

This will load data and estimate parameters. The data consists
of a list of trials with trial type (pro or antisaccade), the
action performed (pro or antisaccade) and the reaction time. 

You can use the file `sem/examples/tapas_sem_example_inversion.m`
as a template to run your analysis.

For more detailed information see


## As a python package

This toolbox can be installed as python package. Although no inference
algorithm is currently included, it can be potentially used in combination
with packages implementing maximum likelihood estimators or the 
Metropolis-Hasting algorithm. After installation it can be imported as
~~~~
from tapas/sem/antisaccades import likelihoods as seria
~~~~
This contains all the models described in the original
[SERIA paper](http://www.biorxiv.org/content/early/2017/06/08/109090).

# Installation

## Supported platforms

Mac and linux platforms are supported. We have tested a variaty of setups
and it has worked so far. If you have any issue please contact us.

In OSX, currently we do not support openmp as clang doesn't directly support
it. Although it is still possible to use openmp, it is not trivial.

We do not support Windows but most likely it can be installed as a python 
package.

## Dependencies

* gsl/1.16

In Ubuntu, it can be install as 
~~~~
sudo apt-get install libgsl0-dev
~~~~
To install in mac you will need to install gsl
~~~~
brew install gsl
brew install clang-omp 
~~~~
Or alternatively using mac ports.
~~~~
sudo port install gsl
~~~~

## Matlab package

You will need a running matlab 
installation. In particular, the command line command  `matlab` should be able
to trigger matlab. The reason is that matlab is used to find out the 
matlabroot directory during the configuration. Make sure
that matlab can be triggered from the command line AND that it is not an
alias.

### Linux
To install the package it should be enough to go to
~~~~
tapas/sem/src/
~~~~
and type
~~~~
./configure && make
~~~~
The most likely problems you could face are the following:

#### Something with automake or aclocal.
In that case please install automake,f.e.,
~~~~
sudo apt-get install automake
~~~~
Then type
~~~~
autoreconf -ifv
~~~~
Then try again
~~~~
configure && make
~~~~

### Mac

This follows the same process than linux.

Most likely config will fail for one of the following reasons.

#### Has config found gls's header? 

Often after installation, the compiler fails to find gsl's headeers.
~~~~
export C_INCLUDE_PATH="$C_INCLUDE_PATH:/opt/local/include"
export CFLAGS="-I:/opt/local/include $CFLAGS"
configure && make
~~~~

#### Has config found gls's libraries? 

If not type
~~~~
export LDFLAGS="$LDFLAGS -L/opt/local/lib/ -L/usr/local/lib"
configure && make
~~~~
#### Has config found matlab?
If not, find the path of matlab and type
~~~~
export PATH=$PATH:your-matlab-path
configure && make
~~~~

## Python Package

This toolbox can be install as an usual python package using
~~~~
sudo python setup.py install 
~~~~
If you lack sudo rights or prefer not install it this way use
~~~~
python setup.py install --user
~~~~
Requirements can be installed using
~~~~
pip install -r requirements.txt
~~~~

# Results

In order to estimate the parameters of the model and the free energy, 
the code uses the Metropolis-Hasting algorith in combination with a few 
different other methods.

The function `tapas_sem_estimate.m` returns an estimated model. This
is structure with the following fields
* `pE`: Posterior expected value. That is the mean of the parameters. 
* `map`: Sample with the highest posterior probability.
* `ps_theta`: Samples of the parameters. The second dimension corresponds
to the number of samples stored.
* `llh`: The estimates accuracy at different temperatures used in 
thermodynamic integration.
* `F`: A scalar with is the estimated model evidence or negative free energy.
* `y`: The same structure as the input.
* `u`: The same structure as the input.
* `ptheta`: The same structure as the input.
* `htheta`: The same structure as the input.
* `pars`: The same structure as the input.

The meaning of the parameters depends on the particular parameteric 
distribution. However, for each model the parameters have a similar meaning 
and are explained below. Typically, in order to asses the convergence of
the algorithm one can use Gelman-Rubin's R hat statistics, which is required
to be bellow 1.1. For example, using the built-in example from the MATLAB
prompt:

```>> results = tapas_sem_example_inversion(1, 'invgamma');
```

This estimates the model using the PROSA model (first value) and assumes
that the hit time of the units is destributed according to the inverse Gamma
distribution (other options can be found in the code).

To asses the convergence of the algorithm, from the MATLAB prompt
```>> psrf(results.ps_theta')

ans =

  Columns 1 through 7

    1.0331    1.1164    1.0534    1.1265    1.1857    1.2260    1.0643

  Columns 8 through 14

    1.0695    2.1619    1.1677    0.9995    1.2352    1.1584    1.2630

  Columns 15 through 18

    1.1480    1.0643    1.0695    2.1619
```

In this case most of the parameters have not converge. Note that parameters
7, 8, 9 and 16, 17, 18 have the same value as they have been set up to 
be equal across trial types (see below).

To obtain the mean value of the parameters one can run
```>> mean(results.ps_theta')

ans =

  Columns 1 through 7

   -1.4134   -2.7990   -0.8407   -3.2681   -2.4326   -3.2056    0.2264

  Columns 8 through 14

   -1.9420   -5.8132   -0.8028   -1.9048   -1.6275   -3.8723   -2.2246

  Columns 15 through 18

   -5.6216    0.2264   -1.9420   -5.8132
```

Note that the parameters take a negative value because they are sampled
before transforming them to their native native space (in the case of the
invgamma parametrization this is standard shape, scale parametrization in
which both values are positive.  

To transform the parameters to their native space (the positive interval)
the respective function 
is `tapas_sem_[model]_[parametric dist]_ptrans.m`. For example,

```>> tapas_sem_prosa_invgamma_ptrans(results.map)'

ans =

  Columns 1 through 7

    2.6363    3.6399    6.1439    9.6374    2.2676    2.7386    1.2675

  Columns 8 through 14

    0.2064    0.0527    3.1975    2.7737    3.7221    8.5906    7.8973

  Columns 15 through 18

   38.5444    1.2675    0.2064    0.0527
```

One can immediately observe that the probability of an early outlier is
0.052.

## Parameters prosa model

The model is defined by 9 parameters: two for the prosaccade unit, two for
the antisaccade unit and two for the stop unit. Moreover, there is a delay
of all the units, a delay for the antisaccade unit and the probability of
making a early outlier, i.e., that a saccade happens before the main delay.
To model different trial types, the model has a set of parameters for each
trial type. Thus, 18 parametes are required. This are organized in a vector
where the parametes has the following meaning

1. Prosaccade unit in prosaccade trials.
2. Prosaccade unit in prosaccade trials.
5. Antisaccade unit in prosaccade trials.
6. Antisaccade unit in prosaccade trials.
3. Stop unit in prosaccade trials.
4. Stop unit in prosaccade trials.
7. General delay in prosaccade trials.
8. Antisaccade unit delay in prosaccade trials.
9. Probability of an early outlier in prosaccade trials.

Parameters 10 to 18 are equivalent but are only relevant in
antisaccade trials.

## Parameters SERIA model

The model is defined by 11 parameters: two for the early unit, two for
the late unit, and two for the stop unit. Also there is the probability of 
an early prosaccade and the probability of a late prosaccade. Finally, there
is a delay for all the units, a delay for the antisaccade unit and the 
probability of
making a early outlier, i.e., that a saccade happens before the main delay.
To model different trial types, the model has a set of parameters for each
trial type. Thus, 22 parametes are required. This are organized in a vector
where the parametes has the following meaning

1. Early unit in prosaccade trials.
2. Early unit in prosaccade trials.
5. Late unit in prosaccade trials.
6. Late unit in prosaccade trials.
3. Stop unit in prosaccade trials.
4. Stop unit in prosaccade trials.
7. Probability of an early prosaccade in prosaccade trials.
8. Probability of a late prosaccade in prosaccade trials.
7. General delay in prosaccade trials.
8. Late unit delay in prosaccade trials.
9. Probability of an early outlier in prosaccade trials.

Parameters 12 to 22 are equivalent but are only relevant in
antisaccade trials.

## Parameters of the SERIA with late race (dora) model

In the code the SERIA model with late race is called dora (for double race)
model. The model is defined by 11 parameters: two for the early prosaccade 
unit, two for the stop unit, two for the late antisaccade unit and 
two for the late Also there is the probability of 
an early prosaccade and the probability of a late prosaccade. Finally, there
is a delay for all the units, a delay for the antisaccade unit and the 
probability of
making a early outlier, i.e., that a saccade happens before the main delay.
To model different trial types, the model has a set of parameters for each
trial type. Thus, 22 parametes are required. This are organized in a vector
where the parametes has the following meaning

1. Early prosaccade unit in prosaccade trials.
2. Early prosaccade unit in prosaccade trials.
3. Antisaccade unit in prosaccade trials.
4. Antisaccade unit in prosaccade trials.
5. Stop unit in prosaccade trials.
6. Stop unit in prosaccade trials.
7. Late prosaccade unit in prosaccade trials.
8. Late prosaccade unit in prosaccade trials.
7. General delay in prosaccade trials.
8. Late unit delay in prosaccade trials.
9. Probability of an early outlier in prosaccade trials.

Parameters 12 to 22 are equivalent but are only relevant in
antisaccade trials.

## Nested models

In order to generate nested model a projection matrix is used. This is 
defined as the attribute `jm` of a model. For example

```ptheta = tapas_sem_prosa_invgamma_ptheta();
ptheta.jm = [eye(15); zeros(3, 12) eye(3)];```

In this case the nested model is defined by setting up the constrain matrix
`jm`. In the example the matrix is 18x15. The number of columns represents
the number of actual parameters. If multiplied with a vector with 
dimensionality 15x1, this would produce a vector in which the parameters
7,8,9 and 16, 17, 18 are equal. The rationale of this is that this three
parameters can be forced to be equal across trial types. A more complicated
example is to force that the parameters of the early unit are equal in 
both trial types, as well as the delay of the units and the probability of 
an outlier. For this one uses

```ptheta = tapas_sem_prosa_invgamma_ptheta();
ptheta.jm = [eye(9) zeros(9, 4);
    eye(2) zeros(2, 11);
    zeros(4, 9) eye(4);
    zeros(3, 6) eye(3) zeros(3, 4)];
```

In this case the actual number of parameters is 9 for prosaccade trials and 
4 for antisaccade trials (i.e. 13). To force that the parameters of the 
early unit are equal across trials types we have written 
`eye(2) zeros(2, 11)`.


