#' Setup deployment for Travis CI
#'
#' Creates a public-private key pair,
#' adds the public key to the GitHub repository via [github_add_key()],
#' and stores the private key as an encrypted environment variable in Travis CI
#' via [travis_set_var()],
#' possibly in a different repository.
#' The \pkg{tic} companion package contains facilities for installing such a key
#' during a Travis CI build.
#'
#' @inheritParams github_add_key
#' @inheritParams travis_repo_info
#' @param travis_repo `[string]`\cr
#'   The Travis CI repository to add the private key to, default: `repo`
#'   (the GitHub repo to which the public deploy key is added).
#'
#' @export
use_travis_deploy <- function(path = ".", info = github_info(path),
                              repo = github_repo(info = info), travis_repo = repo) {

  # authenticate on github and travis and set up keys/vars

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?

  # encrypt private key using tempkey and iv
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  # add to GitHub first, because this can fail because of missing org permissions
  title <- paste0("travis+tic", if (repo == travis_repo) "" else (paste0(" for ", repo)))
  github_add_key(pub_key, title = title, info = info)

  travis_set_var("id_rsa", private_key, public = FALSE, repo = travis_repo)

  cli::cat_bullet(bullet = "tick", bullet_col = "green",
    sprintf("Successfully added private deploy key to ",
    travis_repo, " as secure environment variable id_rsa to Travis CI."))

}

get_public_key <- function(key) {
  as.list(key)$pubkey
}

encode_private_key <- function(key) {
  conn <- textConnection(NULL, "w")
  openssl::write_pem(key, conn, password = NULL)
  private_key <- textConnectionValue(conn)
  close(conn)

  private_key <- paste(private_key, collapse = "\n")

  openssl::base64_encode(charToRaw(private_key))
}
