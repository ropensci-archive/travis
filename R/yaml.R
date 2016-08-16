

add_travis_yml_var <- function(travis_yml, label, value) {
  var_index <- sapply(travis_yml$env$global,
                      function(var) is.character(var) && startsWith(var, label))
  if (any(var_index)) {
    travis_yml$env$global[[which(var_index)]] <- sprintf("%s=%s", label, value)
  } else {
    if (!is.null(names(travis_yml$env$global))) {
      travis_yml$env$global <- list(travis_yml$env$global)
    }
    travis_yml$env$global <- c(travis_yml$env$global,
                               sprintf("%s=%s", label, value))
  }
  return(travis_yml)
}

edit_travis_yml <- function(travis_yml, author_email, enc_id, script_file) {
  if (!is.null(travis_yml$env) && !("global" %in% names(travis_yml$env))) {
    if (length(travis_yml$env) > 1) {
      travis_yml$env <- list("matrix" = travis_yml$env)
    } else {
      travis_yml$env <- list("global" = travis_yml$env)
    }
  }
  travis_yml <- add_travis_yml_var(travis_yml, "AUTHOR_EMAIL", author_email)
  travis_yml <- add_travis_yml_var(travis_yml, "ENCRYPTION_LABEL", enc_id)

  script_command <- sprintf("chmod +x %s && %s", script_file,
                            file.path(".", script_file))
  if (!(script_command %in% travis_yml$after_success)) {
    travis_yml$after_success <- c(travis_yml$after_success, script_command)
  }
  return(travis_yml)
}
