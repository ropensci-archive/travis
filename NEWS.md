# travis 0.3.0.9004

- bugfix: Pass arg `remote` to all printing instances. Previously using a different remote than 'origin' errored.
- Exit early if GitHub PAT is not set instead of just throwing a warning (#144)
- `github_add_key()` gains argument `check_role` to optionally turn off checking for permissions when adding public keys to repos.


# travis 0.3.0.9003

- `use_travis_deploy()` now operates on the repo slug via the `repo` argument
- `use_travis_deploy()`: Removed argument `user`. This information is now queried internally.
- `use_travis_deploy()` now queries the correct information when operating on a custom git remote via the `remote` argument
- `use_travis_deploy()`: Add option to name private and public keys (#129)
- added some Github helper functions (`get_*()`) to scrape GH info in a more descriptive way
- remove endpoint suffix from private_key_name, only use `TRAVIS_DEPLOY_KEY`
- Optimize`use_travis_deploy()`
- export `github_info()`, add `uses_github()`


# travis 0.3.0.9002

- Internal changes only.


# travis 0.3.0.9001

- Support Git remotes other than "origin" (#88).
- Allow `www.` prefix in remote URLs (#114).
- Remove `travis_restart_last_build()`, travis_get_jobs(): use last build if non supplied


# travis 0.3.0

- refactor authentication: Now a Travis API token is used for all requests. On the first use, the user is asked to create one. The token is either stored on disk or as an env var and used in future requests. 
- remove `token` argument from all functions 
- replace `browse_travis()` by `usethis::browse_travis()` 
- remove ability to update env vars ("PATCH"). Please remove (`travis_delete_var()`) and create a new one (`travis_set_var()`). 
- `travis_lint()` now also accepts a URL as input for arg `file`. 

# travis 0.2.11.9001

- Using `usethis::proj_get()` as default path for all functions (#103, @maelle).
- Use {cli} for messages (#103).
- Permission checks before creating deploy key are more accurate, taking into account situations where the current user is not admin of the organization but admin of the repository (#95).
- Clarify error message after failing to find repo after synchronizing with Travis (#99).
- Pass `repo` argument from `travis_set_pat()` to `travis_set_var()` (#98, @maelle).
- Add "Getting Started" vignette (#92, @pat-s).
- Tweak README (#93, @pat-s).
- Tweak tic.R templates (#94).
- Travis template avoids reinstalling remotes (and curl) if the packages are installed already (#94, @pat-s).
- Adapt templates to reflect that bookdown and blogdown are on CRAN now.
- Avoid deployment for tags.
- Document how to avoid recording secret value in history (#80).
- New `travis_lint()` (#74).
- Update rtravis application id in error message (#86, @fmichonneau).
- Add BugReports and URL fields (#81).
- Update doc of `travis-is-enabled()` (#76, @pat-s).
- Fix transformation of remote URL to only remove ".git" if it appears at the end (#75, @fmichonneau).


# travis 0.2.11.9000

- New `travis_get_jobs()`.
- Remove distinction between `repo` and `repo_id`, don't need `repo_id` argument anymore.
- Using Travis CI API v3 (#63).
- Remove `travis_accounts()`.
- New `travis_has_repo()`.
- Rename `uses_travis()` to `travis_is_enabled()`.
- Rename `travis_repositories()` to `travis_repos()`.
- New `format()` and `print()` methods for collections and objects, new S3 classes `"travis"`, `"travis_collection"` and `"travis_xxx"` (one for each collection and item type).
- Merge functionality from cloudyr/travisci (#65, @leeper).
- `github_info()` now always passes a token, and supports the `gh_token` argument.
- Tests for internal formatting functions.
- New functions `travis_get_builds()`, `travis_restart_build()`, `travis_cancel_build()`, `travis_restart_job()`, `travis_cancel_job()`, and `travis_debug_job()`. The latter is the only way to restart a job in debug mode, after this has been enabled by Travis CI: https://docs.travis-ci.com/user/running-build-in-debug-mode/.


# travis 0.2-11 (2017-07-24)

- Tests for internal formatting functions.
- New functions `travis_get_builds()`, `travis_restart_build()`, `travis_cancel_build()`, `travis_restart_job()`, `travis_cancel_job()`, and `travis_debug_job()`. The latter is the only way to restart a job in debug mode, after this has been enabled by Travis CI: https://docs.travis-ci.com/user/running-build-in-debug-mode/.


# travis 0.2-10 (2017-06-29)

- Patch AppVeyor template.


# travis 0.2-9 (2017-06-29)

- Update `tic.R` templates.


# travis 0.2-8 (2017-06-29)

- Blogdown projects with a `config.toml` file are detected.
- `use_tic()` prints message when adding files from a template.
- `use_tic()` creates an `appveyor.yml` only for package projects.
- New `info`, `repo` and `travis_repo` arguments to `use_travis_deploy()` for creating keys for other repos, e.g., to auto-deploy a drat (#61).
- Remove `repos` argument from `github_add_key()`, which now returns the "httr" request object.
- New `use_tic()` (#60).


# travis 0.2-7 (2017-06-13)

- New `new_github()` and `use_github()` (#59).


# travis 0.2-6 (2017-06-10)

- Document all functions, `R CMD check` passes without warnings or notes (#50).
- Disabled caching of GitHub authentication, because functions from this package usually needs to be run only once per development package.
- New `travis_get_var_id()`.
- `travis_delete_var()` gains `name` argument, `id` is computed from `name` (#58).
- All commands that are primarily called for side effects print a success message, unless the `quiet` argument is set to `FALSE` (#46).
- Deploy keys now have the title "travis+tic" by default, existing keys by the same title are deleted and created anew (#33).
- New `travis_set_pat()`, by default directs the user to the page where new tokens are created and waits for a token to appear on the clipboard (#21).


# travis 0.2-5 (2017-06-10)

- The new `uses_github()` and `uses_travis()` functions allow
  determining if GitHub or Travis is enabled for a repository. Note that
  `uses_travis()` needs a repo slug, which is available from an
  attribute of the value returned by `uses_github()` (#47).
- Only interactive sessions will open a browser window to improve setup
  experience. The `travis_browse()` function still opens a browser
  window unconditionally (#52).
- All API functions that provide a side effect return the result of the
  request invisibly (#57).
- For organization repos, adding deploy keys or creating new repos checks if the user and the app have permission to perform this action, and gives more accurate error messages (#51).
- Environment variables on Travis are overwritten if they exist (#30).
- Remove devtools dependency (#49).


# travis 0.2-4 (2016-11-06)

- Documentation improvements.


# travis 0.2-3 (2016-11-04)

- Code cleanup.
- `travis_encrypt()` gains repo argument.
- `use_travis_deploy()` creates an encrypted environment variable that contains the private key; the public key is pushed to GitHub and not stored anywhere (#45). The deploy key is encoded in the base64 encoding, because Travis doesn't handle environment variables with newlines very well.



# travis 0.2-2 (2016-11-04)

- Semi-automated test using `remake`. Run `remake::make(remake::list_targets())` in the package directory, installation is currently required. Tests creating a repository for a new user and installing a SSH key there, the same with a new organization owned by this user.
- If the user needs to manually configure an online service, a browser windows opens in addition to a textual message.
- Support remote URLs with embedded passwords (HTTP/S only).
- Economical request for GitHub scopes, in particular `write:org`.
- Travis authentication can be bound to a repository, in this case a synchronization is attempted if the repository is not found. A token is only returned if the user is permitted to edit the Travis configuration.
- Export `auth_github()` and `auth_travis()`.
- New `github_create_repo()`.
- New `info` arg to `github_repo().
- New `gh_token` arg to `github_add_key()`.
- `setup_keys()` works with paths


# travis 0.2-1 (2016-11-03)

- Fix Travis authentication by using a fresh GitHub token for each authentication (#35, #36).
- Cache Travis and GitHub token during the current R session using `memoise` (#29).
- Support URLs of the form `git://github.com`, with tests (#19).
- All functions have sensible default values.
- New `travis_sync(block = TRUE)`.
- New `travis_enable(active = TRUE)`, will sync by default if repo not found.
- New `travis_browse()`.
- New `travis_delete_var()`.
- New `travis_repo_id()`.
- `travis_repo_info()` now only has a repo argument.
- Don't update `.travis.yml` in `use_travis_deploy()` (#41).
- Relax R dependency to >= 3.2.0.
- More precise commit message when initializing repo.
- Add basic package documentation (#20).


# travis 0.2 (2016-09-11)

Initial release.

- Access to Travis API via `travis_...()` functions.
- Interaction with GitHub API via `github_...()` functions.
- Function `use_travis_deploy()` for setup.
