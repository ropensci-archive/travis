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
  pub_key <- as.list(key)$pubkey

  private_key <- character()
  conn <- textConnection("private_key", "w")

  openssl::write_pem(key, conn, password = NULL)
  close(conn)

  # encrypt private key using tempkey and iv
  repo <- github_repo(path)

  travis_set_var("id_rsa", paste(private_key, collapse = "\n"),
                 public = FALSE, repo = repo)

  github_add_key(pub_key, path)
}
