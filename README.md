# travis

Set up Travis CI for testing and deployment 

<!-- badges: start -->
[![Travis build status](https://img.shields.io/travis/ropenscilabs/travis/master?logo=travis&style=flat-square&label=Linux)](https://travis-ci.org/ropenscilabs/travis)
[![CRAN status](https://www.r-pkg.org/badges/version/travis)](https://cran.r-project.org/package=travis)
[![codecov](https://codecov.io/gh/ropenscilabs/travis/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/travis)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
<!-- badges: end -->

The goal of travis is to simplify the setup of continuous integration with [Travis CI](https://travis-ci.org/).
Both endpoints `.com` and `.org` are supported.

Its main purpose is to provide a command-line way in R for certain Travis tasks that are usually done in the browser (build checking, cache deletion, build restarts, etc.).

To learn more about Travis CI in general, read [this blog post](http://mahugh.com/2016/09/02/travis-ci-for-test-automation/) .
The _travis_ package is closely coupled with the _tic_ package which provides tools for an CI-agnostic workflow.
Read the [Getting Started](https://ropenscilabs/tic/articles/tic.html#prerequisites) vignette for more details.

## Installation

You can install travis from Github with:

``` r
# install.packages("remotes")
remotes::install_github("ropenscilabs/travis")
```

## Get Started with the _travis_ package

See the [Get Started](https://ropenscilabs.github.io/travis/articles/travis.html) vignette for more information.

---

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
