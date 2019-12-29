context("caches")

withr::with_dir(
  here::here("tests/testthat/travis-testthat"),
  {
    test_that("retrieving caches works (.org)", {
      expect_is(
        travis_get_caches(
          repo = "ropenscilabs/tic",
          endpoint = ".org",
          quiet = TRUE
        ),
        "travis_caches"
      )
    })

    test_that("retrieving caches works (.com)", {
      expect_is(
        travis_get_caches(
          repo = "ropenscilabs/tic",
          endpoint = ".com",
          quiet = TRUE
        ),
        "travis_caches"
      )
    })

    test_that("deleting caches works (.org)", {
      skip("We do not want to delete any caches during testing")

      expect_is(
        travis_delete_caches(
          repo = "ropenscilabs/tic",
          endpoint = ".org"
        ),
        "travis_caches"
      )
    })

    test_that("deleting caches works (.com)", {
      skip("We do not want to delete any caches during testing")

      expect_is(
        travis_delete_caches(
          repo = "ropenscilabs/tic",
          endpoint = ".com"
        ),
        "travis_caches"
      )
    })
  }
)
