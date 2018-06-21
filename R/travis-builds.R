#' Travis CI builds
#'
#' @description
#' Functions around completed or pending Travis CI builds and jobs.
#'
#' `travis_get_builds()` calls the "/builds" API for the current repository.
#'
#' @inheritParams travis_set_pat
#'
#' @export
travis_get_builds <- function(repo = github_repo(), token = travis_token(repo),
                              repo_id = travis_repo_id(repo, token)) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  # I couldn't understand the semantics of the after_number parameter of this API
  req <- TRAVIS_GET("/builds", query = list(repository_id = repo_id),
                    token = token)
  httr::stop_for_status(
    req,
    sprintf("get builds for %s (id: %s) from Travis CI", repo, repo_id)
  )
  httr::content(req)[[1L]]
}

#' `travis_restart_build()` restarts a build with a given build ID.
#'
#' @param build_id `[integer(1)]`\cr
#'   The build ID, as obtained from `travis_get_builds()`.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_build <- function(build_id, repo = github_repo(), token = travis_token(repo),
                                 repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_POST(paste0("/builds/", build_id, "/restart"), token = token)
  check_status(
    req,
    sprintf(
      "restar[ting]{t} build %s for %s (id: %s) from Travis CI",
      build_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_restart_last_build()` restarts the *last* build.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_last_build <- function(repo = github_repo(), token = travis_token(repo),
                                 repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")
  last_build_id <- travis_get_builds(repo)$builds[[1]]$id
  req <- TRAVIS_POST(paste0("/builds/", last_build_id, "/restart"), token = token)
  check_status(
    req,
    sprintf(
      "restar[ting]{t} build %s for %s (id: %s) from Travis CI",
      build_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_cancel_build()` cancels a build with a given build ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_build <- function(build_id, repo = github_repo(), token = travis_token(repo),
                                repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_POST(paste0("/builds/", build_id, "/cancel"), token = token)
  check_status(
    req,
    sprintf(
      "cance[lling]{l} build %s for %s (id: %s) from Travis CI",
      build_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_restart_job()` restarts a job with a given job ID.
#'
#' @param job_id `[integer(1)]`\cr
#'   The job ID, as obtained from `travis_get_builds()`.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_job <- function(job_id, repo = github_repo(), token = travis_token(repo),
                               repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_POST(paste0("/job/", job_id, "/restart"), token = token)
  check_status(
    req,
    sprintf(
      "restar[ting]{t} job %s for %s (id: %s) from Travis CI",
      job_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_cancel_job()` cancels a job with a given job ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_job <- function(job_id, repo = github_repo(), token = travis_token(repo),
                              repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_POST(paste0("/job/", job_id, "/cancel"), token = token)
  check_status(
    req,
    sprintf(
      "cance[lling]{l} job %s for %s (id: %s) from Travis CI",
      job_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_debug_job()` restarts, in debug mode, a job with a given job ID.
#' See the \href{https://docs.travis-ci.com/user/running-build-in-debug-mode/}{Travis CI documentation}
#' for more details.
#'
#' @param log_output Show the debugging output in the publicly visible log? When
#'   set to `TRUE`, refrain from issuing commands that might expose secrets.
#' @export
#' @rdname travis_get_builds
travis_debug_job <- function(job_id,
                             log_output = FALSE,
                             repo = github_repo(),
                             token = travis_token(repo),
                             repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_POST3(paste0("/job/", job_id, "/debug"),
                      query = list(quiet = !log_output),
                      token = token)
  check_status(
    req,
    sprintf(
      "restar[ting]{t} debug job %s for %s (id: %s) from Travis CI",
      job_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}

#' `travis_job_log()` returns a build job log
#' @export
#' @rdname travis_get_builds
travis_get_log <- function(job_id,
                           log_output = FALSE,
                           repo = github_repo(),
                           token = travis_token(repo),
                           repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")

  req <- TRAVIS_GET(paste0("/job/", job_id, "/log"),
                    token = token)
  httr::content(req)[[1]]
}

#' `travis_delete_log()` deletes a build job log
#' @export
#' @rdname travis_get_builds
travis_delete_log <- function(job_id,
                              log_output = FALSE,
                              repo = github_repo(),
                              token = travis_token(repo),
                              repo_id = travis_repo_id(repo, token), quiet = FALSE) {
  if (!is.numeric(repo_id)) stopc("`repo_id` must be a number")
  if (!is.numeric(job_id)) stopc("`job_id` must be a number")
  
  req <- TRAVIS_DELETE(paste0("/job/", job_id, "/log"),
                       token = token)
  check_status(
    req,
    sprintf(
      "delet[ing]{e} log from job (id: %s) for %s (id: %s) on Travis CI",
      job_id, repo, repo_id
    ),
    quiet
  )
  invisible(httr::content(req)[[1]])
}
