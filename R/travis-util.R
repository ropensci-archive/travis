#' Travis CI utilities
#'
#' @description
#' Helper functions for Travis CI.
#'
#' `travis_sync()` initiates synchronization with GitHub and waits for completion
#' by default.
#' @param block `[flag]`\cr
#'   Set to `FALSE` to return immediately instead of waiting.
#' @param token \cr
#'   A Travis CI API token obtained from [auth_travis()].
#' @export
travis_sync <- function(block = TRUE, token = auth_travis(), endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  user_id <- travis_user()[["id"]]

  req = travisHTTP(verb = "POST", path = sprintf("/user/%s/sync", user_id),
                   endpoint = endpoint)

  check_status(req$response, cli::cat_bullet(bullet = "info",
                                             bullet_col = "yellow",
                                             "Initiating sync with GitHub."),
               409)

  if (block) {
    cli::cat_bullet(
      bullet = "info", bullet_col = "yellow",
      "Waiting for sync with GitHub."
    )
    while (travis_user()[["is_syncing"]]) {
      Sys.sleep(1)
    }
    message()
  }

  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    "Finished sync with GitHub."
  )
}

#' @importFrom usethis browse_travis
#' @export
usethis::browse_travis
