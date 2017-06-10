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

#' @export
uses_github <- function(path = ".") {
  tryCatch(
    {
      info <- github_info(path)
      structure(TRUE, info = info, repo = github_repo(info = info))
    },
    error = function(e) {
      structure(FALSE, reason = conditionMessage(e))
    }
  )
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

get_repo_data <- function(repo, token = NULL) {
  req <- GITHUB_GET(paste0("/repos/", repo), token = token)
  httr::stop_for_status(req, paste("retrieve repo information for: ", repo))
  httr::content(req)
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
    stopc("Creating private repositories not supported.")
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

    check_write_org(org, gh_token)
  }

  req <- GITHUB_POST(url, body = data, token = gh_token)
  httr::stop_for_status(req, sprintf("create repo %s", name))
  invisible(httr::content(req))
}

#' @rdname github
#' @export
#' @param pubkey openssl public key, see [openssl::read_pubkey()].
#' @param gh_token GitHub token, as returned from [auth_github()]
github_add_key <- function(pubkey, title = "travis+tic",
                           path = ".", info = github_info(path),
                           repo = github_repo(info = info), gh_token = NULL) {
  if (inherits(pubkey, "key"))
    pubkey <- as.list(pubkey)$pubkey
  if (!inherits(pubkey, "pubkey"))
    stopc("Argument 'pubkey' is not an RSA/EC public key")

  if (info$owner$type == "User") {
    if (is.null(gh_token)) {
      gh_token <- auth_github(scopes = "public_repo")
    }
  } else {
    if (is.null(gh_token)) {
      gh_token <- auth_github(scopes = c("public_repo", "write:org"))
    }

    check_write_org(info$owner$login, gh_token)
  }

  key_data <- create_key_data(pubkey, title)

  # remove existing key
  remove_key_if_exists(key_data, repo, gh_token)
  # add public key to repo deploy keys on GitHub
  add_key(key_data, repo, gh_token)
}

create_key_data <- function(pubkey, title) {
  list(
    "title" = title,
    "key" = openssl::write_ssh(pubkey),
    "read_only" = FALSE
  )
}

remove_key_if_exists <- function(key_data, repo, gh_token) {
  req <- GITHUB_GET(
    sprintf("/repos/%s/keys", repo),
    token = gh_token
  )

  httr::stop_for_status(req, sprintf("query deploy keys on GitHub for repo %s", repo))
  keys <- httr::content(req)
  titles <- vapply(keys, "[[", "title", FUN.VALUE = character(1))
  our_title_idx <- which(titles == key_data$title)

  if (length(our_title_idx) == 0) return()

  our_title_idx <- our_title_idx[[1]]

  req <- GITHUB_DELETE(
    sprintf("/repos/%s/keys/%s", repo, keys[[our_title_idx]]$id),
    token = gh_token
  )
  httr::stop_for_status(req, sprintf("delete existing deploy key on GitHub for repo %s", repo))
}

add_key <- function(key_data, repo, gh_token) {
  req <- GITHUB_POST(
    sprintf("/repos/%s/keys", repo),
    body = key_data,
    token = gh_token
  )

  httr::stop_for_status(req, sprintf("add deploy keys on GitHub for repo %s", repo))
  invisible(httr::content(req))
}

check_write_org <- function(org, gh_token) {
  req <- GITHUB_GET(paste0("/user/memberships/orgs/", org), token = gh_token)
  if (httr::status_code(req) %in% 403) {
    org_perm_url <- paste0(
      "https://github.com/orgs/", org,
      "/policies/applications/390126")

    url_stop(
      "You may need to allow access for the rtravis GitHub app to your organization ", org,
      url = org_perm_url
    )
  }

  httr::stop_for_status(
    req,
    paste0(
      "query membership for organization ", org, ". ",
      "Check if you are a member of this organization"
    )
  )

  membership <- httr::content(req)
  role_in_org <- membership$role

  if (role_in_org != "admin") {
    stopc("Must have role admin to edit organization ", org, ", not ", role_in_org)
  }
}

#' @export
github_create_pat <- function(path = ".", repo = github_repo(path), pat = NULL) {
  if (!is.null(pat)) {
    return(pat)
  }
  if (!interactive()) {
    stopc("`pat` must be set in non-interactive mode")
  }

  desc <- paste0("travis+tic for ", repo)
  clipr::write_clip(desc)
  url_message(
    "Create a personal access token, make sure that you are signed in as the correct user. ",
    "The suggested description '", desc, "' has been copied to the clipboard. ",
    "If you use this token only to avoid GitHub's rate limit, you can leave all scopes unchecked. ",
    "Then, copy the new token to the clipboard, it will be detected and applied automatically",
    url = "https://github.com/settings/tokens/new"
  )

  wait_for_clipboard_pat()
}

wait_for_clipboard_pat <- function() {
  message("Waiting for PAT to appear on the clipboard.")
  repeat {
    pat <- clipr::read_clip()
    if (is_pat(pat)) break
    Sys.sleep(0.1)
  }
  message("Detected PAT, clearing clipboard.")
  clipr::write_clip("")
  pat
}

is_pat <- function(pat) {
  grepl("^[0-9a-f]{40}$", pat)
}
