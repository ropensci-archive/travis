context("caches")

withr::with_dir(
  "travis-testthat",
  {
    test_that("retrieving caches works (.org)", {
      expect_s3_class(
        travis_get_caches(
          repo = "ropensci/tic",
          endpoint = ".org",
          quiet = TRUE
        ),
        "travis_caches"
      )
    })

    test_that("retrieving caches works (.com)", {
      expect_s3_class(
        travis_get_caches(
          repo = "ropensci/tic",
          endpoint = ".com",
          quiet = TRUE
        ),
        "travis_caches"
      )
    })

    test_that("deleting caches works (.org)", {
      skip("We do not want to delete any caches during testing")

      expect_s3_class(
        travis_delete_caches(
          repo = "ropensci/tic",
          endpoint = ".org"
        ),
        "travis_caches"
      )
    })

    test_that("deleting caches works (.com)", {
      skip("We do not want to delete any caches during testing")

      expect_s3_class(
        travis_delete_caches(
          repo = "ropensci/tic",
          endpoint = ".com"
        ),
        "travis_caches"
      )
    })
  }
)
