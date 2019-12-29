if (!dir.exists("travis-testthat")) {
  system("git clone https://github.com/pat-s/travis-testthat.git")
}

print(here::here("tests/testthat/travis-testthat"))

withr::with_dir(
  here::here("tests/testthat/travis-testthat"),
  {
    repo <- github_repo(".")
  }
)
