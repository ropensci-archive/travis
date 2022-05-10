# travis

**This package was archived due to recent policy changes on Travis CI, lack of popularity and the lack of maintenance resources.**

Set up Travis CI for testing and deployment.

<!-- badges: start -->

[![Travis build status](https://img.shields.io/travis/ropenscilabs/travis/master?logo=travis&style=flat-square&label=Linux)](https://travis-ci.org/ropenscilabs/travis)
[![CRAN status](https://www.r-pkg.org/badges/version/travis)](https://cran.r-project.org/package=travis)
[![codecov](https://codecov.io/gh/ropenscilabs/travis/branch/master/graph/badge.svg)](https://codecov.io/gh/ropenscilabs/travis)
[![Lifecycle: maturing](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)

<!-- badges: end -->

The goal of {travis} is to simplify the setup of continuous integration with [Travis CI](https://travis-ci.org/).
Both endpoints `.com` (https://travis-ci.com) and `.org` (https://travis-ci.org) are supported.

The main purpose is to provide a command-line way in R for certain Travis tasks that are usually done in the browser (build checking, cache deletion, build restarts, etc.).

The package also comes handy when setting up Travis CI builds for deployment via `use_travis_deploy()`.

To learn more about Travis CI in general, have a look at [this blog post](http://mahugh.com/2016/09/02/travis-ci-for-test-automation/) .

{travis} package is closely coupled with the [{tic}](https://docs.ropensci.org/tic/) package which provides tools for an CI-agnostic workflow.

See the [Get Started](https://docs.ropensci.org/travis/articles/travis.html) vignette for more information.

## Installation

You can install {travis} from Github with:

```r
remotes::install_github("ropenscilabs/travis")
```

---

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
