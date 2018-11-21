add_package_checks()

### Create a pkgdown site ------------------------------------------------------
### Optionally build and deploy a pkgdown site via the CI service
### This has the opportunity to not have to commit man/, DESCRIPTION and NAMESPACE
### changes manually

# if (isTRUE(Sys.getenv("BUILD_PKGDOWN"))) {
#   # pkgdown documentation can be built optionally. Other example criteria:
#   # - `inherits(ci(), "TravisCI")`: Only for Travis CI
#   # - `ci()$is_tag()`: Only for tags, not for branches
#   # - `Sys.getenv("TRAVIS_EVENT_TYPE") == "cron"`: Only for Travis cron jobs
#   get_stage("before_deploy") %>%
#     add_step(step_setup_ssh())
#
#   get_stage("deploy") %>%
#     add_step(step_build_pkgdown()) %>%
#     add_step(step_push_deploy(path = "docs", branch = "gh-pages")) # orphan push to 'gh-pages' branch
#     # add_step(step_push_deploy(commit_paths = "docs/")) # single commit to master/docs
# }

### Update documentation -------------------------------------------------------
### Optionally build the documentation by the CI service
### This has the opportunity to not have to commit man/, DESCRIPTION and NAMESPACE
### changes manually

# if (ci()$get_branch() == "master") { # optionally only in the master branch
#
#   get_stage("deploy") %>%
#     # add_code_step(pkgbuild::compile_dll()) %>% # if the pkg has a src/ directory
#     add_code_step(devtools::document()) %>%
#     add_step(step_push_deploy(commit_paths = c("man/", "DESCRIPTION", "NAMESPACE")))
# }

### Create a covrpage page via https://yonicd.github.io/covrpage/ --------------
### 1. Runs covr::codecov().
### 2. Creates and deploys a tests/README.md file.
### Preview: https://github.com/yonicd/covrpage/tree/master/tests

# get_stage("deploy") %>%
#   add_code_step(covr::codecov()) %>%
#   add_code_step(devtools::install()) %>%
#   add_code_step(covrpage::covrpage_ci()) %>%
#   add_step(step_push_deploy(commit_paths = "tests/README.md"))

### Create a "project-health" page via https://itsalocke.com/projects/ ---------
### 1. Runs pRojects::get_project_health().
### 2. Creates and deploys a project health report to the "project-health" branch.
### Preview: https://github.com/lockedata/pRojects/tree/project-health

# get_stage("deploy") %>%
#   add_code_step(pRojects::get_project_health()) %>%
#   add_step(step_push_deploy(path = "health", branch = "project-health"))
