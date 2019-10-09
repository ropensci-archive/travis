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
#' @inheritParams travis_repo_info
#' @inheritParams github_repo
#' @inheritParams github_create_repo
#'
#' @family GitHub functions
#'
#' @seealso [github_create_repo()]
github_add_key <- function(pubkey, title = "travis+tic",
                           path = usethis::proj_get(), info = github_info(path),
                           quiet = FALSE) {

  if (inherits(pubkey, "key")) {
    pubkey <- as.list(pubkey)$pubkey
  }
  if (!inherits(pubkey, "pubkey")) {
    stopc("`pubkey` must be an RSA/EC public key")
  }

  repo <- github_repo(info = info)
  check_admin_repo(repo)

  key_data <- create_key_data(pubkey, title)

  # remove existing key
  remove_key_if_exists(key_data, repo, quiet)
  # add public key to repo deploy keys on GitHub
  ret <- add_key(key_data, repo, quiet)

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

remove_key_if_exists <- function(key_data, repo, quiet) {

  req = gh::gh(sprintf("GET /repos/%s/keys", repo))

  if (length(req[[1]]) == 1) {
    return()
  }


  # FIXME: catch status returns to process errors
  gh::gh(sprintf("DELETE %s", req[[1]]$url))

  message(sprintf("delet[ing]{e} existing deploy key on GitHub for repo %s", repo))
}

add_key <- function(key_data, repo, quiet) {

  # FIXME: catch status returns to process errors
  gh::gh(sprintf("POST /repos/%s/keys", repo), title = key_data$title,
         key = key_data$key, read_only = key_data$read_only)

  message(sprintf("ad[ding]{d} deploy keys on GitHub for repo %s", repo))
}
