#' Linting
#'
#' This checks if a \samp{.travis.yml} file is valid, and identifies possible
#' errors.
#'
#' This function may incorrectly report valid `.travis.yml` files as broken,
#' in particular if `language: r` is used (which is the default for R projects).
#'
#' @import httr
#' @param file A character string specifying a path to a \samp{.travis.yml}
#'   file or a URL.
#' @template repo
#' @template endpoint
#'
#' @return A list.
#' @examples
#' \dontrun{
#' travis_lint()
#' }
#' @export
travis_lint <- function(file = ".travis.yml", repo = github_repo(),
                        endpoint = get_endpoint()) {

  if (!file.exists(file) && !http_error(file)) {
    writeLines(readLines(file), paste0(tempdir(), "/file.yml"))
    file = paste0(tempdir(), "/file.yml")
  }

  req <- travis(
    verb = "POST",
    path = "/lint",
    body = upload_file(file),
    encode = "raw",
    endpoint = endpoint
  )
  if (status_code(req$response) == 200) {
    cli::cli_alert_info("Linting {.file {file}}.")
    new_travis_lint(content(req$response))
  }
}

new_travis_lint <- function(x) {
  stopifnot(x[["@type"]] == "lint")
  new_travis_collection(
    lapply(x[["warnings"]], new_travis_warning),
    travis_attr(x),
    "warnings"
  )
}

new_travis_warning <- function(x) {
  new_travis_object(x, "warning")
}
