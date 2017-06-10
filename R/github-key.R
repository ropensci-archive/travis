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
