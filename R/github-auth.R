#' Authenticate with GitHub
#'
#' Creates a `GITHUB_TOKEN` and asks you to store it in your `.Renviron` file.
#' @export
auth_github <- function() {
  # authenticate on github
  token <- usethis::github_token()
  if (token == "") {
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      cli::cat_bullet(
        bullet = "info", bullet_col = "yellow",
        "No Github token found. Opening a browser window to create one."
      )
    )
    usethis::browse_github_token()
    cli::cat_bullet(bullet = "cross", bullet_col = "red")
    stop("Circle: Please restart your R session after setting the token and try again.")
  }
}
