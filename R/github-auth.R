#' Authenticate with GitHub
#'
#' Creates a `GITHUB_TOKEN` and asks you to store it in your `.Renviron` file.
#' @export
#' @keywords internal
auth_github <- function() {
  # authenticate on github
  token <- usethis::github_token()
  if (token == "") {
    cli::cat_bullet(
      bullet = "cross", bullet_col = "red",
      cli::cli_text("{.pkg travis}: Please call {.code usethis::browse_github_token()}
                    and follow the instructions. Then restart the session and try again.")
    )
  }
}
