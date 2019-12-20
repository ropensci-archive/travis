context("extract-repo")

test_that("URLs containing 'www' are handled properly", {

    foo = extract_repo("https://www.github.com/tidyverse/dplyr.git")
    foo_http = extract_repo("http://www.github.com/tidyverse/dplyr.git")

    expect_match(foo, "tidyverse/dplyr")
    expect_match(foo_http, "tidyverse/dplyr")
})

test_that("URLs containing 'git@github.com' are handled properly", {

  foo = extract_repo("https://github.com/tidyverse/dplyr.git")

  expect_match(foo, "tidyverse/dplyr")
})

test_that("URLs containing 'git@github.com' are handled properly", {

  foo = extract_repo("git@github.com:tidyverse/dplyr.git")

  expect_match(foo, "tidyverse/dplyr")
})

test_that("URLs containing 'git://github.com' are handled properly", {

  foo = extract_repo("git://github.com:tidyverse/dplyr.git")

  expect_match(foo, "tidyverse/dplyr")
})
