#' @export
travis_get_vars <- function(repo = github_repo(), token = travis_token(repo),
                            repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")
  req <- TRAVIS_GET("/settings/env_vars", query = list(repository_id = repo_id),
                    token = token)
  httr::stop_for_status(req, paste("get environment variable for", repo_id))
  httr::content(req)[[1L]]
}

#' @export
#' @rdname travis-package
travis_set_var <- function(name, value, public = FALSE, repo = github_repo(),
                           token = travis_token(repo), repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")

  vars <- travis_get_vars(token = token, repo_id = repo_id)
  var_idx <- which(vapply(vars, "[[", "name", FUN.VALUE = character(1)) == name)
  if (length(var_idx) > 0) {
    # Travis seems to use the value of the last variable if multiple vars of the
    # same name are defined; we update the last
    if (length(var_idx) > 1) {
      warningc(
        "Multiple entries found for ", name, ", updating the last entry."
      )
      var_idx <- var_idx[[length(var_idx)]]
    }
    var <- vars[[var_idx]]
    travis_patch_var(
      var$id, value, public = public,
      token = token, repo_id = repo_id
    )
  } else {
    travis_post_var(
      name, value, public = public,
      token = token, repo_id = repo_id
    )
  }
}

travis_post_var <- function(name, value, public = FALSE, token, repo_id) {
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
  httr::stop_for_status(req, sprintf("add %s environment variable %s to %s on travis",
                                     if (public) "public" else "private", name, repo_id))
  invisible(httr::content(req)[[1]])
}

travis_patch_var <- function(id, value, public = FALSE, token, repo_id) {
  var_data <- list(
    "env_var" = list(
      "value" = value,
      "public" = public
    )
  )

  req <- TRAVIS_PATCH(paste0("/settings/env_vars/", id),
                      query = list(repository_id = repo_id), body = var_data,
                      token = token)
  httr::stop_for_status(req, sprintf("update %s environment variable %s to %s on travis",
                                     if (public) "public" else "private", name, repo_id))
  invisible(httr::content(req)[[1]])
}

#' @export
#' @rdname travis-package
travis_delete_var <- function(id, repo = github_repo(),
                              token = travis_token(repo), repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stopc("repo_id must be a number")
  req <- TRAVIS_DELETE(paste0("/settings/env_vars/", id),
                       query = list(repository_id = repo_id),
                       token = token)
  httr::stop_for_status(req, sprintf("delete environment variable id=%s on travis",
                                     repo_id))
  invisible(httr::content(req)[[1]])
}
