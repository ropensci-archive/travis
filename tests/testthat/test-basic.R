context("basic")

setwd("./travis-testthat")

test_that("travis_repo_info()", {

  expect_is(travis_repo_info(repo = repo, endpoint = ".org"), "travis_repo")
  expect_is(travis_repo_info(repo = repo, endpoint = ".com"), "travis_repo")
})

test_that("travis_has_repo()", {
  expect_true(travis_has_repo(repo = repo, endpoint = ".org"))
  expect_true(travis_has_repo(repo = repo, endpoint = ".com"))
})

test_that("travis_repo_id()", {
  expect_vector(travis_repo_id(repo = repo, endpoint = ".org"),
    ptype = integer(), size = 1
  )
  expect_vector(travis_repo_id(repo = repo, endpoint = ".com"),
    ptype = integer(), size = 1
  )
})

test_that("travis_repo_settings()", {
  expect_is(
    travis_repo_settings(repo = repo, endpoint = ".org"),
    "travis_settings"
  )
  expect_is(
    travis_repo_settings(repo = repo, endpoint = ".com"),
    "travis_settings"
  )
})
