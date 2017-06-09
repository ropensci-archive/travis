#' Use travis deploy
#'
#' @param pkg Package description, must be path to root of source package.
#'
#' @export
use_travis_deploy <- function(pkg = ".") {

  pkg <- normalizePath(pkg, "/")

  # authenticate on github and travis and set up keys/vars
  setup_keys(pkg)

  url_message("Next steps:\n",
              "* If needed, enable Travis CI with travis::travis_enable()\n",
              "* Configure Travis to use tic as described in the tic README",
              url = "https://github.com/ropenscilabs/tic#example-travis-configuration")

}

setup_keys <- function(path) {

  # generate deploy key pair
  key <- openssl::rsa_keygen()  # TOOD: num bits?

  # encrypt private key using tempkey and iv
  repo <- github_repo(path)

  # add to GitHub first, because this can fail because of missing org permissions
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  add_key <- github_add_key(pub_key, path)

  message(
    "Successfully added public deploy key '", add_key$title, "' to GitHub for ", repo, ". ",
    "You should receive a confirmation e-mail from GitHub. ",
    "Delete the key in the repository's settings when you no longer need it."
  )

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
