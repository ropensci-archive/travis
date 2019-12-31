context("sync")

test_that("syncing works", {
  expect_s3_class(
    travis_sync(quiet = TRUE),
    "travis_api"
  )
})
