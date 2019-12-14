#' Travis CI utilities
#'
#' @description
#' Helper functions for Travis CI.
#'
#' `travis_sync()` initiates synchronization with GitHub and waits for
#' completion by default.
#' @param block `[flag]`\cr
#'   Set to `FALSE` to return immediately instead of waiting.
#' @template endpoint
#' @template quiet
#' @export
travis_sync <- function(block = TRUE,
                        endpoint = get_endpoint(),
                        quiet = FALSE) {

  user_id <- travis_user(quiet = quiet)[["id"]]

  req <- travis(
    verb = "POST", path = sprintf("/user/%s/sync", user_id),
    endpoint = endpoint
  )

  check_status(
    req$response,
    409
  )

  if (block) {
    if (!quiet) {
      cli::cli_alert_info("Waiting for sync with GitHub.")
    }
    while (travis_user(quiet = quiet)[["is_syncing"]]) {
      Sys.sleep(1)
    }
    message()
  }

  if (!quiet) {
    cli::cli_alert_success("Finished sync with GitHub.")
  }
  invisible(req)
}

#' @importFrom usethis browse_travis
#' @export
usethis::browse_travis
