extract_repo <- function(path) {
  if (grepl("^git@github.com:", path)) {
    path <- sub("^git@github.com:", "https://github.com/", path)
  } else if (grepl("^git://github.com", path)) {
    path <- sub("^git://github.com", "https://github.com", path)
  } else if (grepl("^http://(.+@)?github.com", path)) {
    path <- sub("^http://(.+@)?github.com", "https://github.com", path)
  } else if (grepl("^https://(.+@)github.com", path)) {
    path <- sub("^https://(.+@)github.com", "https://github.com", path)
  }
  if (!all(grepl("^https://github.com", path))) {
    stopc("Unrecognized repo format: ", path)
  }
  path <- sub("\\.git", "", path)
  sub("^https://github.com/", "", path)
}
