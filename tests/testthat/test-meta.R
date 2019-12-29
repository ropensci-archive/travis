context("meta")

withr::with_dir(
  here::here("tests/testthat/travis-testthat"),
  {
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
  }
)
