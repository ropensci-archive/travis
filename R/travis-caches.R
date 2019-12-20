#' Get/delete repository cache(s) from Travis CI
#'
#' @description
#' Return cache information
#' @template repo
#' @template endpoint
#' @template quiet
#' @template ellipsis
#' @details
#' `travis_get_caches()` queries the `"/repos/:repo/caches"` API.
#'
#' @family Travis CI functions
#'
#' @export
travis_get_caches <- function(repo = github_repo(),
                              endpoint = get_endpoint(),
                              quiet = FALSE,
                              ...) {

  req <- travis(
    path = sprintf("/repo/%s/caches", encode_slug(repo)),
    endpoint = endpoint,
    ...
  )

  stop_for_status(
    req$response, "get caches for repo."
  )

  if (!quiet) {
    cli::cli_alert_info(
      "Getting caches for {.code {repo}} on Travis CI."
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
#' `travis_delete_caches()` returns the repo ID obtained from
#' `travis_repo_info()`.
#'
#' @export
#' @rdname travis_get_caches
travis_delete_caches <- function(repo = github_repo(),
                                 endpoint = get_endpoint(),
                                 ...) {

  req <- travis(
    verb = "DELETE", path = sprintf("/repo/%s/caches", encode_slug(repo)),
    endpoint = endpoint,
    ...
  )

  stop_for_status(
    req$response, "delete caches for repo."
  )

  cli::cli_alert_success("Deleted caches for {.code {repo}} on Travis CI.")
  invisible(new_travis_caches(content(req$response)))
}
