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
             httr::add_headers(Authorization = paste("token", token)),
             ...)
}

TRAVIS_DELETE <- function(url, ..., token) {
  httr::DELETE(travis(url), encode = "json",
               httr::user_agent("ropenscilabs/travis"),
               httr::accept('application/vnd.travis-ci.2+json'),
               httr::add_headers(Authorization = paste("token", token)),
               ...)
}

TravisToken <- R6::R6Class("TravisToken", inherit = httr::Token, list(
  init_credentials = function() {
    self$credentials <- auth_travis()
  },
  refresh = function(){
    self$credentials <- auth_travis()
  }
))

travis_token_ <- function(repo = NULL) {
  token <- auth_travis()
  if (!identical(travis_user(token)$correct_scopes, TRUE)) {
    url_stop("Please sign up with Travis using your GitHub credentials",
             url = "https://travis-ci.org")
  }
  if (!is.null(repo)) {
    if (!has_repo(repo, token)) {
      travis_sync(token = token)
      if (!has_repo(repo, token)) {
        review_travis_app_permission(repo)
      }
    }
  }
  token
}

has_repo <- function(repo, token) {
  repos <- travis_repositories(slug = repo, token = token)
  length(repos) > 0
}

review_travis_app_permission <- function(org) {
  url_stop("You may need to retry in a few seconds, or allow Travis access to your organization ", org,
           url = "https://github.com/settings/connections/applications/f244293c729d5066cf27")
}

#' Authenticate with Travis
#'
#' Authenticate with Travis using your Github account. Returns an access token.
#'
#' @export
#' @rdname travis
travis_token <- memoise::memoise(travis_token_)

auth_travis_ <- function(gtoken = NULL) {
  message("Authenticating with Travis")
  if (is.null(gtoken)) {
    gtoken <- auth_github_(
      cache = FALSE,
      scopes = c("read:org", "user:email", "repo_deployment", "repo:status", "read:repo_hook", "write:repo_hook"))
  }
  auth_travis_data <- list(
    "github_token" = gtoken$credentials$access_token
  )
  auth_travis <- httr::POST(
    url = travis('/auth/github'),
    httr::content_type_json(), httr::user_agent("Travis/1.0"),
    httr::accept("application/vnd.travis-ci.2+json"),
    body = auth_travis_data, encode = "json"
  )
  httr::stop_for_status(auth_travis, "authenticate with travis")
  httr::content(auth_travis)$access_token
}

#' @export
auth_travis <- memoise::memoise(auth_travis_)

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
  req <- httr::POST(travis(url),
             httr::user_agent("ropenscilabs/travis"),
             httr::accept('application/vnd.travis-ci.2+json'),
             httr::add_headers(Authorization = paste("token", token)))

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
  req <- TRAVIS_PUT(sprintf("/hooks"), body = list(hook = list(id = repo_id, active = active)))
  httr::stop_for_status(
    req, sprintf(
      "%s repo %s on travis",
      ifelse(active, "activate", "deactivate"), repo_id))
}

#' @export
travis_browse <- function(repo = github_repo()) {
  utils::browseURL(paste0("https://travis-ci.org/", repo))
}

setup_keys <- function(path, key_path, pub_key_path, enc_key_path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?
  pub_key <- as.list(key)$pubkey
  openssl::write_pem(pub_key, pub_key_path)

  # generate random variables for encryption
  tempkey <- openssl::rand_bytes(32)
  iv <- openssl::rand_bytes(16)

  # encrypt private key using tempkey and iv
  openssl::write_pem(key, key_path, password = NULL)
  blob <- openssl::aes_cbc_encrypt(key_path, tempkey, iv)
  attr(blob, "iv") <- NULL
  writeBin(blob, enc_key_path)
  invisible(file.remove(key_path))

  repo <- github_repo(path)

  # add tempkey and iv as secure environment variables on travis
  # TODO: overwrite if already exists
  travis_set_var("encryption_key", openssl::base64_encode(tempkey),
                 public = FALSE, repo = repo)
  travis_set_var("encryption_iv", openssl::base64_encode(iv),
                 public = FALSE, repo = repo)

  #print(sprintf("tempkey: %s", openssl::base64_encode(tempkey)))
  #print(sprintf("iv: %s", openssl::base64_encode(iv)))

  github_add_key(pub_key, path)
}
