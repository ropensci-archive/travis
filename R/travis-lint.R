#' Linting
#'
#' This checks if a \samp{.travis.yml} file is valid, and identifies possible errors.
#'
#' This function may incorrectly report valid `.travis.yml` files as broken,
#' in particular if `language: r` is used (which is the default for R projects).
#'
#' @inheritParams travis_set_pat
#'
#' @param file A character string specifying a path to a \samp{.travis.yml} file.
#'
#' @return A list.
#' @examples
#' \dontrun{
#' travis_lint()
#' }
#' @export
travis_lint <- function(file = ".travis.yml", repo = github_repo(), token = travis_token(repo), quiet = FALSE) {
  req <- TRAVIS_POST3(
    "/lint",
    body = httr::upload_file(file),
    encode = "raw",
    token = token
  )

  check_status(
    req,
    sprintf("lint[ing] %s", file),
    quiet
  )

  new_travis_lint(httr::content(req))
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
