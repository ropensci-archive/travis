test_that("github helper functions work", {
  unlink(paste0(tempdir(), "/travis"), recursive = TRUE)
  usethis::create_from_github("ropenscilabs/travis",
    destdir = tempdir(check = TRUE), open = FALSE
  )

  withr::with_dir(paste0(tempdir(), "/travis"), {

    # github_info() ------------------------------------------------------------
    info <- github_info()
    expect_s3_class(info, "gh_response")
    expect_equal(info$name, "travis")
    expect_equal(info$owner$login, "ropenscilabs")

    #   # get_repo_slug ------------------------------------------------------------
    repo_slug <- get_repo_slug()
    expect_equal(repo_slug, "ropenscilabs/travis")

    #   # get_repo -----------------------------------------------------------------
    repo <- get_repo()
    expect_equal(repo, "travis")

    #   # get_user -----------------------------------------------------------------
    user <- get_user()
    expect_type(user, "character")

    #   # get_owner ----------------------------------------------------------------
    owner <- get_owner()
    expect_equal(owner, "ropenscilabs")

    #   # github_repo --------------------------------------------------------------
    repo_slug <- github_repo()
    expect_equal(repo_slug, "ropenscilabs/travis")

    #   # check_admin_repo ---------------------------------------------------------
    expect_silent(check_admin_repo(owner, user, repo))

    #   # get_role_in_repo ---------------------------------------------------------
    role <- get_role_in_repo(owner, user, repo)
    expect_type(role, "character")
  })
})

test_that("SSH key creation works", {
  key <- openssl::rsa_keygen()

  pubkey <- get_public_key(key)
  expect_s3_class(pubkey, "pubkey")

  private_key <- create_key_data(key$pubkey, "test")
  expect_type(private_key, "list")
  expect_length(private_key, 3)

  encoded <- encode_private_key(key$pubkey)
  expect_type(encoded, "character")
})
