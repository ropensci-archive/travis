context("repo")

test_that("extract_repo() works", {
  repo <- "ropenscilabs/travis"

  expect_match(extract_repo("git://github.com/ropenscilabs/travis.git"), repo)
  expect_match(extract_repo("http://github.com/ropenscilabs/travis.git"), repo)
  expect_match(extract_repo("http://user:pass@github.com/ropenscilabs/travis.git"), repo) # nolint
  expect_match(extract_repo("https://github.com/ropenscilabs/travis.git"), repo)
  expect_match(extract_repo("https://user:pass@github.com/ropenscilabs/travis.git"), repo) # nolint
  expect_match(extract_repo("git@github.com:ropenscilabs/travis.git"), repo)
  expect_match(extract_repo("git://github.com/ropenscilabs/travis"), repo)
  expect_match(extract_repo("http://github.com/ropenscilabs/travis"), repo)
  expect_match(extract_repo("http://user:pass@github.com/ropenscilabs/travis"), repo) # nolint
  expect_match(extract_repo("https://github.com/ropenscilabs/travis"), repo)
  expect_match(extract_repo("https://user:pass@github.com/ropenscilabs/travis"), repo) # nolint
  expect_match(extract_repo("git@github.com:ropenscilabs/travis"), repo)
})
