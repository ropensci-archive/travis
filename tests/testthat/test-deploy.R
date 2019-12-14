context("use-travis-deploy")

setwd("./travis-testthat")

test_that("use_travis_deploy detects existing keys (.org)", {
  expect_message(
    use_travis_deploy(endpoint = ".org"),
    "Deploy key for Travis CI"
  )
})

test_that("use_travis_deploy detects existing keys (.com)", {
  expect_message(
    use_travis_deploy(endpoint = ".com"),
    "Deploy key for Travis CI"
  )
})
