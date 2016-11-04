github <- function(endpoint = "") {
  paste0("https://api.github.com", endpoint)
}

GITHUB_GET <- function(url, ..., token) {
  httr::GET(github(url),
            httr::user_agent("ropenscilabs/travis"),
            httr::accept("application/vnd.github.v3+json"),
            httr::config(token = token),
            ...)
}

GITHUB_PUT <- function(url, ..., token) {
  httr::PUT(github(url), encode = "json",
            httr::user_agent("ropenscilabs/travis"),
            httr::accept("application/vnd.github.v3+json"),
            httr::config(token = token),
            ...)
}

GITHUB_POST <- function(url, ..., token) {
  httr::POST(github(url), encode = "json",
             httr::user_agent("ropenscilabs/travis"),
             httr::accept("application/vnd.github.v3+json"),
             httr::config(token = token),
             ...)
}

GITHUB_DELETE <- function(url, ..., token) {
  httr::DELETE(github(url), encode = "json",
               httr::user_agent("ropenscilabs/travis"),
               httr::accept("application/vnd.github.v3+json"),
               httr::config(token = token),
               ...)
}

#' Github Information
#'
#' Retrieves metadata about a git repository from github.
#'
#' @export
#' @param path directory of the git repository
#' @rdname github
github_info <- function(path = ".") {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

#' @export
#' @rdname github
github_repo <- function(path = ".", info = github_info(path)) {
  paste(info$owner$login, info$name, sep = "/")
}

#' @export
github_create_repo <- function(path = ".", name = NULL, org = NULL, private = FALSE,
                               gh_token = NULL) {
  if (private) {
    stop("Creating private repositories not supported.", call. = FALSE)
  }

  if (is.null(name)) {
    name <- basename(normalizePath(path))
  }

  data <- list(
    "name" = name
  )

  if (is.null(org)) {
    url <- "/user/repos"
    if (is.null(gh_token)) {
      gh_token <- auth_github(scopes = "public_repo")
    }
  } else {
    url <- paste0("/orgs/", org, "/repos")
    if (is.null(gh_token)) {
      gh_token <- auth_github(scopes = c("public_repo", "write:org"))
    }
  }

  req <- GITHUB_POST(url, body = data, token = gh_token)
  if (httr::status_code(req) %in% 403) {
    on.exit(review_org_permission(org))
  }
  httr::stop_for_status(req, sprintf("create repo %s", name))
}

#' @rdname github
#' @export
#' @param pubkey openssl public key, see [openssl::read_pubkey()].
#' @param gh_token GitHub token, as returned from [auth_github()]
github_add_key <- function(pubkey, path = ".", info = github_info(path),
                           repo = github_repo(info = info), gh_token = NULL) {
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

  if (is.null(gh_token)) {
    if (info$owner$type == "Organization") {
      gh_token <- auth_github(scopes = c("public_repo", "write:org"))
    } else {
      gh_token <- auth_github(scopes = "public_repo")
    }
  }

  add_key <- GITHUB_POST(sprintf("/repos/%s/keys", repo),
                         body = key_data,
                         token = gh_token)
  if (httr::status_code(add_key) %in% 404) {
    org <- strsplit(repo, "/")[[1]][[1]]
    on.exit(review_org_permission(org))
  }
  httr::stop_for_status(add_key, sprintf("add deploy keys on GitHub for repo %s",  repo))
}

review_org_permission <- function(org) {
  org_perm_url <- paste0("https://github.com/orgs/",
                         org,
                         "/policies/applications/390126")
  url_message("You may need to allow access for the rtravis GitHub app to your organization ", org,
              url = org_perm_url)
}

get_repo_data <- function(repo) {
  req <- GITHUB_GET(paste0("/repos/", repo), token = NULL)
  httr::stop_for_status(req, paste("retrieve repo information for: ", repo))
  httr::content(req)
}
