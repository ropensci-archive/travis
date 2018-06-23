#' Get/delete repository cache(s) from Travis CI
#'
#' @description
#' Return cache information
#'
#' `travis_get_caches()` queries the "/repos/:repo/caches" API.
#'
#' @inheritParams travis_set_pat
#'
#' @family Travis CI functions
#'
#' @export
travis_get_caches <- function(repo = github_repo(),
                              token = travis_token(repo),
                              quiet = FALSE) {
  req <- TRAVIS_GET3(sprintf("/repo/%s/caches", encode_slug(repo)), token = token)
  check_status(
    req,
    sprintf(
      "get[ting] caches for %s on Travis CI",
      repo
    ),
    quiet
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
                                 token = travis_token(repo),
                                 repo_id = travis_repo_id(repo, token),
                                 quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_DELETE3(sprintf("/repo/%s/caches", repo_id), token = token)
  check_status(
    req,
    sprintf(
      "delet[ing]{e} caches for %s (id: %s) on Travis CI",
      repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}
