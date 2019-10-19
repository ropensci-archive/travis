github_add_key <- function(pubkey, repo = NULL, user = NULL,
                           title = "travis") {
  if (is.null(user)) {
    user <- github_info()$owner$login
  }
  if (is.null(repo)) {
    repo <- github_info()$name
  }

  if (inherits(pubkey, "key")) {
    pubkey <- as.list(pubkey)$pubkey
  }
  if (!inherits(pubkey, "pubkey")) {
    stop("`pubkey` must be an RSA/EC public key")
  }

  # check if we have enough rights to add a key
  check_admin_repo(github_info()$owner$login, user, repo)

  key_data <- create_key_data(pubkey, title)

  # remove existing key
  remove_key_if_exists(key_data, user, repo)
  # add public key to repo deploy keys on GitHub
  ret <- add_key(key_data, user, repo)

  cli::cat_rule()
  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    sprintf("Added a public deploy key to GitHub for repo '%s'.", repo)
  )

  invisible(ret)
}

check_admin_repo <- function(owner, user, repo) {
  role_in_repo <- get_role_in_repo(owner, user, repo)
  if (role_in_repo != "admin") {
    stop("Must have role admin to add deploy key to repo ", repo, ", not ", role_in_repo)
  }
}

add_key <- function(key_data, user, project) {

  # FIXME: catch status returns to process errors
  resp <- gh::gh("POST /repos/:owner/:repo/keys",
                 owner = user, repo = project,
                 title = key_data$title,
                 key = key_data$key, read_only = key_data$read_only
  )

  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    sprintf("Adding deploy keys on GitHub and Circle CI for repo '%s'.", project)
  )

  invisible(resp)
}

get_role_in_repo <- function(owner, user, repo) {

  req <- gh::gh("/repos/:owner/:repo/collaborators/:username/permission",
                owner = owner, repo = repo, username = user
  )
  req$permission
}

github_user <- function() {
  req <- gh::gh("GET /user")
  return(req)
}

remove_key_if_exists <- function(key_data, user, repo) {
  req <- gh::gh("/repos/:owner/:repo/keys", owner = user, repo = repo)

  if (length(req[[1]]) == 1) {
    return()
  }

  gh::gh(sprintf("DELETE %s", req[[1]]$url))
}

create_key_data <- function(pubkey, title) {
  list(
    "title" = title,
    "key" = openssl::write_ssh(pubkey),
    "read_only" = FALSE
  )
}

#' @description
#' `github_repo()` returns the true repository name as string.
#'
#' @param info `[list]`\cr
#'   GitHub information for the repository, by default obtained through
#'   [github_info()].
#'
#' @export
#' @rdname github_info
github_repo <- function(path = usethis::proj_get(), info = github_info(path)) {
  paste(info$owner$login, info$name, sep = "/")
}

#' Github information
#'
#' @description
#' Retrieves metadata about a Git repository from GitHub.
#'
#' `github_info()` returns a list as obtained from the GET "/repos/:repo" API.
#'
#' @param path `[string]`\cr
#'   The path to a GitHub-enabled Git repository (or a subdirectory thereof).
#' @family GitHub functions
github_info <- function(path = usethis::proj_get()) {
  remote_url <- get_remote_url(path)
  repo <- extract_repo(remote_url)
  get_repo_data(repo)
}

get_repo_data <- function(repo) {
  req = gh::gh("/repos/:repo", repo = repo)
  return(req)
}
