#' @export
travis_sync <- function(block = TRUE, token = travis_token(), quiet = FALSE) {
  url <- "/users/sync"
  req <- TRAVIS_POST(url, token = token)

  check_status(req, "initiat[ing](e) sync with GitHub", quiet, 409)

  if (block) {
    message("Waiting for sync with GitHub", appendLF = FALSE)
    while(travis_user()$is_syncing) {
      if (!quiet) message(".", appendLF = FALSE)
      Sys.sleep(1)
    }
    if (!quiet) message()
  }

  if (!quiet) message("Finished sync with GitHub.")
}

#' @export
travis_browse <- function(repo = github_repo()) {
  utils::browseURL(paste0("https://travis-ci.org/", repo))
}
