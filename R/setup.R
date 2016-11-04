#' Use travis deploy
#'
#' @param pkg Package description, can be path or package name. See
#'   \code{\link{as.package}} for more information.
#'
#' @export
use_travis_deploy <- function(pkg = ".") {

  pkg <- devtools::as.package(pkg)

  # authenticate on github and travis and set up keys/vars
  setup_keys(pkg$path)

}

setup_keys <- function(path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?

  # encrypt private key using tempkey and iv
  repo <- github_repo(path)

  private_key <- encode_private_key(key)
  travis_set_var("id_rsa", private_key,
                 public = FALSE, repo = repo)

  pub_key <- as.list(key)$pubkey
  github_add_key(pub_key, path)
}

encode_private_key <- function(key) {
  conn <- textConnection(NULL, "w")
  openssl::write_pem(key, conn, password = NULL)
  private_key <- textConnectionValue(conn)
  close(conn)

  private_key <- paste(private_key, collapse = "\n")

  openssl::base64_encode(charToRaw(private_key))
}
