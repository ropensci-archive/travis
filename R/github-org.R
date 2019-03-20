github_user <- function(gh_token) {
  req <- GITHUB_GET(paste0("/user"), token = gh_token)

  httr::stop_for_status(
    req,
    "get information on authenticated user"
  )

  httr::content(req)
}

get_role_in_repo <- function(repo, gh_token) {
  user <- github_user(gh_token)$login

  req <- GITHUB_GET(paste0("/repos/", repo, "/collaborators/", user, "/permission"), token = gh_token)

  httr::stop_for_status(
    req,
    paste0("get collaborator information on repo ", repo, " for user ", user)
  )

  response <- httr::content(req)
  response$permission
}

check_admin_repo <- function(repo, gh_token) {
  role_in_repo <- get_role_in_repo(repo, gh_token)
  if (role_in_repo != "admin") {
    stopc("Must have role admin to add deploy key to repo ", repo, ", not ", role_in_repo)
  }
}

get_role_in_org <- function(org, gh_token) {
  req <- GITHUB_GET(paste0("/user/memberships/orgs/", org), token = gh_token)
  if (httr::status_code(req) %in% 403) {
    org_perm_url <- paste0(
      "https://github.com/orgs/", org,
      "/policies/applications/551569")

    url_stop(
      "You may need to allow access for the rtravis GitHub app to your organization ", org,
      url = org_perm_url
    )
  }

  httr::stop_for_status(
    req,
    paste0(
      "query membership for organization ", org, ". ",
      "Check if you are a member of this organization"
    )
  )

  membership <- httr::content(req)
  role_in_org <- membership$role

  role_in_org
}

check_write_org <- function(org, gh_token) {
  role_in_org <- get_role_in_org(org, gh_token)
  if (role_in_org != "admin") {
    stopc("Must have role admin to edit organization ", org, ", not ", role_in_org)
  }
}
