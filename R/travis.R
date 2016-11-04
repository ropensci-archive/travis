travis <- function(endpoint = "") {
  paste0("https://api.travis-ci.org", endpoint)
}

TRAVIS_GET <- function(url, ..., token) {
  httr::GET(travis(url),
            httr::user_agent("ropenscilabs/travis"),
            httr::accept('application/vnd.travis-ci.2+json'),
            httr::add_headers(Authorization = paste("token", token)),
            ...)
}

TRAVIS_PUT <- function(url, ..., token) {
  httr::PUT(travis(url), encode = "json",
            httr::user_agent("ropenscilabs/travis"),
            httr::accept('application/vnd.travis-ci.2+json'),
            httr::add_headers(Authorization = paste("token", token)),
            ...)
}

TRAVIS_POST <- function(url, ..., token) {
  httr::POST(travis(url), encode = "json",
             httr::user_agent("ropenscilabs/travis"),
             httr::accept('application/vnd.travis-ci.2+json'),
             if (!is.null(token)) httr::add_headers(Authorization = paste("token", token)),
             ...)
}

TRAVIS_DELETE <- function(url, ..., token) {
  httr::DELETE(travis(url), encode = "json",
               httr::user_agent("ropenscilabs/travis"),
               httr::accept('application/vnd.travis-ci.2+json'),
               httr::add_headers(Authorization = paste("token", token)),
               ...)
}

#' @export
travis_accounts <- function(token = travis_token()) {
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'), token = token)
  httr::stop_for_status(req, paste("list accounts"))
  httr::content(req)[[1L]]
}

#' @export
travis_repositories <- function(slug = NULL, search = NULL, token = travis_token()) {
  req <- TRAVIS_GET("/repos", query = list(slug = slug, search = search), token = token)
  httr::stop_for_status(req, paste("list repositories"))
  httr::content(req)[[1L]]
}

#' @export
travis_user <- function(token = travis_token()) {
  req <- TRAVIS_GET("/users/", token = token)
  httr::stop_for_status(req, paste("get current user information"))
  httr::content(req)[[1L]]
}

#' @export
travis_sync <- function(block = TRUE, token = travis_token()) {
  url <- "/users/sync"
  req <- TRAVIS_POST(url, token = token)

  if (!(httr::status_code(req) %in% c(200, 409))) {
    httr::stop_for_status(req, "synch user")
  }

  if (block) {
    message("Waiting for sync with GitHub", appendLF = FALSE)
    while(travis_user()$is_syncing) {
      message(".", appendLF = FALSE)
      write_lf <- TRUE
      Sys.sleep(1)
    }
    message()
  }
}

#' @export
travis_get_vars <- function(repo = github_repo(), token = travis_token(repo),
                            repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stop("repo_id must be a number")
  req <- TRAVIS_GET("/settings/env_vars", query = list(repository_id = repo_id),
                    token = token)
  httr::stop_for_status(req, paste("get environment variable for", repo_id))
  httr::content(req)[[1L]]
}

#' @export
#' @rdname travis
travis_set_var <- function(name, value, public = FALSE, repo = github_repo(),
                           token = travis_token(repo), repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stop("repo_id must be a number")
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )

  req <- TRAVIS_POST("/settings/env_vars",
                     query = list(repository_id = repo_id), body = var_data,
                     token = token)
  httr::stop_for_status(req, sprintf("add %s environment variable %s to %s on travis",
                                     if (public) "public" else "private", name, repo_id))
}

#' @export
#' @rdname travis
travis_delete_var <- function(id, repo = github_repo(),
                              token = travis_token(repo), repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stop("repo_id must be a number")
  req <- TRAVIS_DELETE(paste0("/settings/env_vars/", id),
                       query = list(repository_id = repo_id),
                       token = token)
  httr::stop_for_status(req, sprintf("delete environment variable id=%s on travis",
                                     repo_id))
}

#' @export
#' @rdname travis
travis_repo_info <- function(repo = github_repo(),
                             token = travis_token(repo)) {
  req <- TRAVIS_GET(sprintf("/repos/%s", repo), token = token)
  httr::stop_for_status(req, sprintf("get repo info on %s from Travis", repo))
  httr::content(req)[[1L]]
}

#' @export
#' @rdname travis
travis_repo_id <- function(repo = github_repo(), token = travis_token(repo), ...) {
  travis_repo_info(repo = repo, ..., token = token)$id
}

#' @export
#' @rdname travis
travis_enable <- function(active = TRUE, repo = github_repo(),
                          token = travis_token(repo), repo_id = travis_repo_id(repo, token = token)) {
  req <- TRAVIS_PUT(sprintf("/hooks"),
                    body = list(hook = list(id = repo_id, active = active)),
                    token = token)
  httr::stop_for_status(
    req, sprintf(
      "%s repo %s on travis",
      ifelse(active, "activate", "deactivate"), repo_id))
}

#' @export
travis_browse <- function(repo = github_repo()) {
  utils::browseURL(paste0("https://travis-ci.org/", repo))
}
