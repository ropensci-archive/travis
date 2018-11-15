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

## Example

1. Create a repository on GitHub (if it's not there yet)

    ```r
    github_create_repo()
    ```

1. Show the GitHub repository name

    ```r
    github_repo()
    ```

1. Turn on Travis for this repo (syncs from GitHub if necessary!)

    ```r
    travis_enable()
    ```

1. Browse the repo on Travis

Check the [Getting Started](travis.html) vignette for examples.

1. Set up push access for Travis: This creates an SSH key, stores it as encoded
   encrypted environment variable on Travis, and enables push access for the
   corresponding public key. GitHub notifies you via e-mail.

## *tic* integration

Apart from automating away a few button flips, it also provides an easy method to set up push access which can be then triggered (on Travis) by the companion package [tic](https://github.com/krlmlr/tic). 
Please see `?usethis::use_ci()` documentation or the [Getting Started vignette](https://ropenscilabs.github.io/tic/articles/tic.htmlinitialization) of *tic* for a more detailed explanation.

1. Query current state of the repo on Travis.

    ```r
    travis_get_builds()
    
    A collection of 25 Travis CI builds:
    - id: 430482536, number: 415, state: started, duration: NULL, event_type: pull_request, ...
    - id: 430482493, number: 414, state: failed, duration: 2886, event_type: push, ...
    - id: 430453895, number: 413, state: failed, duration: 3028, event_type: pull_request, ...
    - id: 430453887, number: 412, state: failed, duration: 3251, event_type: push, ...
    - id: 430442750, number: 411, state: failed, duration: 2716, event_type: pull_request, ...
    - ...
    ```
    
1. Retrieve cache information 

    ```r
    travis_get_caches()
    
    A collection of 56 Travis CI caches:
    - repository_id: 10785882, size: 68080246, name: cache-linux-trusty-118a1ba90e288592bc83914310d60771d319c6a1e959176fb3aadede7b9782cb--R-3.5.0.tgz, branch: PR.64, last_modified: 2018-09-13T22:29:55Z, repo: list(`@type` = "repository", `@href` = "/repo/10785882", `@representation` = "minimal", id = 10785882, name = "tic", slug = "ropenscilabs/tic")
    
    - repository_id: 10785882, size: 60603887, name: cache-linux-trusty-e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855--R-3.1.3.tgz, branch: PR.64, last_modified: 2018-09-13T22:27:07Z, repo: list(`@type` = "repository", `@href` = "/repo/10785882", `@representation` = "minimal", id = 10785882, name = "tic", slug = "ropenscilabs/tic")
    [...]
    ```
    
1. Clear all caches (caution, currently its only possible to delete all caches!):
    
    ```r
    travis_delete_caches()
    
    Finished deleting caches for <repo> on Travis CI.
    ```
    
1. Create a Personal Access Token (PAT) to avoid Github's rate limit

    ```r
    travis_set_pat()
    
    Create a personal access token, make sure that you are signed in as the correct user. The suggested description 'travis+tic for <repo>' has been copied to the clipboard. If you use this token only to avoid GitHubts rate limit, you can leave all scopes unchecked. Then, copy the new token to the clipboard, it will be detected and applied automatically. Please visit https://github.com/settings/tokens/new. A browser window will be opened. Waiting for PAT to appear on the clipboard. Detected PAT, clearing clipboard. Finished adding private environment variable GITHUB_PAT to <repo> on Travis CI.
    ```
    
1. Set or update environment variables on Travis. Caution: The secret value passed to this function is captured in the history.

    ```r
    travis_set_var()
    
    Finished adding private environment variable variable to <repo> on Travis CI.
    ```
    
---

[![ropensci_footer](https://ropensci.org/public_images/ropensci_footer.png)](https://ropensci.org)
