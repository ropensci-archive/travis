#' @title Github API helpers
#' @description
#' - `auth_github()`: Creates a `GITHUB_TOKEN` and asks to store it in your
#' `.Renviron` file.
#'
#' @export
#' @keywords internal
#' @name github_helpers
auth_github <- function() {
  # authenticate on github
  token <- usethis::github_token()
  if (token == "") {
    cli::cli_alert_danger("{.pkg travis}: Please call
      {.code usethis::browse_github_token()} and follow the instructions.
      Then restart the session and try again.", wrap = TRUE)
  }
}

#' @description
#' - `get_owner()`: Returns the owner of a Github repo.
#'
#' @template remote
#' @keywords internal
#' @rdname github_helpers
#' @export
get_owner <- function(remote = "origin") {
  github_info(path = usethis::proj_get(), remote = remote)$owner$login
}

#' #' @description
#' - `get_user()`: Get the personal Github user name of a user
#'
#' @keywords internal
#' @rdname github_helpers
#' @export
get_user <- function() {
  github_user()$login
}

#' @description
#' - `get_repo()`: Returns the repo name of a Github repo for a given remote.
#'
#' @template remote
#' @keywords internal
#' @rdname github_helpers
#' @export
get_repo <- function(remote = "origin") {
  github_info(
    path = usethis::proj_get(),
    remote = remote
  )$name
}

#' @description
#' - `get_repo_slug()`: Returns the repo slug of a Github repo
#' (`<owner>/<repo>`).
#'
#' @template remote
#' @keywords internal
#' @rdname github_helpers
#' @export
get_repo_slug <- function(remote = "origin") {
  github_info(
    path = usethis::proj_get(),
    remote = remote
  )$full_name
}
