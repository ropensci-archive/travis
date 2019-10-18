#' Travis CI utilities
#'
#' @description
#' Helper functions for Travis CI.
#'
#' `travis_sync()` initiates synchronization with GitHub and waits for completion
#' by default.
#'
#' @param block `[flag]`\cr
#'   Set to `FALSE` to return immediately instead of waiting.
#' @inheritParams travis_set_pat
#'
#' @export
travis_sync <- function(block = TRUE, token = travis_token(), quiet = FALSE) {
  user_id <- travis_user(token = token)[["id"]]

  req = travisHTTP(verb = "POST", path = sprintf("/user/%s/sync", user_id))

  check_status(req$response, cli::cat_bullet(bullet = "info",
                                             bullet_col = "yellow",
                                             "Initiating sync with GitHub."),
               quiet, 409)

  if (block) {
    cli::cat_bullet(
      bullet = "info", bullet_col = "yellow",
      "Waiting for sync with GitHub."
    )
    while (travis_user()[["is_syncing"]]) {
      Sys.sleep(1)
    }
    if (!quiet) message()
  }

  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    "Finished sync with GitHub."
  )
}

##' @importFrom usethis browse_travis
##' @export
NULL
