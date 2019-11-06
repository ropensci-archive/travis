#' Get/delete repository cache(s) from Travis CI
#'
#' @description
#' Return cache information
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#' @details
#' `travis_get_caches()` queries the `"/repos/:repo/caches"` API.
#'
#' @inheritParams travis_set_pat
#'
#' @family Travis CI functions
#'
#' @export
travis_get_caches <- function(repo = github_repo()) {

  req = travisHTTP(path = sprintf("/repo/%s/caches", encode_slug(repo)))

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Getting caches for '%s' on Travis CI.", repo
      )
    )
  }
  new_travis_caches(httr::content(req$response))
}


new_travis_caches <- function(x) {
  stopifnot(x[["@type"]] == "caches")
  new_travis_collection(
    lapply(x[["caches"]], new_travis_cache),
    travis_attr(x),
    "caches"
  )
}

new_travis_cache <- function(x) {
  stopifnot(x[["@type"]] == "cache")
  new_travis_object(x, "cache")
}

#' @description
#' `travis_delete_caches()` returns the repo ID obtained from `travis_repo_info()`.
#'
#' @export
#' @rdname travis_get_caches
travis_delete_caches <- function(repo = github_repo()) {
  req = travisHTTP(verb = "DELETE", path = sprintf("/repo/%s/caches", encode_slug(repo)))

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Deleting caches for '%s' on Travis CI.", repo
      )
    )
    invisible(new_travis_caches(content(req$response)))
  }
}
