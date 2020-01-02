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

withr::with_dir(
  "travis-testthat",
  {
    test_that("Catch invalid API keys", {

      # backup
      api_key_org <- travis_check_api_key(".org")
      api_key_com <- travis_check_api_key(".com")

      # invalidate
      Sys.setenv("R_TRAVIS_ORG" = "invalid")
      Sys.setenv("R_TRAVIS_COM" = "invalid")

      expect_error(travis_get_builds(repo = repo, endpoint = ".org"),
        regexp = "Possibly invalid API key detected. Please double-check and retry." # nolint
      )
      expect_error(travis_get_builds(repo = repo, endpoint = ".com"),
        regexp = "Possibly invalid API key detected. Please double-check and retry." # nolint
      )

      # restore
      Sys.setenv("R_TRAVIS_ORG" = api_key_org)
      Sys.setenv("R_TRAVIS_COM" = api_key_com)
    })
  }
)
