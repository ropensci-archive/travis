context("sync")

withr::with_dir(
  "travis-testthat",
  {
    test_that("syncing works", {

      # syncing .org does not work if the Travis CI GH app is not installed
      # unfortunately, this app cannot be installed anymore
      expect_s3_class(
        travis_sync(quiet = TRUE, endpoint = ".com"),
        "travis_api"
      )
    })
  }
)
