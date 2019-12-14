context("sync")

test_that("syncing works", {

  expect_is(
    travis_sync(quiet = TRUE),
    "travis_api"
  )
})
