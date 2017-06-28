#' Setup deployment for Travis CI
#'
#' Creates a public-private key pair,
#' adds the public key to the GitHub repository via [github_add_key()],
#' and stores the private key as an encrypted environment variable in Travis CI
#' via [travis_set_var()].
#' The \pkg{tic} companion package contains facilities for installing such a key
#' during a Travis CI build.
#'
#' @inheritParams github_add_key
#'
#' @export
use_travis_deploy <- function(path = ".") {

  # authenticate on github and travis and set up keys/vars

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?

  info <- github_info(path)
  repo <- github_repo(info = info)

  # encrypt private key using tempkey and iv
  # add to GitHub first, because this can fail because of missing org permissions
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  add_key <- github_add_key(pub_key, info = info, repo = repo)

  travis_set_var("id_rsa", private_key, public = FALSE, repo = repo)

  message("Successfully added private deploy key to Travis CI for ", repo, ".")

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
