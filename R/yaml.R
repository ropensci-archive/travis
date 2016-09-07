edit_travis_yml <- function(travis_yml, tasks) {
  pkg <- "ropenscilabs/travis"
  if (!(pkg %in% travis_yml$r_github_packages)) {
    travis_yml$r_github_packages <- c(travis_yml$r_github_packages, pkg)
  }
  base_fun <- "R -e 'travis::deploy"
  task_arg <- sprintf('c("%s")', paste(tasks, collapse = ", "))
  script_command <- sprintf("%s(tasks = %s)'", base_fun, task_arg)
  in_after_success <- grepl(base_fun, travis_yml$after_success)
  if (any(in_after_success)) {
    travis_yml$after_success[which(in_after_success)] <- script_command
  } else {
    travis_yml$after_success <- c(travis_yml$after_success, script_command)
  }
  return(travis_yml)
}
