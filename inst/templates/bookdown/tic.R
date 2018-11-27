get_stage("before_install") %>%
  add_code_step(update.packages(ask = FALSE))

get_stage("install") %>%
  add_code_step(remotes::install_deps(dependencies = TRUE))

get_stage("deploy") %>%
  add_code_step(
    bookdown::render_book('index.Rmd', 'bookdown::gitbook'),
    prepare_call = remotes::install_github("rstudio/bookdown")
  )

if (Sys.getenv("id_rsa") != "") {

  get_stage("before_deploy") %>%
    add_step(step_setup_ssh())

  get_stage("deploy") %>%
    add_step(step_push_deploy(path = "_book", branch = "gh-pages"))
}
