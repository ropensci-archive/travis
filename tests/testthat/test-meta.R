context("meta")

test_that("Querying repos on Travis works", {

  expect_is(
    travis_repos(quiet = TRUE),
    "travis_repos"
  )
})

test_that("Querying user info on Travis works", {

  expect_is(
    travis_user(quiet = TRUE),
    "travis_user"
  )
})
