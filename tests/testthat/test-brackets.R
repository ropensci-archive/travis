context("Brackets")

test_that("Keeping and removing brackets", {
  expect_equal(keep_brackets("updat[ing]{e} variable"), "updating variable")
  expect_equal(remove_brackets("updat[ing]{e} variable"), "update variable")
})

test_that("Keeping and removing brackets (suffix only)", {
  expect_equal(keep_brackets("restar[ting]{t} build"), "restarting build")
  expect_equal(remove_brackets("restar[ting]{t} build"), "restart build")
})

test_that("Keeping and removing brackets (empty)", {
  expect_equal(keep_brackets("restart[ing]{} build"), "restarting build")
  expect_equal(remove_brackets("restart[ing]{} build"), "restart build")
})

test_that("Keeping and removing brackets (only [])", {
  expect_equal(keep_brackets("restart[ing] build"), "restarting build")
  expect_equal(remove_brackets("restart[ing] build"), "restart build")
})

test_that("Keeping and removing brackets (only {})", {
  expect_equal(keep_brackets("x{a} b"), "x b")
  expect_equal(remove_brackets("x{a} b"), "xa b")
})

test_that("Brackets with spaces are kept unchanged", {
  expect_equal(keep_brackets("[a ]{b } c"), "[a ]{b } c")
  expect_equal(remove_brackets("[a ]{b } c"), "[a ]{b } c")
})
