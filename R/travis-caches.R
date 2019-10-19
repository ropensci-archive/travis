#' Get/delete repository cache(s) from Travis CI
#'
#' @description
#' Return cache information
#'
#' `travis_get_caches()` queries the "/repos/:repo/caches" API.
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#' @param token \cr
#'   A Travis CI API token obtained from [auth_travis()].
#' @family Travis CI functions
#'
#' @export
travis_get_caches <- function(repo = github_repo(),
                              token = auth_travis()) {
  req <- TRAVIS_GET3(sprintf("/repo/%s/caches", encode_slug(repo)), token = token)
  check_status(
    req,
    sprintf(
      "get[ting] caches for %s on Travis CI",
      repo
    )
  )
  new_travis_caches(httr::content(req))
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
travis_delete_caches <- function(repo = github_repo(),
                                 token = auth_travis()) {

  req <- TRAVIS_DELETE3(sprintf("/repo/%s/caches", encode_slug(repo)), token = token)
  check_status(
    req,
    sprintf(
      "delet[ing]{e} caches for %s on Travis CI",
      repo
    )
  )
  invisible(new_travis_caches(httr::content(req)))
}
