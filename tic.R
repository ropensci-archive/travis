do_package_checks()

if (ci_has_env("BUILD_PKGDOWN")) {
  get_stage("install") %>%
    add_step(step_install_github("ropensci/rotemplate"))
  do_pkgdown()
}
