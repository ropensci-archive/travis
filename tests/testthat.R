# This testthat setup is somewhat complicated due to API calls on the same system
# that the tests are running on. Therefore, we explain the setup here in a few
# lines:
#
# To be able to talk to the API, API keys from @pat-s are stored as env vars
# R_TRAVIS_ORG, R_TRAVIS_COM and GITHUB_PAT on Travis CI .com and .org.
#
# Most tests run on repo pat-s/travis-testthat. This repo is cloned before tests
# are starting in file `helper.R`.
# The "debug" functions need extra permissions and are running on
# - ropenscilabs/tic (.com)
# - mlr-org/mlr (.org)
# This is because @pat-s has access to both repos for triggering builds and
# both repos have "debug builds" enabled via Travis.
#
# To avoid restarting several builds more than once in a CI run, certain tests
# won't run on PR builds and on covr.
# Also, all queried builds need to be canceled afterwards. This is needed to
# start them again during the covr run.
library(testthat)
library(travis)

test_check("travis")
