#' Add a deploy key to GitHub
#'
#' Adds a public deploy key to an existing GitHub repository.
#' An existing key of the same name is dropped.
#'
#' @export
#' @param pubkey `[pubkey]`\cr
#'   openssl public key, see [openssl::read_pubkey()].
#' @param title `[string]`\cr
#'   The title for the new key, default: "travis+tic".
#' @param gh_token `[Token2.0]`\cr
#'   GitHub authentication token, by default obtained from [auth_github()] with
#'   the "public_repo" and (if an organization repo) "write:org" scopes.
#' @inheritParams travis_repo_info
#' @inheritParams github_repo
#' @inheritParams github_create_repo
#'
#' @family GitHub functions
#'
#' @seealso [github_create_repo()]
github_add_key <- function(pubkey, title = "travis+tic",
                           path = usethis::proj_get(), info = github_info(path),
                           gh_token = NULL, quiet = FALSE) {

  if (inherits(pubkey, "key")) {
    pubkey <- as.list(pubkey)$pubkey
  }
  if (!inherits(pubkey, "pubkey")) {
    stopc("`pubkey` must be an RSA/EC public key")
  }

  if (is.null(gh_token)) {
    if (info$owner$type == "User") {
      gh_token <- auth_github("public_repo")
    } else {
      gh_token <- auth_github("public_repo", "write:org")
    }
  }

  repo <- github_repo(info = info)
  check_admin_repo(repo, gh_token)

  key_data <- create_key_data(pubkey, title)

  # remove existing key
  remove_key_if_exists(key_data, repo, gh_token, quiet)
  # add public key to repo deploy keys on GitHub
  ret <- add_key(key_data, repo, gh_token, quiet)

  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    paste0("Successfully added public deploy key ", title, "' to GitHub for ", repo, ". ")
  )
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " You should receive a confirmation e-mail from GitHub."
  )
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Delete the key in the repository's settings to revoke access for that key or when you no longer need it."
  )

  invisible(ret)
}

create_key_data <- function(pubkey, title) {
  list(
    "title" = title,
    "key" = openssl::write_ssh(pubkey),
    "read_only" = FALSE
  )
}

remove_key_if_exists <- function(key_data, repo, gh_token, quiet) {
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
  check_status(req, sprintf("delet[ing]{e} existing deploy key on GitHub for repo %s", repo), quiet)
}

add_key <- function(key_data, repo, gh_token, quiet) {
  req <- GITHUB_POST(
    sprintf("/repos/%s/keys", repo),
    body = key_data,
    token = gh_token
  )

  check_status(req, sprintf("ad[ding]{d} deploy keys on GitHub for repo %s", repo), quiet)
  invisible(httr::content(req))
}
