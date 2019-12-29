context("meta")

withr::with_dir(
  "./tests/testthat/travis-testthat",
  {
    test_that("Querying repos on Travis works", {
      expect_s3_class(
        travis_repos(quiet = TRUE),
        "travis_repos"
      )
    })

    test_that("Querying user info on Travis works", {
      expect_s3_class(
        travis_user(quiet = TRUE),
        "travis_user"
      )
    })
  }
)
