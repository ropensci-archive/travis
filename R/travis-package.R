#' @details
#' Use [github_repo()] to get the name of the current repository
#' as determined from the `origin` remote. The [github_info()]
#' function queries basic information on your repository.
#' The following functions simplify integrating R package testing and deployment
#' with GitHub and Travis CI:
#' - [github_create_repo()] creates a repository on GitHub,
#' - [travis_enable()] enables Travis CI for your repository,
#' - [travis_set_pat()] installs a `GITHUB_PAT` environment variable on Travis
#'   to work around rate limitations for installing packages from GitHub,
#' - [use_travis_deploy()] installs a public deploy key on GitHub and the
#'   corresponding private key on Travis CI to simplify deployments to GitHub
#'   from Travis CI.
#' All these functions ask for permission the first time you call them.
"_PACKAGE"
