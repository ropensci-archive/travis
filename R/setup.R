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
                              repo = github_info(path = path)$name,
                              endpoint = get_endpoint()) {

  auth_github()
  auth_travis()

  # generate deploy key pair
  key <- openssl::rsa_keygen() # TOOD: num bits?

  # encrypt private key using tempkey and iv
  pub_key <- get_public_key(key)
  private_key <- encode_private_key(key)

  # Github deploy key ----------------------------------------------------------

  # query deploy key
  cli::cli_alert_info("Querying Github deploy keys from repo.")
  gh_keys <- gh::gh("/repos/:owner/:repo/keys",
    owner = github_info(path = path)$owner$login, repo = repo
  )

  if (!gh_keys[1] == "") {
    gh_keys_names <- gh_keys %>%
      purrr::map_chr(~ .x$title)

    # delete old keys with no endpoint spec
    # this helps to avoid having unused keys stored
    old_keys <- gh_keys_names %>%
      purrr::map_lgl(~ .x == "Deploy key for Travis CI" | .x == "travis+tic")
    if (any(old_keys == TRUE)) {
      purrr::walk(gh_keys[old_keys], ~
      gh::gh("DELETE /repos/:owner/:repo/keys/:key_id",
        owner = github_info(path = path)$owner$login,
        repo = repo,
        key_id = .x$id
      ))
      cli::cli_alert_info("Deleted unused old Travis deploy key(s) from
                          Github repo.", wrap = TRUE)
    }

    # check if key(s) exists
    if (any(gh_keys_names %in% sprintf(
      "Deploy key for Travis CI (%s)",
      endpoint
    ))) {
      return(cli::cli_alert("Deploy key for Travis CI ({.code {endpoint}})
      already present in {.file ~/.travis/config.yml}. No action required.",
        wrap = TRUE
      ))
    }
  }

  # add to GitHub first, because this can fail because of missing org
  # permissions
  title <- sprintf("Deploy key for Travis CI (%s)", endpoint)
  github_add_key(pubkey = pub_key, user = user, repo = repo, title = title)

  # env var 'id_rsa' on Travis -------------------------------------------------

  # check if id_rsa already exists on Travis
  idrsa <- travis_get_vars(
    repo = github_repo(path = path),
    endpoint = endpoint
  ) %>%
    purrr::map_lgl(~ .x$name == "id_rsa") %>%
    any()

  # delete existing ssh key
  if (isTRUE(idrsa)) {
    travis_delete_var(travis_get_var_id("id_rsa",
      repo = github_repo(path = path), quiet = TRUE
    ),
    repo = github_repo(path = path), endpoint = endpoint
    )
  }

  travis_set_var("id_rsa", private_key,
    public = FALSE, repo = github_repo(path = path),
    endpoint = endpoint
  )

  cli::cat_rule()
  cli::cli_alert_success(
    "Added a private deploy key to project {.code {repo}} on Travis CI as
      secure environment variable 'id_rsa'.",
    wrap = TRUE
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
