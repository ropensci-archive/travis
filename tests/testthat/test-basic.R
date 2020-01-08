context("basic")

withr::with_dir(
  "travis-testthat",
  {
    test_that("travis_repo_info()", {
      expect_s3_class(
        travis_repo_info(endpoint = ".org"),
        "travis_repo"
      )
      expect_s3_class(
        travis_repo_info(endpoint = ".com"),
        "travis_repo"
      )
    })

    test_that("travis_has_repo()", {
      expect_true(travis_has_repo(endpoint = ".org"))
      expect_true(travis_has_repo(endpoint = ".com"))
    })

    test_that("travis_repo_id()", {
      expect_vector(travis_repo_id(endpoint = ".org"),
        ptype = integer(), size = 1
      )
      expect_vector(travis_repo_id(endpoint = ".com"),
        ptype = integer(), size = 1
      )
    })

    test_that("travis_repo_settings()", {
      expect_s3_class(
        travis_repo_settings(endpoint = ".org"),
        "travis_settings"
      )
      expect_s3_class(
        travis_repo_settings(endpoint = ".com"),
        "travis_settings"
      )
    })
  }
)
