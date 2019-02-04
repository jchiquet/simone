
<!-- README.md is generated from README.Rmd. Please edit that file -->

# SIMoNe: Statistical Inference for Modular Networks

[![Travis build
status](https://travis-ci.org/jchiquet/simone.svg?branch=master)](https://travis-ci.org/jchiquet/simone)
[![AppVeyor build
status](https://ci.appveyor.com/api/projects/status/github/jchiquet/simone?branch=master&svg=true)](https://ci.appveyor.com/project/jchiquet/simone)
[![CRAN
status](https://www.r-pkg.org/badges/version/simone)](https://cran.r-project.org/package=simone)

> The goals of SIMoNe is to implement methods for the inference of
> co-expression networks based on partial correlation coefficients from
> either steady-state or time-course transcriptomic data. Note that with
> both type of data this package can deal with samples collected in
> different experimental conditions and therefore not identically
> distributed. In this particular case, multiple but related networks
> are inferred on one simone run.

## Installation

To install CRAN version,

``` r
install.packages("simone")
```

To install dev version,

``` r
devtools::install_github("jchiquet/simone")
```

## Features

The available inference methods for edges selection include

  - *neighborhood selection* as in Meinshausen and Buhlman (2006),
    steady-state data only;
  - *graphical Lasso* as in Banerjee et al, 2008 and Friedman et al
    (2008), steady-state data only;
  - *VAR(1) inference* as in Charbonnier, Chiquet and Ambroise (2010),
    time-course data only;
  - *multitask learning* as in Chiquet, Grandvalet and Ambroise (2011),
    both time-course and steady-state data.

All the listed methods are based l1-norm penalization, with an
additional grouping effect for multitask learning (including three
variants: “intertwined”, “group-Lasso” and “cooperative-Lasso”).

The penalization of each individual edge may be weighted according to a
latent clustering of the network, thus adapting the inference of the
network to a particular topology. The clustering algorithm is performed
by the `blockmodels` package.

Since the choice of the network sparsity level remains a current issue
in the framework of sparse Gaussian network inference, the algorithm
provides a full path of estimators starting from an empty network and
adding edges as the penalty level progressively decreases. Bayesian
Information Criteria (BIC) and Akaike Information Criteria (AIC) are
adapted to the GGM context in order to help to choose one particular
network among this path of solutions.

Graphical tools are provided to summarize the results of a SIMoNe run
and offer various representations for network plotting.

## First steps

Have a look at the
[documentation](http://cran.r-project.org/web/packages/simone/simone.pdf).
You may also check the demos:

``` r
demo(cancer_pooled)
demo(cancer_multitask)
demo(check_glasso, echo=FALSE)
demo(simone_steadyState)
demo(simone_timeCourse)
demo(simone_multitask)
```

## References

  - J. Chiquet, Y. Grandvalet, and C. Ambroise (2011). Inferring
    multiple graphical structures, Statistics and Computing.
    <http://dx.doi.org/10.1007/s11222-010-9191-2>

  - C. Charbonnier, J. Chiquet, and C. Ambroise (2010). Weighted-Lasso
    for Structured Network Inference from Time Course Data. Statistical
    Applications in Genetics and Molecular Biology, vol. 9, iss. 1,
    article 15. <http://www.bepress.com/sagmb/vol9/iss1/art15/>

  - C. Ambroise, J. Chiquet, and C. Matias (2009). Inferring sparse
    Gaussian graphical models with latent structure. Electronic Journal
    of Statistics, vol. 3, pp. 205–238.
    <http://dx.doi.org/10.1214/08-EJS314>

  - Leger, Jean-Benoist. “Blockmodels: A R-package for estimating in
    Latent Block Model and Stochastic Block Model, with various
    probability functions, with or without covariates.” arXiv preprint
    [arXiv:1602.07587](https://arxiv.org/pdf/1602.07587) (2016).
