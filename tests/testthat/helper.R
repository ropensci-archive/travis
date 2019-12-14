if (!dir.exists("travis-testthat")) {
  system("git clone https://github.com/pat-s/travis-testthat.git ./travis-testthat")
}

# change to "travis-testthat" a
setwd("./travis-testthat")

repo = github_repo(".")
