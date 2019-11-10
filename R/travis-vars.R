#' Travis CI variables
#'
#' @description
#' Functions around public and private variables available in Travis CI builds.
#'
#' `travis_get_vars()` calls the "/settings/env_vars" API.
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the structure of ´<user>/<repo>´.
#' @export
#' @examples
#' \dontrun{
#' # List all variables:
#' travis_get_vars()
#' }
travis_get_vars <- function(repo = github_repo(), endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  req = travis(path = sprintf("/repo/%s/env_vars", encode_slug(repo)),
                   endpoint = endpoint)

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Get environment variables for '%s' on Travis CI.", repo
      )
    )
    new_travis_env_vars(content(req$response))
  }
}

new_travis_env_vars <- function(x) {
  stopifnot(x[["@type"]] == "env_vars")
  new_travis_collection(
    lapply(x[["env_vars"]], new_travis_env_var),
    travis_attr(x),
    "env_vars"
  )
}

new_travis_env_var <- function(x) {
  stopifnot(x[["@type"]] == "env_var")
  new_travis_object(x, "env_var")
}

#' @description
#' `travis_get_var_id()` retrieves the ID for a variable name, or `NULL`.
#' If multiple variables exist by that name, it returns the ID of the last
#' (with a warning),
#' because this is what seems to be used in Travis CI builds in such a case.
#'
#' @param name `[string]`\cr
#'   The name of the variable.
#'
#' @export
#' @rdname travis_get_vars
#' @examples
#' \dontrun{
#' # Get the ID of a variable.
#' travis_get_var_id("secret_var")
#' }
travis_get_var_id <- function(name, repo = github_repo(), endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  vars <- travis_get_vars(repo = repo, endpoint = endpoint)
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

#' @description
#' `travis_set_var()` creates or updates a variable.
#' If multiple variables exist by that name, it updates the last (with a warning),
#' because this is what seems to be used in Travis CI builds in such a case.
#'
#' @details
#' Avoid using `travis_set_var()` with literal values, because they will be
#' recorded in the `.Rhistory` file.
#'
#' @param value `[string]`\cr
#'   The value for the new or updated variable.
#' @param public `[flag]`\cr
#'   Should the variable be public or private?
#'
#' @export
#' @rdname travis_get_vars
#' @examples
#' \dontrun{
#' # Avoid calling with literal values:
#' travis_set_var("secret_var", "oh no - this will be recorded in .Rhistory!")
#'
#' # Set a Travis environment variable without recording it in history
#' # by reading the value from the console:
#' travis_set_var("secret_var", readLines(n = 1))
#' }
travis_set_var <- function(name, value, public = FALSE, repo = github_repo(),
                           endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  var_data <- list(
    "env_var.name" = name,
    "env_var.value" = value,
    "env_var.public" = public
  )

  req = travis(verb = "POST", sprintf("/repo/%s/env_vars", encode_slug(repo)),
                   body = var_data, endpoint = endpoint)

  if (status_code(req$response) == 201) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Adding environment variables for '%s' on Travis CI.", repo
      )
    )
    new_travis_env_var(content(req$response))
  }
}

#' @description
#' `travis_delete_var()` deletes a variable.
#'
#' @param id `[string]`\cr
#'   The ID of the variable, by default obtained from `travis_get_var_id()`.
#' @template endpoint
#'
#' @export
#' @rdname travis_get_vars
#' @examples
#' \dontrun{
#' # Delete a variable:
#' travis_delete_var("secret_var")
#' }
travis_delete_var <- function(name, repo = github_repo(),
                              id = travis_get_var_id(name, repo = repo),
                              endpoint = endpoint) {

  if (is.null(endpoint)) {
    endpoint = Sys.getenv("R_TRAVIS", unset = "ask")
  }

  if (is.null(id)) stopc(paste0("`id` must not be NULL; or variable `name` not found.",
                         " Does it really exist? Check with `travis_get_vars()`.",
                         collapse = ""))

  req = travis(verb = "DELETE", sprintf("/repo/%s/env_var/%s",
                                            encode_slug(repo), id),
                   endpoint = endpoint)

  if (status_code(req) == 204) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Deleting environment variable with id = '%s' for '%s' on Travis CI.",
        id, repo
      )
    )
    invisible(req)
  }
}
