#' Setup deployment for Travis CI
#'
#' Creates a public-private key pair,
#' adds the public key to the GitHub repository via `github_add_key()`,
#' and stores the private key as an encrypted environment variable in Travis CI
#' via [travis_set_var()],
#' possibly in a different repository.
#' The \pkg{tic} companion package contains facilities for installing such a key
#' during a Travis CI build.
#'
#' @inheritParams travis_repo_info

#' @param path `[string]` \cr
#'   The path to the repository.
#' @param user `[string]` \cr
#'   Name of the Github user account.
#' @param repo `[string]`\cr
#'   The Travis CI repository to add the private key to, default: `repo`
#'   (the GitHub repo to which the public deploy key is added).
#' @template endpoint
#'
#' @export
use_travis_deploy <- function(path = usethis::proj_get(),
                              user = github_user()$login,
                              repo = github_info()$name,
                              endpoint = NULL) {

  if (is.null(endpoint)) {
    endpoint <- Sys.getenv("R_TRAVIS", unset = "ask")
  }

  # authenticate on github and travis and set up keys/vars
  auth_github()

  # generate deploy key pair
  key <- openssl::rsa_keygen() # TOOD: num bits?

  # encrypt private key using tempkey and iv
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  # Github deploy key ----------------------------------------------------------

  # check if key(s) exists
  cli::cli_text("Querying Github deploy keys from repo.")
  gh_keys <- gh::gh("/repos/:owner/:repo/keys", owner = github_info()$owner$login, repo = repo)
  gh_keys_names <- gh_keys %>%
    purrr::map_chr(~ .x$title)
  if (any(gh_keys %in% sprintf("Deploy key for Travis CI (%s)", endpoint))) {
    cli::cli_text("Deploy key for Travis CI {endpoint} already present. Not taking action.")
  }

  # delete old keys with no endpoint spec
  # this helps to avoid having unused keys stored
  old_keys <- gh_keys_names %>%
    purrr::map_lgl(~ .x == "Deploy key for Travis CI")
  if (any(old_keys == TRUE)) {
    purrr::walk(gh_keys[old_keys], ~ gh::gh("DELETE /repos/:owner/:repo/keys/:key_id",
                                            owner = github_info()$owner$login,
                                            repo = repo,
                                            key_id = .x$id))
    cli::cat_bullet(
      bullet = "tick", bullet_col = "green",
      sprintf(
        "Deleted unused old Travis deploy key(s) from Github repo.",
        repo
      )
    )
  }

  # add to GitHub first, because this can fail because of missing org permissions
  title <- sprintf("Deploy key for Travis CI (%s)", endpoint)
  github_add_key(pubkey = pub_key, user = user, repo = repo, title = title)

  # env var 'id_rsa' on Travis -------------------------------------------------

  # check if id_rsa already exists on Travis
  idrsa <- travis_get_vars() %>%
    purrr::map_lgl(~ .x$name == "id_rsa") %>%
    any()

  # delete existing ssh key
  if (isTRUE(idrsa)) {
    travis_delete_var(travis_get_var_id("id_rsa"))
  }

  travis_set_var("id_rsa", private_key,
    public = FALSE, repo = github_repo(),
    endpoint = endpoint
  )

  cli::cat_rule()
  cli::cat_bullet(
    bullet = "tick", bullet_col = "green",
    sprintf(
      "Added a private deploy key to project '%s' on Travis CI as secure environment variable 'id_rsa'.",
      repo
    )
  )
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
