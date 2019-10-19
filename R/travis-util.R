#' Travis CI utilities
#'
#' @description
#' Helper functions for Travis CI.
#'
#' `travis_sync()` initiates synchronization with GitHub and waits for completion
#' by default.
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#' @param block `[flag]`\cr
#'   Set to `FALSE` to return immediately instead of waiting.
#' @param token \cr
#'   A Travis CI API token obtained from [auth_travis()].
#' @export
travis_sync <- function(block = TRUE, token = auth_travis()) {
  user_id <- travis_user(token = token)[["id"]]

  req <- TRAVIS_POST3(sprintf("/user/%s/sync", user_id),
    token = token
  )

  check_status(req, "initiat[ing]{e} sync with GitHub", 409)

  if (block) {
    message("Waiting for sync with GitHub", appendLF = FALSE)
    while (travis_user(token = token)[["is_syncing"]]) {
      message(".", appendLF = FALSE)
      Sys.sleep(1)
    }
    message()
  }

   message("Finished sync with GitHub.")
}

#' @description
#' `travis_browse()` opens a browser pointing to the current repo on  Travis CI.
#'
#' @export
#' @rdname travis_sync
travis_browse <- function(repo = github_repo()) {
  utils::browseURL(paste0("https://travis-ci.org/", repo))
}
