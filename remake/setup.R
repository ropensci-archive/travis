create_id <- function(value = NULL) {
  if (is.null(value)) {
    value <- gsub("_", "-", ids::adjective_animal())
    message(value)
  }
  value
}

create_github_user <- function(user, password) {
  clipr::write_clip(user)
  menu(c("OK"), title = paste0("Please create GitHub user ", user, " with password ", password))

  user
}

create_github_org <- function(org) {
  clipr::write_clip(org)
  menu(c("OK"), title = paste0("Please create GitHub organization ", org))

  org
}

create_git_repo <- function(repo_path) {
  unlink(repo_path, recursive = TRUE, force = TRUE)
  dir.create(repo_path, recursive = TRUE, showWarnings = FALSE)
  repo <- git2r::init(repo_path)

  git2r::config(repo, user.name = "user.name", user.email = "user@ema.il")

  writeLines(character(), file.path(repo_path, ".gitignore"))
  git2r::add(repo, ".gitignore")
  git2r::commit(repo, "initial")

  devtools::setup(repo_path)
  git2r::add(repo, ".")
  git2r::commit(repo, "infra")

  repo
}

create_gh_repo <- function(user, password, repo, org = NULL) {
  tryCatch(travis::github_repo(repo@path),
           error = function(e) do_create_gh_repo(user, password, repo, org))
}

do_create_gh_repo <- function(user, password, repo, org = NULL) {
  message("Current user: ", user)
  clipr::write_clip(user)
  r <- travis::github_create_repo(repo@path, org = org)
  res <- httr::content(r)

  remote_name <- "origin"
  git2r::remote_add(repo, remote_name, gsub("//", paste0("//", user, ":", password, "@"), res$clone_url))

  git2r::push(repo, remote_name, "refs/heads/master")

  res$full_name
}

create_travis_token <- function(user) {
  utils::browseURL("https://travis-ci.org")
  menu("OK", title = paste0("Please authenticate user ", user, " for Travis"))
  message("Please authenticate Travis user ", user)
  travis::auth_travis()
}

enable_travis_for_repo <- function(repo, travis_token) {
  withr::with_dir(
    repo@path,
    travis::travis_enable()
  )
}

setup_keys_for_repo <- function(repo) {
  1
  travis::use_travis_deploy(repo@path)
}
