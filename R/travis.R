TRAVIS_API <- "https://api.travis-ci.org"
GITHUB_API <- "https://api.github.com"

set_travis_var <- function(repo_id, name, value, public = FALSE, travis_token) {
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )
  req <- httr::POST(
    url = paste0(TRAVIS_API, "/settings/env_vars"),
    query = list(repository_id = repo_id),
    httr::add_headers(Authorization = paste("token", travis_token)),
    body = var_data, encode = "json"
  )
  httr::stop_for_status(req)
  return(NULL)
}

rand_char <- function() {
  num <- openssl::rand_num()
  chars <- c(0:9, letters, LETTERS)
  ranges <- cut(c(num, 0, 1), length(chars))
  chars[which(levels(ranges) == ranges[1])]
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
    "key" = as.list(public_key)$ssh,
    "read_only" = FALSE
  )
  add_key <- httr::POST(
    url = paste0(GITHUB_API, sprintf("/repos/%s/%s/keys", owner, repo)), gtoken,
    body = key_data, encode = "json"
  )
  httr::stop_for_status(add_key)

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
  httr::stop_for_status(travis_repo)
  repo_id <- httr::content(travis_repo)$id

  set_travis_var(repo_id, sprintf("encrypted_%s_key", enc_id),
                 paste(tempkey, collapse = ""), FALSE, travis_token)
  set_travis_var(repo_id, sprintf("encrypted_%s_iv", enc_id),
                 paste(iv, collapse = ""), FALSE, travis_token)

  return(enc_id)

}

auth_github <- function() {
  scopes <- c("repo", "read:org", "user:email", "write:repo_hook")
  app <- httr::oauth_app("github",
                         key = "4bca480fa14e7fb785a1",
                         secret = "70bb4da7bab3be6828808dd6ba37d19370b042d5")
  github_token <- httr::oauth2.0_token(httr::oauth_endpoints("github"), app,
                                       scope = scopes)
  gtoken <- httr::config(token = github_token)
  return(gtoken)
}

auth_travis <- function(gtoken) {
  # TODO: 403
  # auth_travis_data <- list(
  #   "github_token" = gtoken$auth_token$credentials$access_token
  # )
  # auth_travis <- httr::POST(
  #   url = paste0(TRAVIS_API, "/auth/github"),
  #   httr::content_type_json(), httr::user_agent("Travis/1.0"),
  #   httr::accept("application/vnd.travis-ci.2+json"),
  #   body = auth_travis_data, encode = "json"
  # )
  # httr::stop_for_status(auth_travis)
  # travis_token <- httr::content(auth_travis)$access_token
  travis_token <- readline(
    "What is your travis access token? (can be found in ~/.travis/config) "
  )
  return(travis_token)
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
    authors <- eval(parse(text = pkg$`authors@r`))
    roles <- if (!is.list(authors$role)) list(authors$role) else authors$role
    cre <- authors[sapply(roles, function(roles) "cre" %in% roles)]
    use_email <- utils::menu(c("Yes", "No"),
                             title = sprintf("Use %s as author email?",
                                             cre$email))
    if (use_email == 1) {
      author_email <- cre$email
    } else {
      author_email <- readline(prompt = "Please enter an author email: ")
    }
  }

  if (!file.exists(travis_path)) devtools::use_travis(pkg)
  travis_yml <- yaml::yaml.load_file(travis_path)

  # authenticate on github and travis and set up keys/vars
  gh <- devtools:::github_info(pkg$path)
  gtoken <- auth_github()
  travis_token <- auth_travis(gtoken)
  enc_id <- setup_keys(gh$username, gh$repo, gtoken, travis_token, key_path,
                       enc_key_path)

  # add vars to .travis.yml
  travis_yml$env$global <- c(travis_yml$env$global,
                             paste0("AUTHOR_EMAIL=", author_email),
                             paste0("ENCRYPTION_LABEL=", enc_id))
  travis_yml$after_success <- c(travis_yml$before_install,
                                paste("chmod 755", script_file),
                                file.path(".", script_file))
  writeLines(yaml::as.yaml(travis_yml), travis_path)

  # get push script to be run on travis
  script_src <- system.file("script", "push_gh_pages.sh",
                            package = "travis", mustWork = TRUE)
  file.copy(script_src, script_path)
  devtools::use_build_ignore(script_file, pkg = pkg)
  devtools::use_build_ignore(enc_key_file, pkg = pkg)

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
