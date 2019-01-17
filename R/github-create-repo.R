#' Create a repository on GitHub
#'
#' @description
#' Creates a GitHub repository.
#'
#' `github_create_repo()` only creates the repository on GitHub.
#'
#' @param path `[string]`\cr
#'   The path to the existing Git repository.
#' @param name `[string]`\cr
#'   The name of the new repository on GitHub, default: basename of the
#'   repo directory.
#' @param org `[string]`\cr
#'   The organization of the new repository on GitHub, default: user namespace,
#'   no organization.
#' @param private `[flag]`\cr
#'   Must be `FALSE`, creation of private repositories not yet supported.
#' @param gh_token `[Token2.0]`\cr
#'   GitHub authentication token, by default obtained from [auth_github()] with
#'   the "public_repo" and (if an organization repo) "write:org" scopes.
#' @param quiet `[flag]`\cr
#'   Set to `FALSE` to suppress success message.
#'
#' @family GitHub functions
#'
#' @export
github_create_repo <- function(name, org = NULL,
                               private = FALSE, gh_token = NULL, quiet = FALSE) {
  if (private) {
    stopc("Creating private repositories not supported.")
  }

  data <- list(
    "name" = name
  )

  if (is.null(org)) {
    url <- "/user/repos"
    if (is.null(gh_token)) {
      gh_token <- auth_github("public_repo")
    }
  } else {
    url <- paste0("/orgs/", org, "/repos")
    if (is.null(gh_token)) {
      gh_token <- auth_github("public_repo", "write:org")
    }

    check_write_org(org, gh_token)
  }

  req <- GITHUB_POST(url, body = data, token = gh_token)
  check_status(req, sprintf("creat[ing]{e} GitHub repository %s", name), quiet)
  invisible(httr::content(req))
}

#' @description
#' `use_github()` creates a GitHub repository for an existing Git repository,
#' and connects both.
#'
#' @param push `[flag]`\cr
#'   Should the contents of the existing repository be pushed to GitHub?
#'   Defaults to `FALSE` for non-interactive sessions, and asks the user
#'   in interactive sessions.
#'
#' @export
#' @rdname github_create_repo
use_github <- function(path = usethis::proj_get(), push = NA,
                       name = NULL, org = NULL, private = FALSE,
                       gh_token = NULL, quiet = FALSE) {

  if (uses_github(path)) {
    stopc("Already using GitHub")
  }

  r <- git2r::repository(path, discover = TRUE)

  if (is.null(name)) {
    name <- basename(normalizePath(path))
  }

  new_info <- github_create_repo(
    name = name, org = org, private = private,
    gh_token = gh_token, quiet = quiet
  )

  remote_url <- ask_remote_url(new_info$ssh_url, new_info$clone_url)

  if (!quiet) message("Setting origin remote to ", remote_url)
  git2r::remote_add(r, "origin", remote_url)

  if ("master" %in% names(git2r::branches(r, "local"))) {
    if (is.na(push)) push <- ask_push()

    if (push) {
      if (!quiet) message("Pushing master to origin")
      git2r::push(r, "origin", "refs/heads/master")
    } else {
      if (!quiet) message("Not pushed to GitHub yet")
    }
  } else {
    if (!quiet) message("master branch not found, cannot push to GitHub")
  }

  invisible(new_info)
}

ask_remote_url <- function(...) {
  urls <- c(...)
  if (!interactive()) return(urls[[1]])

  res <- utils::menu(urls, title = "Choose remote URL")
  urls[[res]]
}

ask_push <- function() {
  if (!interactive()) return(FALSE)

  utils::menu(c(
    "Push to GitHub, contents of your repository will be made public",
    "Do not push to GitHub"
  )) == 1
}


#' @description
#' `new_github()` creates an empty Git repository with a single commit and
#' a corresponding GitHub repository, and always pushes to GitHub.
#'
#' @param user `[person|string]`\cr
#'   An object of class [person], or a string that returns such an object
#'   when evaluated.
#' @export
#' @rdname github_create_repo
new_github <- function(path, user = getOption("devtools.desc.author"),
                       name = NULL, org = NULL, private = FALSE,
                       gh_token = NULL, quiet = FALSE) {

  if (!is.null(user)) {
    if (is.character(user)) {
      user <- eval(parse(text = user))
    }
    if (!inherits(user, "person")) {
      stopc("`user` must be a `person` object, or a string that evaluates to an object of class `person`, or `NULL`")
    }
  }

  dir.create(path, recursive = TRUE)
  r <- git2r::init(path)

  if (!is.null(user)) {
    git2r::config(
      r,
      user.name = format(user, include = c("given", "family")),
      user.email = format(user, include = "email", braces = list(email = ""))
    )
  }

  writeLines(character(), file.path(path, ".gitignore"))
  git2r::add(r, ".gitignore")
  git2r::commit(r, "initial", all = TRUE)

  use_github(
    path = path, push = TRUE, name = name, org = org, private = private,
    gh_token = gh_token, quiet = quiet
  )

}
