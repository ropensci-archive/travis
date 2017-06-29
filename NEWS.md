## travis 0.2-9 (2017-06-29)

- Update `tic.R` templates.


## travis 0.2-8 (2017-06-29)

- Blogdown projects with a `config.toml` file are detected.
- `use_tic()` prints message when adding files from a template.
- `use_tic()` creates an `appveyor.yml` only for package projects.
- New `info`, `repo` and `travis_repo` arguments to `use_travis_deploy()` for creating keys for other repos, e.g., to auto-deploy a drat (#61).
- Remove `repos` argument from `github_add_key()`, which now returns the "httr" request object.
- New `use_tic()` (#60).


## travis 0.2-7 (2017-06-13)

- New `new_github()` and `use_github()` (#59).


## travis 0.2-6 (2017-06-10)

- Document all functions, `R CMD check` passes without warnings or notes (#50).
- Disabled caching of GitHub authentication, because functions from this package usually needs to be run only once per development package.
- New `travis_get_var_id()`.
- `travis_delete_var()` gains `name` argument, `id` is computed from `name` (#58).
- All commands that are primarily called for side effects print a success message, unless the `quiet` argument is set to `FALSE` (#46).
- Deploy keys now have the title "travis+tic" by default, existing keys by the same title are deleted and created anew (#33).
- New `travis_set_pat()`, by default directs the user to the page where new tokens are created and waits for a token to appear on the clipboard (#21).


## travis 0.2-5 (2017-06-10)

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


## travis 0.2-4 (2016-11-06)

- Documentation improvements.


## travis 0.2-3 (2016-11-04)

- Code cleanup.
- `travis_encrypt()` gains repo argument.
- `use_travis_deploy()` creates an encrypted environment variable that contains the private key; the public key is pushed to GitHub and not stored anywhere (#45). The deploy key is encoded in the base64 encoding, because Travis doesn't handle environment variables with newlines very well.



## travis 0.2-2 (2016-11-04)

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


## travis 0.2-1 (2016-11-03)

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


## travis 0.2 (2016-09-11)

Initial release.

- Access to Travis API via `travis_...()` functions.
- Interaction with GitHub API via `github_...()` functions.
- Function `use_travis_deploy()` for setup.
