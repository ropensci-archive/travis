context("authentication")

withr::with_dir(
  "travis-testthat",
  {
    test_that("Travis enable/disable works", {

      # disable
      capture.output(travis_enable(
        repo = repo, endpoint = ".org",
        active = FALSE
      ))
      expect_false(travis_is_enabled(repo = repo, endpoint = ".org"))

      capture.output(travis_enable(
        repo = repo, endpoint = ".com",
        active = FALSE
      ))
      expect_false(travis_is_enabled(endpoint = ".com"))

      # enable
      capture.output(travis_enable(repo = repo, endpoint = ".org"))
      expect_true(travis_is_enabled(repo = repo, endpoint = ".org"))

      capture.output(travis_enable(repo = repo, endpoint = ".com"))
      expect_true(travis_is_enabled(endpoint = ".com"))
    })
  }
)
