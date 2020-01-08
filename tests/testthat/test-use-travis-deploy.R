context("use_travis_deploy")

withr::with_dir(
  "travis-testthat",
  {
    test_that("use_travis_deploy works if the public key is missing", {
      skip_if(
        !Sys.getenv("TRAVIS_PULL_REQUEST") == "false",
        "Skipping test on PR to avoid race conditions."
      )
      private_key_exists <- travis_get_vars(
        # repo = repo,
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      # delete public key
      if (public_key_exists) {
        key_id <- which(gh_keys_names %>%
          purrr::map_lgl(~ .x == "Deploy key for Travis CI (.org)"))
        gh::gh("DELETE /repos/:owner/:repo/keys/:key_id",
          owner = "pat-s",
          repo = "travis-testthat",
          key_id = gh_keys[[key_id]]$id
        )
      }

      # run function
      use_travis_deploy()

      # check again if both are present
      private_key_exists <- travis_get_vars(
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      expect_true(public_key_exists & private_key_exists)
    })

    test_that("use_travis_deploy works if the private key is missing", {
      skip_if(
        !Sys.getenv("TRAVIS_PULL_REQUEST") == "false",
        "Skipping test on PR to avoid race conditions."
      )

      private_key_exists <- travis_get_vars(
        # repo = repo,
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      # delete private key
      if (private_key_exists) {
        # delete existing private key from Travis
        travis_delete_var(travis_get_var_id("TRAVIS_DEPLOY_KEY_ORG",
          quiet = TRUE
        ),
        endpoint = ".org"
        )
      }

      # run function
      use_travis_deploy()

      # check again if both are present
      private_key_exists <- travis_get_vars(
        # repo = repo,
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      expect_true(public_key_exists & private_key_exists)
    })

    test_that("use_travis_deploy works if both private and public key are missing", {
      private_key_exists <- travis_get_vars(
        # repo = repo,
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      # delete private key
      if (private_key_exists) {
        # delete existing private key from Travis
        travis_delete_var(travis_get_var_id("TRAVIS_DEPLOY_KEY_ORG",
          quiet = TRUE
        ),
        endpoint = ".org"
        )
      }
      # delete public key
      if (public_key_exists) {
        key_id <- which(gh_keys_names %>%
          purrr::map_lgl(~ .x == "Deploy key for Travis CI (.org)"))
        gh::gh("DELETE /repos/:owner/:repo/keys/:key_id",
          owner = "pat-s",
          repo = "travis-testthat",
          key_id = gh_keys[[key_id]]$id
        )
      }

      # run function
      use_travis_deploy()

      # check again if both are present
      private_key_exists <- travis_get_vars(
        # repo = repo,
        endpoint = ".org"
      ) %>%
        purrr::map_lgl(~ .x$name == "Deploy key for Travis CI (.org)") %>%
        any()

      # delete existing public key from github
      gh_keys <- gh::gh("/repos/:owner/:repo/keys",
        owner = "pat-s", repo = "travis-testthat"
      )
      gh_keys_names <- gh_keys %>%
        purrr::map_chr(~ .x$title)

      public_key_exists <- any(gh_keys_names %in%
        "Deploy key for Travis CI (.org)")

      expect_true(public_key_exists & private_key_exists)
    })

    test_that("use_travis_deploy returns early if both keys are present", {
      skip_if(
        !Sys.getenv("TRAVIS_PULL_REQUEST") == "false",
        "Skipping test on PR to avoid race conditions."
      )

      # run function
      foo <- use_travis_deploy()
      expect_match(foo, "Deploy keys already present.")
    })
  }
)
