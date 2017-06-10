#' @export
travis_get_vars <- function(repo = github_repo(), token = travis_token(repo),
                            repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")
  req <- TRAVIS_GET("/settings/env_vars", query = list(repository_id = repo_id),
                    token = token)
  httr::stop_for_status(
    req,
    sprintf("get environment variables for %s (id: %s) from Travis CI", repo, repo_id)
  )
  httr::content(req)[[1L]]
}

#' @export
travis_get_var_id <- function(name, repo = github_repo(),
                              token = travis_token(repo),
                              repo_id = travis_repo_id(repo, token)) {
  vars <- travis_get_vars(repo = repo, token = token, repo_id = repo_id)
  var_idx <- which(vapply(vars, "[[", "name", FUN.VALUE = character(1)) == name)
  if (length(var_idx) > 0) {
    # Travis seems to use the value of the last variable if multiple vars of the
    # same name are defined; we update the last
    if (length(var_idx) > 1) {
      warningc(
        "Multiple entries found for variable ", name, ", updating the last entry."
      )
      var_idx <- var_idx[[length(var_idx)]]
    }
  } else if (length(var_idx) == 0) {
    return(NULL)
  }

  vars[[var_idx]]$id
}

#' @export
#' @rdname travis-package
travis_set_var <- function(name, value, public = FALSE, repo = github_repo(),
                           token = travis_token(repo),
                           repo_id = travis_repo_id(repo, token),
                           quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")

  var_id <- travis_get_var_id(
    name = name, repo = repo, token = token, repo_id = repo_id
  )

  if (!is.null(var_id)) {
    travis_patch_var(var_id, name, value, public, token, repo, repo_id, quiet)
  } else {
    travis_post_var(name, value, public, token, repo, repo_id, quiet)
  }
}

#' @export
#' @rdname travis-package
travis_delete_var <- function(name, repo = github_repo(),
                              token = travis_token(repo),
                              repo_id = travis_repo_id(repo, token),
                              id = travis_get_var_id(name, repo = repo, token = token, repo_id = repo_id),
                              quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")

  if (is.null(id)) stopc("`id` must not be NULL, or variable `name` not found")

  req <- TRAVIS_DELETE(paste0("/settings/env_vars/", id),
                       query = list(repository_id = repo_id),
                       token = token)
  check_status(
    req,
    sprintf(
      "delet[ing]{e} environment variable %s (id: %s) from %s (id: %s) on Travis CI",
      name, id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

travis_post_var <- function(name, value, public, token, repo, repo_id, quiet) {
  var_data <- list(
    "env_var" = list(
      "name" = name,
      "value" = value,
      "public" = public
    )
  )

  req <- TRAVIS_POST("/settings/env_vars",
                     query = list(repository_id = repo_id), body = var_data,
                     token = token)
  check_status(
    req,
    sprintf(
      "add[ing] %s environment variable %s to %s (id: %s) on Travis CI",
      if (public) "public" else "private", name, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

travis_patch_var <- function(id, name, value, public, token, repo, repo_id, quiet) {
  var_data <- list(
    "env_var" = list(
      "value" = value,
      "public" = public
    )
  )

  req <- TRAVIS_PATCH(paste0("/settings/env_vars/", id),
                      query = list(repository_id = repo_id), body = var_data,
                      token = token)
  check_status(
    req,
    sprintf(
      "updat[ing]{e} %s environment variable %s for %s (id: %s) on Travis CI",
      if (public) "public" else "private", name, repo, repo_id
    ),
    quiet
  )

  invisible(httr::content(req)[[1]])
}
