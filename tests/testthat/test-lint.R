context("lint")

withr::with_dir(
  "travis-testthat",
  {
    test_that("linting works", {
      expect_s3_class(
        travis_lint("https://raw.githubusercontent.com/pat-s/travis-testthat/master/.travis.yml", # nolint
          quiet = TRUE, endpoint = ".org"
        ),
        "travis_warnings"
      )
    })
  }
)
