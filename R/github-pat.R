#' Create a GitHub PAT
#'
#' Prompts the user to create a personal access token for the GitHub API
#' related to the current repository, e.g., to work around rate limitations.
#' First, the user is directed to the website where a PAT can be created.
#' A suggestion for the PAT's title is copied to the clipboard.
#' Then, the function waits until the user copies a string that resembles a PAT
#' (i.e., 40 lowercase hexadecimal digits) to the clipboard.
#' The clipboard is cleared right after obtaining the PAT.
#'
#' The relatively cumbersome workflow is due to the fact that
#' creating a PAT requires basic authentication (username + password).
#'
#' @inheritParams github_add_key
#' @inheritParams travis_repo_info
#'
#' @family GitHub functions
#'
#' @export
github_create_pat <- function(path = usethis::proj_get(), repo = github_repo(path)) {
  if (!interactive()) {
    stopc("Cannot use `github_create_pat()` in non-interactive mode")
  }

  desc <- paste0("travis+tic for ", repo)
  clipr::write_clip(desc)

  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Creating a personal access token (PAT)."
  )
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    paste0(" The suggested description '%s' has been copied to the clipboard.", desc)
  )
  cli::cat_bullet(
    bullet = "info", bullet_col = "yellow",
    " If you use this token only to avoid GitHub's rate limit, you can leave all scopes unchecked."
  )
  cli::cat_bullet(
    bullet = "info", bullet_col = "yellow",
    " Then, copy the new token to the clipboard, it will be detected and applied automatically."
  )

  open_browser_window("https://github.com/settings/tokens/new")
  wait_for_clipboard_pat()
}

wait_for_clipboard_pat <- function() {
  cli::cat_bullet(
    bullet = "info", bullet_col = "yellow",
    " If you use this token only to avoid GitHub's rate limit, you can leave all scopes unchecked."
  )

  cli::cat_bullet(
    bullet = "info", bullet_col = "yellow",
    " Waiting for PAT to appear on the clipboard."
  )
  repeat {
    pat <- clipr::read_clip()
    if (is_pat(pat)) break
    Sys.sleep(0.1)
  }
  cli::cat_bullet(
    bullet = "pointer", bullet_col = "yellow",
    " Detected PAT, clearing clipboard."
  )
  tryCatch(
    clipr::write_clip(""),
    error = function(e) {
      warningc("Error clearing clipboard: ", conditionMessage(e))
    }
  )
  pat
}

is_pat <- function(pat) {
  grepl("^[0-9a-f]{40}$", pat)
}
