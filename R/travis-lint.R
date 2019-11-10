#' Linting
#'
#' This checks if a \samp{.travis.yml} file is valid, and identifies possible errors.
#'
#' This function may incorrectly report valid `.travis.yml` files as broken,
#' in particular if `language: r` is used (which is the default for R projects).
#'
#' @inheritParams travis_set_pat
#' @import httr
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#' @param file A character string specifying a path to a \samp{.travis.yml} file.
#' @template endpoint
#'
#' @return A list.
#' @examples
#' \dontrun{
#' travis_lint()
#' }
#' @export
travis_lint <- function(file = ".travis.yml", repo = github_repo(),
                        endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  req = travis(verb = "POST",
                   path = "/lint", body = upload_file(file),
                   encode = "raw",
                   endpoint = endpoint)
  browser()
  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf("Linting %s", file)
    )
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
