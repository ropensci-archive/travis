# travis

[![Travis-CI Build Status](https://travis-ci.org/ropenscilabs/travis.svg?branch=master)](https://travis-ci.org/ropenscilabs/travis)

The goal of travis is to simplify the setup of continuous integration with [Travis CI](https://travis-ci.org/).
Its main purpose is to provide a command-line way in R for certain Travis tasks that are usually done in the browser (build checking, cache deletion, build restarts, etc.).

## Installation

You can install travis from github with:

``` r
# install.packages("remotes")
remotes::install_github("ropenscilabs/travis")
```

## Permissions

The package is linked to the "rtravis" application, and will request GitHub permissions to carry out its actions. 
Revoking these permissions also invalidates any SSH keys created by this package.

## Examples

Check the [Getting Started](travis.html) vignette for examples.

## *tic* integration

Apart from automating away a few button flips, it also provides an easy method to set up push access which can be then triggered (on Travis) by the companion package [tic](https://github.com/krlmlr/tic). 
Please see `?usethis::use_ci()` documentation or the [Getting Started vignette](https://ropenscilabs.github.io/tic/articles/tic.htmlinitialization) of *tic* for a more detailed explanation.

---

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
