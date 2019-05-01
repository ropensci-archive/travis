#' Travis CI variables
#'
#' @description
#' Functions around public and private variables available in Travis CI builds.
#'
#' `travis_get_vars()` calls the "/settings/env_vars" API.
#'
#' @inheritParams travis_set_pat
#'
#' @export
#' @examples
#' \dontrun{
#' # List all variables:
#' travis_get_vars()
#' }
travis_get_vars <- function(repo = github_repo(), token = travis_token(repo)) {
  req <- TRAVIS_GET3(sprintf("/repo/%s/env_vars", encode_slug(repo)),
    token = token
  )
  httr::stop_for_status(
    req,
    sprintf("get environment variables for %s from Travis CI", repo)
  )
  new_travis_env_vars(httr::content(req))
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
travis_get_var_id <- function(name, repo = github_repo(),
                              token = travis_token(repo)) {
  vars <- travis_get_vars(repo = repo, token = token)
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
#' Avoid using `travis_set_var()` with literal values
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
                           token = travis_token(repo),
                           quiet = FALSE) {
  var_id <- travis_get_var_id(
    name = name, repo = repo, token = token
  )

  if (!is.null(var_id)) {
    travis_patch_var(var_id, name, value, public, token, repo, quiet)
  } else {
    travis_post_var(name, value, public, token, repo, quiet)
  }
}

#' @description
#' `travis_delete_var()` deletes a variable.
#'
#' @param id `[string]`\cr
#'   The ID of the variable, by default obtained from `travis_get_var_id()`.
#'
#' @export
#' @rdname travis_get_vars
#' @examples
#' \dontrun{
#' # Delete a variable:
#' travis_delete_var("secret_var")
#' }
travis_delete_var <- function(name, repo = github_repo(),
                              token = travis_token(repo),
                              id = travis_get_var_id(name, repo = repo, token = token),
                              quiet = FALSE) {
  if (is.null(id)) stopc("`id` must not be NULL, or variable `name` not found")

  req <- TRAVIS_DELETE3(sprintf("/repo/%s/env_var/%s", encode_slug(repo), id),
    token = token
  )
  check_status(
    req,
    sprintf(
      "delet[ing]{e} environment variable %s (id: %s) from %s on Travis CI",
      name, id, repo
    ),
    quiet
  )
  invisible(httr::content(req))
}

travis_post_var <- function(name, value, public, token, repo, quiet) {
  var_data <- list(
    "env_var.name" = name,
    "env_var.value" = value,
    "env_var.public" = public
  )

  req <- TRAVIS_POST3(sprintf("/repo/%s/env_vars", encode_slug(repo)),
    body = var_data,
    token = token
  )
  check_status(
    req,
    sprintf(
      "ad[ding]{d} %s environment variable %s to %s on Travis CI",
      if (public) "public" else "private", name, repo
    ),
    quiet
  )
  invisible(new_travis_env_var(httr::content(req)))
}

travis_patch_var <- function(id, name, value, public, token, repo, quiet) {
  var_data <- list(
    "env_var.value" = value,
    "env_var.public" = public
  )

  req <- TRAVIS_PATCH3(sprintf("/repo/%s/env_var/%s", encode_slug(repo), id),
    body = var_data,
    token = token
  )
  check_status(
    req,
    sprintf(
      "updat[ing]{e} %s environment variable %s for %s on Travis CI",
      if (public) "public" else "private", name, repo
    ),
    quiet
  )

  invisible(new_travis_env_var(httr::content(req)))
}
