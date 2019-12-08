context("builds")

setwd("./travis-testthat")

test_that("Querying builds works", {
  builds <- travis_get_builds(endpoint = ".org")
  expect_is(builds, "travis_builds")
  builds <- travis_get_builds(endpoint = ".com")
  expect_is(builds, "travis_builds")
})

test_that("triggering a new build works", {
  expect_is(
    travis_restart_build(
      travis_get_builds(endpoint = ".org")[[1]]$id,
      ".org"
    ),
    "travis_pending"
  )
  expect_is(
    travis_restart_build(travis_get_builds(endpoint = ".com")[[1]]$id,
      endpoint = ".com"
    ),
    "travis_pending"
  )
})

test_that("restarting the last build works", {
  expect_is(
    travis_restart_last_build(endpoint = ".org"),
    "travis_pending"
  )
  expect_is(
    travis_restart_last_build(endpoint = ".com"),
    "travis_pending"
  )
})

test_that("Querying jobs works", {
  builds <- travis_get_jobs(travis_get_builds(endpoint = ".org")[[1]]$id,
    endpoint = ".org"
  )
  expect_is(builds, "travis_jobs")
  builds <- travis_get_jobs(travis_get_builds(endpoint = ".com")[[1]]$id,
    endpoint = ".com"
  )
  expect_is(builds, "travis_jobs")
})

test_that("restarting a job works", {
  expect_is(
    travis_restart_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".org")[[1]]$id,
        endpoint = ".org"
      )[[1]]$id,
      endpoint = ".org"
    ),
    "travis_pending"
  )

  expect_is(
    travis_restart_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".com")[[1]]$id,
        endpoint = ".com"
      )[[1]]$id,
      endpoint = ".com"
    ),
    "travis_pending"
  )
})

test_that("cancelling a job works", {
  expect_is(
    travis_cancel_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".org")[[1]]$id,
        endpoint = ".org"
      )[[1]]$id,
      endpoint = ".org"
    ),
    "travis_pending"
  )

  expect_is(
    travis_cancel_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".com")[[1]]$id,
        endpoint = ".com"
      )[[1]]$id,
      endpoint = ".com"
    ),
    "travis_pending"
  )
})

test_that("restarting a debug job works", {
  expect_is(
    travis_debug_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".org")[[1]]$id,
        endpoint = ".org"
      )[[1]]$id,
      endpoint = ".org"
    ),
    "travis_pending"
  )

  expect_is(
    travis_debug_job(
      travis_get_jobs(
        travis_get_builds(endpoint = ".com")[[1]]$id,
        endpoint = ".com"
      )[[1]]$id,
      endpoint = ".com"
    ),
    "travis_pending"
  )
})

test_that("retrieving logs works", {
  expect_is(
    travis_get_log(
      travis_get_jobs(
        travis_get_builds(endpoint = ".org")[[1]]$id,
        endpoint = ".org"
      )[[1]]$id,
      endpoint = ".org"
    ),
    "character"
  )

  expect_is(
    travis_get_log(
      travis_get_jobs(
        travis_get_builds(endpoint = ".com")[[1]]$id,
        endpoint = ".com"
      )[[1]]$id,
      endpoint = ".com"
    ),
    "character"
  )
})

test_that("deleting logs works", {
  expect_is(
    travis_delete_log(
      travis_get_jobs(
        travis_get_builds(endpoint = ".org")[[1]]$id,
        endpoint = ".org"
      )[[1]]$id,
      endpoint = ".org"
    ),
    "character"
  )

  expect_is(
    travis_delete_log(
      travis_get_jobs(
        travis_get_builds(endpoint = ".com")[[1]]$id,
        endpoint = ".com"
      )[[1]]$id,
      endpoint = ".com"
    ),
    "character"
  )
})
