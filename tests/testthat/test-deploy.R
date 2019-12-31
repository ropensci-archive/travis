context("use-travis-deploy")

withr::with_dir(
  "travis-testthat",
  {
    test_that("use_travis_deploy detects existing keys (.org)", {
      # tests timing out on Travis for unknown reason
      skip_on_ci()
      expect_message(
        use_travis_deploy(endpoint = ".org"),
        "Deploy key for Travis CI"
      )
    })

    test_that("use_travis_deploy detects existing keys (.com)", {
      # tests timing out on Travis for unknown reason
      skip_on_ci()
      expect_message(
        use_travis_deploy(endpoint = ".com"),
        "Deploy key for Travis CI"
      )
    })
  }
)
