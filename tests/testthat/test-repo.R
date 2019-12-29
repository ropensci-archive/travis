context("repo")

test_that("extract_repo() works", {
  repo <- "ropenscilabs/travis"

  expect_equal(extract_repo("git://github.com/ropenscilabs/travis.git"), repo)
  expect_equal(extract_repo("http://github.com/ropenscilabs/travis.git"), repo)
  expect_equal(extract_repo("http://user:pass@github.com/ropenscilabs/travis.git"), repo) # nolint
  expect_equal(extract_repo("https://github.com/ropenscilabs/travis.git"), repo)
  expect_equal(extract_repo("https://user:pass@github.com/ropenscilabs/travis.git"), repo) # nolint
  expect_equal(extract_repo("git@github.com:ropenscilabs/travis.git"), repo)
  expect_equal(extract_repo("git://github.com/ropenscilabs/travis"), repo)
  expect_equal(extract_repo("http://github.com/ropenscilabs/travis"), repo)
  expect_equal(extract_repo("http://user:pass@github.com/ropenscilabs/travis"), repo) # nolint
  expect_equal(extract_repo("https://github.com/ropenscilabs/travis"), repo)
  expect_equal(extract_repo("https://user:pass@github.com/ropenscilabs/travis"), repo) # nolint
  expect_equal(extract_repo("git@github.com:ropenscilabs/travis"), repo)
  expect_equal(extract_repo("ssh://git@github.com/ropenscilabs/travis"), repo)
})
