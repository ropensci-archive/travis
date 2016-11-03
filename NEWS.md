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
