get_stage("before_install") %>%
  add_code_step(update.packages(ask = FALSE))

get_stage("install") %>%
  add_code_step(blogdown::install_hugo(), prepare_call = remotes::install_github("rstudio/blogdown"))

if (Sys.getenv("id_rsa") != "") {

  get_stage("before_deploy") %>%
    add_step(step_setup_ssh())

  get_stage("deploy") %>%
    add_code_step(blogdown::build_site()) %>%
    add_step(step_push_deploy())
}
