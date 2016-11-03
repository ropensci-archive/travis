GITHUB_API <- "https://api.github.com"

#' Github Information
#'
#' Retrieves metadata about a git repository from github.
#'
#' @export
#' @param path directory of the git repository
#' @rdname github
github_info <- function(path = ".") {
  remote_url <- get_github_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

#' @export
#' @rdname github
github_repo <- function(path = ".") {
  info <- github_info(path)
  paste(info$owner$login, info$name, sep = "/")
}

#' @rdname github
#' @export
#' @param pubkey openssl public key, see \link[openssl:read_pubkey]{openssl::read_pubkey}.
github_add_key <- function(pubkey, repo = github_repo()) {
  gtoken <- auth_github()
  if (inherits(pubkey, "key"))
    pubkey <- as.list(pubkey)$pubkey
  if (!inherits(pubkey, "pubkey"))
    stop("Argumnet 'pubkey' is not an RSA/EC public key")

  # add public key to repo deploy keys on GitHub
  key_data <- list(
    "title" = paste("travis", Sys.time()),
    "key" = openssl::write_ssh(pubkey),
    "read_only" = FALSE
  )
  add_key <- httr::POST(
    url = paste0(GITHUB_API, sprintf("/repos/%s/keys", repo)),
    httr::config(token = gtoken), body = key_data, encode = "json"
  )
  if (httr::status_code(add_key) %in% 404) {
    org_perm_url <- paste0("https://github.com/orgs/",
                           strsplit(repo, "/")[[1]][[1]],
                           "/policies/applications/390126")
    on.exit(
      message("You may need to allow access for the rtravis GitHub app to your organization at: \n  ",
              org_perm_url))
  }
  httr::stop_for_status(add_key, sprintf("add deploy keys on GitHub for repo %s",  repo))
}

get_repo_data <- function(repo) {
  req <- httr::GET(paste0(GITHUB_API, "/repos/", repo))
  httr::stop_for_status(req, paste("retrieve repo information for: ", repo))
  jsonlite::fromJSON(httr::content(req, "text"))
}

get_github_url <- function(path) {
  r <- git2r::repository(path, discover = TRUE)
  remote_names <- git2r::remotes(r)
  if (!length(remote_names))
    stop("Failed to lookup git remotes")
  remote_name <- "origin"
  if (!("origin" %in% remote_names)) {
    remote_name <- remote_names[1]
    warning("No remote 'origin' found. Using: ", remote_name)
  }
  git2r::remote_url(r, remote_name)
}

extract_repo <- function(path) {
  if (grepl("^git@github.com:", path)) {
    path <- sub("^git@github.com:", "https://github.com/", path)
  } else if (grepl("^git://github.com", path)) {
    path <- sub("^git://github.com", "https://github.com", path)
  } else if (grepl("^http://github.com", path)) {
    path <- sub("^http://github.com", "https://github.com", path)
  }
  if (!all(grepl("^https://github.com", path))) {
    stop("Unrecognized repo format: ", path)
  }
  path <- sub("\\.git", "", path)
  sub("^https://github.com/", "", path)
}

auth_github_ <- function(cache = NULL) {
  message("Authenticating with GitHub")
  if (is.null(cache)) {
    cache <- getOption("httr_oauth_cache")
  }

  scopes <- c("repo", "read:org", "user:email", "write:repo_hook")
  app <- httr::oauth_app("github",
                         key = "4bca480fa14e7fb785a1",
                         secret = "70bb4da7bab3be6828808dd6ba37d19370b042d5")
  httr::oauth2.0_token(httr::oauth_endpoints("github"), app, scope = scopes, cache = cache)
}

auth_github <- memoise::memoise(auth_github_)
