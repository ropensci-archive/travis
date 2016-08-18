travis <- function(endpoint = ""){
  paste0("https://api.travis-ci.org", endpoint)
}

TRAVIS_GET <- function(url, ...){
  token <- travis_token()
  httr::GET(travis(url),
    httr::user_agent("ropenscilabs/travis"),
    httr::accept('application/vnd.travis-ci.2+json'),
    httr::add_headers(Authorization = paste("token", token)),
    ...)
}

TRAVIS_POST <- function(url, ...){
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
travis_token <- function(refresh = FALSE){
  gtoken <- travis:::auth_github()
  app <- httr::oauth_app("travis", key = "", secret = gtoken$credentials$access_token)
  endpoint <- httr::oauth_endpoint(NULL, NULL, travis('/auth/github'))
  token <- TravisToken$new(app, endpoint)
  if(refresh) token$refresh()
  token$credentials
}

auth_travis <- function(gtoken = auth_github()) {
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
travis_accounts <- function(){
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'))
  httr::stop_for_status(req, paste("list accounts"))
  jsonlite::fromJSON(httr::content(req, "text"))
}

#' @export
travis_repositories <- function(filter = ""){
  req <- TRAVIS_GET("/repos", query = list(search = filter))
  httr::stop_for_status(req, paste("list repositories"))
  jsonlite::fromJSON(httr::content(req, "text"))$repos
}

#' @export
travis_get_var <- function(repo_id){
  if(!is.numeric(repo_id)) stop("repo_id must be a number")
  token <- travis_token()
  req <- TRAVIS_GET("/settings/env_vars", query = list(repository_id = repo_id))
  httr::stop_for_status(req, paste("get environment variable for", repo_id))
  jsonlite::fromJSON(httr::content(req, "text"))
}

#' @export
#' @rdname travis
travis_set_var <- function(repo_id, name, value, public = FALSE) {
  if(!is.numeric(repo_id)) stop("repo_id must be a number")
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
  httr::stop_for_status(req, sprintf("add environment variable to %s on travis", repo_id))
  invisible()
}

rand_char <- function() {
  chars <- c(0:9, letters, LETTERS)
  sample(chars, 1)
}

rand_string <- function(length) {
  paste(replicate(length, rand_char()), collapse = "")
}

setup_keys <- function(owner, repo, gtoken, travis_token, key_path,
                       enc_key_path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?
  github_add_key(key, paste(owner, repo, sep = "/"))

  #NOTE: it might be easier to encrypt with travis_pubkey()

  # generate random variables for encryption
  enc_id <- rand_string(12)
  tempkey <- openssl::rand_bytes(32)
  iv <- openssl::rand_bytes(16)

  # encrypt private key using tempkey and iv
  openssl::write_pem(key, key_path, password = NULL)
  blob <- openssl::aes_cbc_encrypt(key_path, tempkey, iv)
  attr(blob, "iv") <- NULL
  writeBin(blob, enc_key_path)
  invisible(file.remove(key_path))

  # add tempkey and iv as secure environment variables on travis
  travis_repo <- httr::GET(
    url = travis(sprintf("/repos/%s/%s", owner, repo)),
    httr::add_headers(Authorization = paste("token", travis_token))
  )
  httr::stop_for_status(travis_repo, sprintf("get repo info on %s/%s from travis", owner, repo))
  repo_id <- httr::content(travis_repo)$id

  set_travis_var(repo_id, sprintf("encrypted_%s_key", enc_id),
                 paste(tempkey, collapse = ""), FALSE, travis_token)
  set_travis_var(repo_id, sprintf("encrypted_%s_iv", enc_id),
                 paste(iv, collapse = ""), FALSE, travis_token)

  return(enc_id)

}
