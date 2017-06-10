#' @export
travis_sync <- function(block = TRUE, token = travis_token()) {
  url <- "/users/sync"
  req <- TRAVIS_POST(url, token = token)

  if (!(httr::status_code(req) %in% c(200, 409))) {
    httr::stop_for_status(req, "synch user")
  }

  if (block) {
    message("Waiting for sync with GitHub", appendLF = FALSE)
    while(travis_user()$is_syncing) {
      message(".", appendLF = FALSE)
      write_lf <- TRUE
      Sys.sleep(1)
    }
    message()
  }
}

#' @export
travis_browse <- function(repo = github_repo()) {
  utils::browseURL(paste0("https://travis-ci.org/", repo))
}
