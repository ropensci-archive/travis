#' @export
github_create_pat <- function(path = ".", repo = github_repo(path), pat = NULL) {
  if (!is.null(pat)) {
    return(pat)
  }
  if (!interactive()) {
    stopc("`pat` must be set in non-interactive mode")
  }

  desc <- paste0("travis+tic for ", repo)
  clipr::write_clip(desc)
  url_message(
    "Create a personal access token, make sure that you are signed in as the correct user. ",
    "The suggested description '", desc, "' has been copied to the clipboard. ",
    "If you use this token only to avoid GitHub's rate limit, you can leave all scopes unchecked. ",
    "Then, copy the new token to the clipboard, it will be detected and applied automatically",
    url = "https://github.com/settings/tokens/new"
  )

  wait_for_clipboard_pat()
}

wait_for_clipboard_pat <- function() {
  message("Waiting for PAT to appear on the clipboard.")
  repeat {
    pat <- clipr::read_clip()
    if (is_pat(pat)) break
    Sys.sleep(0.1)
  }
  message("Detected PAT, clearing clipboard.")
  clipr::write_clip("")
  pat
}

is_pat <- function(pat) {
  grepl("^[0-9a-f]{40}$", pat)
}
