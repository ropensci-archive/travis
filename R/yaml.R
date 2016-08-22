edit_travis_yml <- function(travis_yml) {
  pkg <- "ropenscilabs/travis"
  if (!(pkg %in% travis_yml$r_github_packages)) {
    travis_yml$r_github_packages <- c(travis_yml$r_github_packages, pkg)
  }
  script_command <- sprintf("R -e 'travis::deploy()'")
  if (!(script_command %in% travis_yml$after_success)) {
    travis_yml$after_success <- c(travis_yml$after_success, script_command)
  }
  return(travis_yml)
}
