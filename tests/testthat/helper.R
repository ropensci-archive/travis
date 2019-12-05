if (!dir.exists("travis-testthat")) {
  git2r::clone("https://github.com/pat-s/travis-testthat.git", "./travis-testthat")
}

# change to "travis-testthat" a
setwd("./travis-testthat")

repo = github_repo(".")
#print(list.files(all.files = T))
