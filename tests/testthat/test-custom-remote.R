context("remote")

withr::with_dir(
  "./tests/testthat/travis-testthat",
  {
    test_that("custom remote is honored", {
      system("git remote add test https://github.com/pat-s/travis-testthat.git")

      expect_s3_class(github_info(remote = "test"), "gh_response")

      system("git remote remove test")
    })
  }
)
