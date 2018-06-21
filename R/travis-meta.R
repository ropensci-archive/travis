#' Retrieve meta information from Travis CI
#'
#' @description
#' Return account, repositories, and user information.
#'
#' `travis_accounts()` queries the "/accounts" API.
#'
#' @inheritParams travis_repo_info
#'
#' @seealso [Travis CI API documentation](https://docs.travis-ci.com/api)
#'
#' @family Travis CI functions
#'
#' @export
travis_accounts <- function(token = travis_token()) {
  req <- TRAVIS_GET("/accounts", query = list(all = 'true'), token = token)
  httr::stop_for_status(req, paste("list accounts"))
  lapply(httr::content(req)[[1L]], `class<-`, "travis_account")
}

#' @export
print.travis_account <- function(x, ...) {
    cat("Account (", x$id, "): ", x$name, "\n", sep = "")
    cat("Type: ", x$type, "\n", sep = "")
    cat("Login: ", x$login, "\n", sep = "")
    cat("Repos: ", x$repos_count, "\n", sep = "")
    invisible(x)
}

#' @description
#' `travis_repositories()` queries the "/repos" API.
#'
#' @param slug,search `[string]`\cr
#'   Arguments to the API call
#'
#' @export
#'
#' @rdname travis_accounts
travis_repositories <- function(slug = NULL, search = NULL, token = travis_token()) {
  req <- TRAVIS_GET("/repos", query = list(slug = slug, search = search), token = token)
  httr::stop_for_status(req, paste("list repositories"))
  lapply(httr::content(req)[[1L]], `class<-`, "travis_repository")
}

#' @export
print.travis_repository <- function(x, ...) {
    cat("Repo (", x$id, "): ", x$slug, "\n", sep = "")
    cat("Active: ", as.character(x$active), "\n", sep = "")
    cat("Description: ", x$description, "\n", sep = "")
    cat("Language: ", x$github_language, "\n", sep = "")
    cat("Last Build (", x$last_build_id, ") Status: ", x$last_build_state, "\n", sep = "")
    cat("Last Build Finished: ", x$last_build_finished_at, "\n\n", sep = "")
    invisible(x)
}

#' @description
#' `travis_user()` queries the "/users" API.
#'
#' @export
#'
#' @rdname travis_accounts
travis_user <- function(token = travis_token()) {
  req <- TRAVIS_GET("/users/", token = token)
  httr::stop_for_status(req, paste("get current user information"))
  lapply(httr::content(req)[[1L]], `class<-`, "travis_repository")
}

#' @export
print.travis_user <- function(x, ...) {
    cat("User (", x$id, "): ", x$name, "\n", sep = "")
    cat("Login: ", x$login, "\n", sep = "")
    cat("Email: ", x$email, "\n", sep = "")
    cat("Correct scopes: ", as.character(x$correct_scopes), "\n", sep = "")
    invisible(x)
}
