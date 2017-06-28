#' Getting tic testing up and running
#'
#' Prepares a repo for building and deploying supported by \pkg{tic}.
#'
#' @param path `[string]`\cr
#'   The path to the repo to prepare.
#' @param quiet `[flag]`\cr
#'   Less verbose output? Default: `FALSE`.
#'
#' @export
use_tic <- function(path = ".", quiet = FALSE) {
  #' @details
  #' The preparation consists of the following steps:
  withr::with_dir(path, {
    #' 1. If necessary, create a GitHub repository via [use_github()]
    use_github_interactive()
    stopifnot(uses_github())

    #' 1. Enable Travis via [travis_enable()]
    travis_enable()
    #' 1. Create a default `.travis.yml` file
    #'    (overwrite after confirmation in interactive mode only)
    use_travis_yml()
    #' 1. Create a default `appveyor.yml` file
    #'    (depending on repo type, overwrite after confirmation
    #'    in interactive mode only)
    repo_type <- detect_repo_type()
    if (needs_appveyor(repo_type)) use_appveyor_yml()

    #' 1. Create a default `tic.R` file depending on the repo type
    #'    (package, website, bookdown, ...)
    use_tic_r(repo_type)

    #' 1. Enable deployment (if necessary, depending on repo type)
    #'    via [use_travis_deploy()]
    if (needs_deploy(repo_type)) use_travis_deploy()

    #' 1. Create a GitHub PAT and install it on Travis CI via [travis_set_pat()]
    travis_set_pat()
  })

  #'
  #' This function is aimed at supporting the most common use cases.
  #' Users who require more control are advised to manually call the individual
  #' functions.
}

use_github_interactive <- function() {
  if (!interactive()) return()
  if (uses_github()) return()

  if (!yesno("Create GitHub repo and push code?")) return()

  message("Creating GitHub repository")
  use_github(push = TRUE)
}

use_travis_yml <- function() {
  use_template("dot-travis.yml", target = ".travis.yml")
}

use_appveyor_yml <- function() {
  use_template("appveyor.yml")
}

use_tic_r <- function(repo_type) {
  use_template(repo_type, "tic.R")
}

use_template <- function(..., target = basename(file.path(...))) {
  source <- template_file(...)
  safe_filecopy(source, target)
  message("Added ", target, " from template.")
  usethis::use_build_ignore(target)
}

template_file <- function(...) {
  system.file("templates", ..., package = utils::packageName(), mustWork = TRUE)
}

safe_filecopy <- function(source, target = basename(source)) {
  eval(bquote(stopifnot(file.exists(.(source)))))
  check_overwrite(target)
  file.copy(source, target, overwrite = TRUE)
}

check_overwrite <- function(path) {
  if (file.exists(path)) {
    if (!interactive()) stopc("Not overwriting ", path, " in non-interactive mode.")
    stopifnot(yesno("Overwrite ", path, "?"))
  }
}

yesno <- function(...) {
  utils::menu(c("Yes", "No"), title = paste0(...)) == 1
}

detect_repo_type <- function() {
  if (file.exists("_bookdown.yml")) return("bookdown")
  if (file.exists("_site.yml")) return("site")
  if (file.exists("config.toml")) return("blogdown")
  if (file.exists("DESCRIPTION")) return("package")
  "unknown"
}

needs_appveyor <- function(repo_type) {
  repo_type == "package"
}

needs_deploy <- function(repo_type) {
  repo_type != "unknown"
}
