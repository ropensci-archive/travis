#' Travis CI builds
#'
#' @description
#' Functions around completed or pending Travis CI builds and jobs.
#' @param repo `[string]`\cr
#'   The repository slug to use. Must follow the "`user/repo`" structure.
#' `travis_get_builds()` calls the "builds" API for the current repository.
#' @template endpoint
#'
#' @export
travis_get_builds <- function(repo = github_repo(),
                              endpoint = get_endpoint()) {

  req <- travis(
    path = sprintf("/repo/%s/builds", encode_slug(repo)),
    endpoint = endpoint
  )

  stop_for_status(
    req$response,
    sprintf("get builds for %s from Travis CI", repo)
  )
  new_travis_builds(content(req$response))
}

new_travis_builds <- function(x) {
  stopifnot(x[["@type"]] == "builds")
  new_travis_collection(
    lapply(x[["builds"]], new_travis_build),
    travis_attr(x),
    "builds"
  )
}

new_travis_build <- function(x) {
  stopifnot(x[["@type"]] == "build")
  new_travis_object(x, "build")
}

#' `travis_restart_build()` restarts a build with a given build ID.
#'
#' @param build_id `[integer(1)]`\cr
#'   The build ID, as obtained from `travis_get_builds()`. If not supplied,
#'   the latest build is used.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_build <- function(build_id = NULL,
                                 repo = github_repo(),
                                 endpoint = get_endpoint()) {

  if (is.null(build_id)) {
    build_id <- travis_get_builds()[[1]]$id
  }

  req <- travis(
    verb = "POST", path = sprintf("/build/%s/restart", build_id),
    endpoint = endpoint
  )

  stop_for_status(
    req$response,
    "restart last build. Is the build already running?"
  )

  cli::cli_alert_success(
    "Restarted build {.val {build_id}} for {.code {repo}} on Travis CI."
  )
  invisible(new_travis_pending_build(httr::content(req$response)))
}

#' `travis_cancel_build()` cancels a build with a given build ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_build <- function(build_id,
                                repo = github_repo(),
                                endpoint = get_endpoint()) {

  req <- travis(
    verb = "POST", path = sprintf("/build/%s/cancel", build_id),
    endpoint = endpoint
  )

  stop_for_status(
    req$response,
    "cancel the build. Is the build actually running?"
  )

  cli::cli_alert_success(
    "Cancelling build {.val {build_id}} for {.code {repo}} on Travis CI."
  )
  invisible(new_travis_pending_build(content(req$response)))
}

new_travis_pending_build <- function(x) {
  stopifnot(x[["@type"]] == "pending")
  x[["build"]] <- new_travis_build(x[["build"]])
  new_travis_object(x, "pending")
}

#' `travis_get_jobs()` calls the "jobs" API for the current repository.
#'
#' @export
#' @rdname travis_get_builds
travis_get_jobs <- function(build_id = NULL,
                            repo = github_repo(),
                            endpoint = get_endpoint()) {

  if (is.null(build_id)) {
    build_id <- travis_get_builds()[[1]]$id
  }

  req <- travis(path = sprintf("/build/%s/jobs", build_id), endpoint = endpoint)

  stop_for_status(
    req$response,
    sprintf("getting jobs for build '%s' from Travis CI", build_id)
  )

  new_travis_jobs(httr::content(req$response))
}

new_travis_jobs <- function(x) {
  stopifnot(x[["@type"]] == "jobs")
  new_travis_collection(
    lapply(x[["jobs"]], new_travis_job),
    travis_attr(x),
    "jobs"
  )
}

new_travis_job <- function(x) {
  stopifnot(x[["@type"]] == "job")
  new_travis_object(x, "job")
}

#' `travis_restart_job()` restarts a job with a given job ID.
#'
#' @param job_id `[integer(1)]`\cr
#'   The job ID, as obtained from `travis_get_builds()`.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_job <- function(job_id,
                               repo = github_repo(),
                               endpoint = get_endpoint()) {

  req <- travis(
    verb = "POST", path = sprintf("/job/%s/restart", job_id),
    endpoint = endpoint
  )

  stop_for_status(req$response, "restart job. Is the job already running?")

  cli::cli_alert_success(
    "Restarting job {.val {job_id}} for {.code {repo}} on Travis CI."
  )
  invisible(new_travis_pending_build(httr::content(req$response)))
}

#' `travis_cancel_job()` cancels a job with a given job ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_job <- function(job_id,
                              repo = github_repo(),
                              endpoint = get_endpoint()) {

  req <- travis(
    verb = "POST", path = sprintf("/job/%s/cancel", job_id),
    endpoint = endpoint
  )

  stop_for_status(
    req$response,
    "cancel the job. Is the job actually running?"
  )

  cli::cli_alert_success(
    "Cancelled build {.val {job_id}} for {.code {repo}} on Travis CI."
  )
  invisible(new_travis_pending_build(httr::content(req$response)))
}

#' `travis_debug_job()` restarts, in debug mode, a job with a given job ID. See
#' the
#' \href{https://docs.travis-ci.com/user/running-build-in-debug-mode/}{Travis CI
#' documentation} for more details.
#'
#' @param log_output Show the debugging output in the publicly visible log? When
#'   set to `TRUE`, refrain from issuing commands that might expose secrets.
#' @export
#' @rdname travis_get_builds
travis_debug_job <- function(job_id,
                             log_output = FALSE,
                             repo = github_repo(),
                             endpoint = get_endpoint()) {

  req <- travis(
    verb = "POST", path = sprintf("/job/%s/debug", job_id),
    query = list(quiet = !log_output), endpoint = endpoint
  )

  stop_for_status(
    req$response,
    "start the build in debug mode. Is the build already running?"
  )

  cli::cli_alert_success(
    "Restarted build {.val {job_id}} for {.code {repo}} in debugging mode
        on Travis CI.",
    wrap = TRUE
  )
  invisible(new_travis_pending_job(content(req$response)))
}

new_travis_pending_job <- function(x) {
  stopifnot(x[["@type"]] == "pending")
  x[["job"]] <- new_travis_job(x[["job"]])
  new_travis_object(x, "pending")
}

#' `travis_job_log()` returns a build job log.
#' @export
#' @rdname travis_get_builds
travis_get_log <- function(job_id = NULL,
                           repo = github_repo(),
                           endpoint = get_endpoint()) {

  if (is.null(job_id)) {
    job_id <- travis_get_jobs()[[1]]$id
  }

  req <- travis(path = sprintf("/job/%s/log.txt", job_id), endpoint = endpoint)

  stop_for_status(
    req, sprintf(
      "getting log from job '%s' for '%s' on Travis CI.",
      job_id, repo
    )
  )

  glue::as_glue(content(req, encoding = "UTF-8"))
}

#' `travis_delete_log()` deletes a build job log.
#' @export
#' @rdname travis_get_builds
travis_delete_log <- function(job_id,
                              repo = github_repo(),
                              endpoint = get_endpoint()) {

  req <- travis(
    verb = "DELETE", path = sprintf("/job/%s/log", job_id),
    endpoint = endpoint
  )

  stop_for_status(
    req$response, "delete logs. Do logs (still) exist for this job?"
  )

  cli::cli_alert_success(
    "Deleted log from job {.val {job_id}} for {.code {repo}} on Travis CI."
  )
  glue::as_glue(content(req$response, encoding = "UTF-8"))
}

new_travis_log <- function(x) {
  stopifnot(x[["@type"]] == "log")
  new_travis_object(x, "log")
}
