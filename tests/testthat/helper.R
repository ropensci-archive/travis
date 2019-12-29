if (!dir.exists("travis-testthat")) {
  system("git clone https://github.com/pat-s/travis-testthat.git")
}

withr::with_dir(
  "travis-testthat",
  {
    repo <- github_repo(".")
  }
)
