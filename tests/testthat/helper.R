if (!dir.exists("travis-testthat")) {
  system("git clone https://github.com/pat-s/travis-testthat.git")
}

# change to "travis-testthat"
setwd("./travis-testthat")

repo <- github_repo(".")
