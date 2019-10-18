#' Travis CI builds
#'
#' @description
#' Functions around completed or pending Travis CI builds and jobs.
#'
#' `travis_get_builds()` calls the "builds" API for the current repository.
#'
#' @inheritParams travis_set_pat
#'
#' @export
travis_get_builds <- function(repo = github_repo()) {

  req = travisHTTP(path = sprintf("/repo/%s/builds", encode_slug(repo)))

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
#'   The build ID, as obtained from `travis_get_builds()`.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_build <- function(build_id, repo = github_repo(),
                                 quiet = FALSE) {
  req = travisHTTP(verb = "POST", path = sprintf("/build/%s/restart", build_id))

  if (status_code(req$response) == 202) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Restarted build '%s' for '%s' on Travis CI.", build_id, repo
      )
    )
    invisible(new_travis_pending_build(httr::content(req$response)))
  }
}

#' `travis_restart_last_build()` restarts the *last* build.
#'
#' @export
#' @rdname travis_get_builds
travis_restart_last_build <- function(repo = github_repo(),
                                      quiet = FALSE) {
  builds <- travis_get_builds(repo = repo)
  last_build_id <- builds[[1]]$id
  travis_restart_build(last_build_id,
    repo = repo,
    quiet = quiet
  )
}

#' `travis_cancel_build()` cancels a build with a given build ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_build <- function(build_id, repo = github_repo(),
                                quiet = FALSE) {
  req = travisHTTP(verb = "POST", path = sprintf("/build/%s/cancel", build_id))

  if (status_code(req$response) == 202) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Cancelling build '%s' for '%s' on Travis CI.", build_id, repo
      )
    )
    invisible(new_travis_pending_build(httr::content(req$response)))
  }
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
travis_get_jobs <- function(build_id, repo = github_repo()) {
  req = travisHTTP(path = sprintf("/build/%s/jobs", build_id))

  httr::stop_for_status(
    req$response,
    sprintf("get jobs for build %s from Travis CI", build_id)
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
travis_restart_job <- function(job_id, repo = github_repo(),
                               quiet = FALSE) {

  req = travisHTTP(verb = "POST", path = sprintf("/job/%s/restart", job_id))

  if (status_code(req$response) == 202) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Restarting job '%s' for '%s' on Travis CI.", job_id, repo
      )
    )
    invisible(new_travis_pending_build(httr::content(req$response)))
  }
}

#' `travis_cancel_job()` cancels a job with a given job ID.
#'
#' @export
#' @rdname travis_get_builds
travis_cancel_job <- function(job_id, repo = github_repo(),
                              quiet = FALSE) {

  req = travisHTTP(verb = "POST", path = sprintf("/job/%s/cancel", job_id))

  if (status_code(req$response) == 202) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Cancelling build '%s' for '%s' on Travis CI.", job_id, repo
      )
    )
    invisible(new_travis_pending_build(httr::content(req$response)))
  }
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
                             quiet = FALSE) {

  req = travisHTTP(verb = "POST", path = sprintf("/job/%s/debug", job_id),
                   query = list(quiet = !log_output))

  if (status_code(req$response) == 202) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Restarted build '%s' for '%s' in debugging mode on Travis CI.", job_id, repo
      )
    )
    invisible(new_travis_pending_job(content(req$response)))
  }
}

new_travis_pending_job <- function(x) {
  stopifnot(x[["@type"]] == "pending")
  x[["job"]] <- new_travis_job(x[["job"]])
  new_travis_object(x, "pending")
}

#' `travis_job_log()` returns a build job log.
#' @export
#' @rdname travis_get_builds
travis_get_log <- function(job_id,
                           repo = github_repo(),
                           quiet = FALSE) {

  req = travisHTTP(path = sprintf("/job/%s/log.txt", job_id))

  if (status_code(req) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Getting log from job '%s' for '%s' on Travis CI.", job_id, repo
      )
    )
    glue::as_glue(content(req, encoding = "UTF-8"))
  }
}

#' `travis_delete_log()` deletes a build job log.
#' @export
#' @rdname travis_get_builds
travis_delete_log <- function(job_id,
                              repo = github_repo(),
                              quiet = FALSE) {
  req = travisHTTP(verb = "DELETE", path = sprintf("/job/%s/log", job_id))

  if (status_code(req$response) == 200) {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Deleting log from job '%s' for '%s' on Travis CI.", job_id, repo
      )
    )
    glue::as_glue(content(req$response, encoding = "UTF-8"))
  }
}

new_travis_log <- function(x) {
  stopifnot(x[["@type"]] == "log")
  new_travis_object(x, "log")
}
