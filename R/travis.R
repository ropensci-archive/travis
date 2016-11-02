travis <- function(endpoint = "") {
  paste0("https://api.travis-ci.org", endpoint)
}

TRAVIS_GET <- function(url, ...) {
  token <- travis_token()
  httr::GET(travis(url),
            httr::user_agent("ropenscilabs/travis"),
            httr::accept('application/vnd.travis-ci.2+json'),
            httr::add_headers(Authorization = paste("token", token)),
            ...)
}

TRAVIS_POST <- function(url, ...) {
  token <- travis_token()
  httr::POST(travis(url), encode = "json",
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

#' Authenticate with Travis
#'
#' Authenticate with Travis using your Github account. Returns an access token.
#' @export
#' @rdname travis
travis_token <- function() {
  auth_travis()
}

auth_travis_ <- function(gtoken = NULL) {
  message("Authenticating with Travis")
  if (is.null(gtoken)) {
    gtoken <- auth_github_(cache = FALSE)
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

auth_travis <- memoise::memoise(auth_travis_)

#' @export
travis_accounts <- function() {
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'))
  httr::stop_for_status(req, paste("list accounts"))
  jsonlite::fromJSON(httr::content(req, "text"))
}

#' @export
travis_repositories <- function(filter = "") {
  req <- TRAVIS_GET("/repos", query = list(search = filter))
  httr::stop_for_status(req, paste("list repositories"))
  jsonlite::fromJSON(httr::content(req, "text"))$repos
}

#' @export
travis_get_var <- function(repo_id) {
  if (!is.numeric(repo_id)) stop("repo_id must be a number")
  token <- travis_token()
  req <- TRAVIS_GET("/settings/env_vars", query = list(repository_id = repo_id))
  httr::stop_for_status(req, paste("get environment variable for", repo_id))
  jsonlite::fromJSON(httr::content(req, "text"))
}

#' @export
#' @rdname travis
travis_set_var <- function(repo_id, name, value, public = FALSE) {
  if (!is.numeric(repo_id)) stop("repo_id must be a number")
  token <- travis_token()
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )
  req <- TRAVIS_POST("/settings/env_vars",
                     query = list(repository_id = repo_id), body = var_data
  )
  httr::stop_for_status(req, sprintf("add environment variable to %s on travis",
                                     repo_id))
  invisible()
}

#' @export
#' @rdname travis
travis_repo_info <- function(owner, repo) {
  req <- TRAVIS_GET(sprintf("/repos/%s/%s", owner, repo))
  httr::stop_for_status(req, sprintf("get repo info on %s/%s from travis",
                                     owner, repo))
  jsonlite::fromJSON(httr::content(req, "text"))$repo
}

setup_keys <- function(owner, repo, key_path, pub_key_path, enc_key_path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?
  pub_key <- as.list(key)$pubkey
  openssl::write_pem(pub_key, pub_key_path)
  github_add_key(key, paste(owner, repo, sep = "/"))

  # generate random variables for encryption
  tempkey <- openssl::rand_bytes(32)
  iv <- openssl::rand_bytes(16)

  # encrypt private key using tempkey and iv
  openssl::write_pem(key, key_path, password = NULL)
  blob <- openssl::aes_cbc_encrypt(key_path, tempkey, iv)
  attr(blob, "iv") <- NULL
  writeBin(blob, enc_key_path)
  invisible(file.remove(key_path))

  # get the repo id
  repo_id <- travis_repo_info(owner, repo)$id

  # add tempkey and iv as secure environment variables on travis
  # TODO: overwrite if already exists
  travis_set_var(repo_id, "encryption_key", openssl::base64_encode(tempkey),
                 public = FALSE)
  travis_set_var(repo_id, "encryption_iv", openssl::base64_encode(iv),
                 public = FALSE)

  #print(sprintf("tempkey: %s", openssl::base64_encode(tempkey)))
  #print(sprintf("iv: %s", openssl::base64_encode(iv)))

}
