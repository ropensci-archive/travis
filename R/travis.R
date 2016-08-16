TRAVIS_API <- "https://api.travis-ci.org"

TravisToken <- R6::R6Class("TravisToken", inherit = httr::Token, list(
  init_credentials = function() {
    self$credentials <- auth_travis()
  }
))

#' Authenticate with Travis
#'
#' Authenticate with Travis using your Github account. Returns an access token.
#' @export
travis_get_token <- function(){
  gtoken <- travis:::auth_github()
  app <- httr::oauth_app("travis", key = "", secret = gtoken$credentials$access_token)
  endpoint <- httr::oauth_endpoint(NULL, NULL, TRAVIS_API)
  TravisToken$new(app, endpoint)$credentials
}

auth_travis <- function(gtoken = auth_github()) {
  auth_travis_data <- list(
    "github_token" = gtoken$credentials$access_token
  )
  auth_travis <- httr::POST(
    url = paste0(TRAVIS_API, "/auth/github"),
    httr::content_type_json(), httr::user_agent("Travis/1.0"),
    httr::accept("application/vnd.travis-ci.2+json"),
    body = auth_travis_data, encode = "json"
  )
  httr::stop_for_status(auth_travis, "authenticate with travis")
  travis_token <- httr::content(auth_travis)$access_token
  return(travis_token)
}

travis_set_var <- function(repo, name, value, public = FALSE, travis_token) {
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )
  req <- httr::POST(
    url = paste0(TRAVIS_API, "/settings/env_vars"),
    query = list(repository_id = repo),
    httr::add_headers(Authorization = paste("token", travis_token)),
    body = var_data, encode = "json"
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
  public_key <- as.list(key)$pubkey

  # add public key to repo deploy keys on GitHub
  key_data <- list(
    "title" = paste("travis", Sys.time()),
    "key" = write_ssh(public_key),
    "read_only" = FALSE
  )
  add_key <- httr::POST(
    url = paste0(GITHUB_API, sprintf("/repos/%s/%s/keys", owner, repo)),
    httr::config(token = gtoken), body = key_data, encode = "json"
  )
  httr::stop_for_status(add_key, sprintf("add deploy keys on GitHub for repo %s/%s", owner, repo))

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
    url = paste0(TRAVIS_API, sprintf("/repos/%s/%s", owner, repo)),
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




add_travis_yml_var <- function(travis_yml, label, value) {
  var_index <- sapply(travis_yml$env$global,
                      function(var) is.character(var) && startsWith(var, label))
  if (any(var_index)) {
    travis_yml$env$global[[which(var_index)]] <- sprintf("%s=%s", label, value)
  } else {
    if (!is.null(names(travis_yml$env$global))) {
      travis_yml$env$global <- list(travis_yml$env$global)
    }
    travis_yml$env$global <- c(travis_yml$env$global,
                               sprintf("%s=%s", label, value))
  }
  return(travis_yml)
}

edit_travis_yml <- function(travis_yml, author_email, enc_id, script_file) {
  if (!is.null(travis_yml$env) && !("global" %in% names(travis_yml$env))) {
    if (length(travis_yml$env) > 1) {
      travis_yml$env <- list("matrix" = travis_yml$env)
    } else {
      travis_yml$env <- list("global" = travis_yml$env)
    }
  }
  travis_yml <- add_travis_yml_var(travis_yml, "AUTHOR_EMAIL", author_email)
  travis_yml <- add_travis_yml_var(travis_yml, "ENCRYPTION_LABEL", enc_id)

  script_command <- sprintf("chmod +x %s && %s", script_file,
                            file.path(".", script_file))
  if (!(script_command %in% travis_yml$after_success)) {
    travis_yml$after_success <- c(travis_yml$after_success, script_command)
  }
  return(travis_yml)
}

#' Use travis vignettes
#'
#' @param pkg package description, can be path or package name. See
#'   \code{\link{as.package}} for more information.
#' @param author_email Email that will be used for commits on your behalf.
#'
#' @export
use_travis_vignettes <- function(pkg = ".", author_email = NULL) {
  pkg <- devtools::as.package(pkg)
  travis_path <- file.path(pkg$path, ".travis.yml")
  key_file <- ".deploy_key"
  key_path <- file.path(pkg$path, key_file)
  enc_key_file <- paste0(key_file, ".enc")
  enc_key_path <- file.path(pkg$path, enc_key_file)
  script_file <- ".push_gh_pages.sh"
  script_path <- file.path(pkg$path, script_file)

  if (is.null(author_email)) {
    author_email <- devtools:::maintainer(pkg)$email
  }

  if (!file.exists(travis_path)) devtools::use_travis(pkg)
  travis_yml <- yaml::yaml.load_file(travis_path)

  # authenticate on github and travis and set up keys/vars
  gh <- github_info(pkg$path)
  username <- gh$owner$login
  repo <- gh$name
  gtoken <- auth_github()
  travis_token <- auth_travis(gtoken)

  enc_id <- setup_keys(username, repo, gtoken, travis_token, key_path,
                       enc_key_path)

  # get push script to be run on travis
  script_src <- system.file("script", "push_gh_pages.sh",
                            package = "travis", mustWork = TRUE)
  file.copy(script_src, script_path)

  # add new files to .Rbuildignore
  devtools::use_build_ignore(enc_key_file, pkg = pkg)
  devtools::use_build_ignore(script_file, pkg = pkg)

  # update .travis.yml
  new_travis_yml <- edit_travis_yml(travis_yml, author_email, enc_id, script_file)
  writeLines(yaml::as.yaml(new_travis_yml), travis_path)

  # commit changes to git
  r <- git2r::repository(pkg$path)
  st <- vapply(git2r::status(r), length, integer(1))
  if (any(st != 0)) {
    git2r::add(r, ".Rbuildignore")
    git2r::add(r, ".travis.yml")
    git2r::add(r, script_file)
    git2r::add(r, enc_key_file)
    git2r::commit(r, "set up travis pushing vignettes to gh-pages")
  }

}
