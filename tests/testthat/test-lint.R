context("lint")

test_that("linting works", {

  expect_is(
    travis_lint("https://raw.githubusercontent.com/pat-s/travis-testthat/master/.travis.yml",
                quiet = TRUE),
    "travis_warnings"
  )
})
