# travis [![Travis-CI Build Status](https://travis-ci.org/ropenscilabs/travis.svg?branch=master)](https://travis-ci.org/ropenscilabs/travis)


The goal of travis is to simplify the setup of continuous integration with [Travis CI](https://travis-ci.org/).
Apart from automating away a few button flips, it also provides an easy method to set up push access which can be then triggered (on Travis) by the companion package [tic](https://github.com/krlmlr/tic).


## Installation

You can install travis from github with:


``` r
# install.packages("remotes")
remotes::install_github("ropenscilabs/travis")
```


## Permissions

The package is linked to the "rtravis" application, and will request GitHub permissions to carry out its actions. Unfortunately, revoking these permissions also invalidates any SSH keys created by this package.


## Example

0. Create a repository on GitHub (if it's not there yet)

    ```r
    github_create_repo()
    ```

1. Show the GitHub repository name

    ```r
    github_repo()
    ```

2. Turn on Travis for this repo (syncs from GitHub if necessary!)

    ```r
    travis_enable()
    ```

3. Browse the repo on Travis

    ```r
    travis_browse()
    ```

4. Set up push access for Travis: This creates an SSH key, stores it as encoded
   encrypted environment variable on Travis, and enables push access for the
   corresponding public key. GitHub notifies you via e-mail.

    ```r
    use_travis_deploy()
    ```
