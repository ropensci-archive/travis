set_travis_var <- function(repo_id, name, value, public = FALSE, token) {
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )
  env_vars_url <- sprintf(
    "https://api.travis-ci.org/settings/env_vars?repository_id=%s", repo_id
  )
  req <- httr::POST(env_vars_url,
                    httr::add_headers(Authorization = paste("token", token)),
                    body = jsonlite::toJSON(var_data, auto_unbox = TRUE))
  #assertthat::assert_that(req$status_code == 200)
  return(NULL)
}

setup_keys <- function(username, repo, fullname, travis_token, key_path, enc_key_path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?
  public_key <- as.list(key)$pubkey

  # add public key to repo deploy keys on GitHub
  key_data <- list(
    "title" = paste("travis", Sys.time()),
    "key" = as.list(public_key)$ssh,
    "read_only" = FALSE
  )
  create_key <- github::create.repository.key(
    username, repo, jsonlite::toJSON(key_data, auto_unbox = TRUE)
  )
  #assertthat::assert_that(create_key$ok)

  # generate random variables for encryption
  enc_id <- stringi::stri_rand_strings(1, 12)
  tempkey <- openssl::rand_bytes(32)
  iv <- openssl::rand_bytes(16)

  # encrypt private key using tempkey and iv
  openssl::write_pem(key, key_path, password = NULL)
  blob <- openssl::aes_cbc_encrypt(key_path, tempkey, iv)
  attr(blob, "iv") <- NULL
  writeBin(blob, enc_key_path)
  invisible(file.remove(key_path))

  # add tempkey and iv as secure environment variables on travis
  repo <- httr::GET(
    sprintf("https://api.travis-ci.org/repos/%s", fullname),
    httr::add_headers(Authorization = paste("token", travis_token))
  )

  repo_id <- httr::content(repo)$id
  set_travis_var(repo_id, sprintf("encrypted_%s_key", enc_id),
                 paste(tempkey, collapse = ""), FALSE, travis_token)
  set_travis_var(repo_id, sprintf("encrypted_%s_iv", enc_id),
                 paste(iv, collapse = ""), FALSE, travis_token)

  return(enc_id)

}

auth_github_travis <- function() {
  scopes <- c("repo", "read:org", "user:email", "write:repo_hook")
  ctx <- github::interactive.login(scopes = scopes)
  github_token <- ctx$token$credentials$access_token
  # TODO: 403
  # auth_travis <- httr::POST(
  #   "https://api.travis-ci.org/auth/github",
  #   httr::content_type_json(), httr::user_agent("Travis/1.0"),
  #   httr::accept("application/vnd.travis-ci.2+json"),
  #   data = jsonlite::toJSON(list("github_token" = github_token),
  #                           auto_unbox = TRUE)
  # )
  #
  # travis_token <- httr::content(auth_travis)$access_token
  travis_token <- readline(prompt = "What is your travis access token? (can be found in ~/.travis/config) ")
  return(travis_token)
}

#' Use travis vignettes
#'
#' @param author_email Email that will be used for commits on your behalf.
#' @param pkg package description, can be path or package name. See
#'   \code{\link{as.package}} for more information.
#'
#' @export
use_travis_vignettes <- function(author_email, pkg = ".") {
  pkg <- devtools::as.package(pkg)
  travis_path <- file.path(pkg$path, ".travis.yml")
  key_file <- ".deploy_key"
  key_path <- file.path(pkg$path, key_file)
  enc_key_file <- paste0(key_file, ".enc")
  enc_key_path <- file.path(pkg$path, enc_key_file)
  script_file <- ".push_gh_pages.sh"
  script_path <- file.path(pkg$path, script_file)

  if (!file.exists(travis_path)) devtools::use_travis(pkg)
  travis_yml <- yaml::yaml.load_file(travis_path)

  # authenticate on github and travis and set up keys/vars
  gh <- devtools:::github_info(pkg$path)
  travis_token <- auth_github_travis()
  enc_id <- setup_keys(gh$username, gh$repo, gh$fullname, travis_token,
                       key_path, enc_key_path)

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
