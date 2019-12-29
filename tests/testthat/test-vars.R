context("vars")

withr::with_dir(
  "travis-testthat",
  {
    test_that("getting env vars works (.org)", {
      expect_s3_class(
        travis_get_vars(
          repo = "ropenscilabs/travis", endpoint = ".org",
          quiet = TRUE
        ),
        "travis_env_vars"
      )
    })

    test_that("getting env vars works (.com)", {
      expect_s3_class(
        travis_get_vars(
          repo = "ropenscilabs/travis", endpoint = ".com",
          quiet = TRUE
        ),
        "travis_env_vars"
      )
    })

    test_that("getting env var id works (.org)", {
      expect_s3_class(
        travis_get_var_id(
          travis_get_vars(
            repo = "ropenscilabs/travis", endpoint = ".org",
            quiet = TRUE
          )[[1]]$name,
          repo = "ropenscilabs/travis", endpoint = ".org",
          quiet = TRUE
        ),
        "character"
      )
    })

    test_that("getting env var id works (.com)", {
      expect_s3_class(
        travis_get_var_id(
          travis_get_vars(
            repo = "ropenscilabs/travis", endpoint = ".com",
            quiet = TRUE
          )[[1]]$name,
          repo = "ropenscilabs/travis", endpoint = ".com",
          quiet = TRUE
        ),
        "character"
      )
    })

    test_that("setting env vars works (.org)", {
      expect_s3_class(
        travis_set_var(
          name = "test", value = "test",
          repo = repo, endpoint = ".org",
          quiet = TRUE
        ),
        "travis_env_var"
      )
    })

    test_that("setting env vars works (.com)", {
      expect_s3_class(
        travis_set_var(
          name = "test", value = "test",
          repo = repo, endpoint = ".com",
          quiet = TRUE
        ),
        "travis_env_var"
      )
    })

    test_that("deleting env vars works (.org)", {
      expect_s3_class(
        travis_delete_var(
          travis_get_var_id(
            name = "test", repo = repo,
            endpoint = ".org", quiet = TRUE
          ),
          repo = repo,
          endpoint = ".org", quiet = TRUE
        ),
        "response"
      )
    })

    test_that("deleting env vars works (.com)", {
      expect_s3_class(
        travis_delete_var(
          travis_get_var_id(
            name = "test", repo = repo,
            endpoint = ".com", quiet = TRUE
          ),
          repo = repo,
          endpoint = ".com", quiet = TRUE
        ),
        "response"
      )
    })
  }
)
