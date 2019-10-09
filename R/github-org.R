github_user <- function() {
  req = gh::gh("GET /user")
  return(req)
}

get_role_in_repo <- function(repo) {
  user <- github_user()$login

  req = gh::gh(sprintf("GET /repos/%s/collaborators/%s/permission", repo, user))

  message("get collaborator information on repo ", repo, " for user ", user)

  req$permission
}

check_admin_repo <- function(repo) {
  role_in_repo <- get_role_in_repo(repo)
  if (role_in_repo != "admin") {
    stopc("Must have role admin to add deploy key to repo ", repo, ", not ", role_in_repo)
  }
}

get_role_in_org <- function(org) {
  req = gh::gh(sprintf("GET /user/memberships/orgs/%s", org))

  # FIXME: Query 403 exit code to check if rtravis is enabled for the repo
  # if (httr::status_code(req) %in% 403) {
  #   org_perm_url <- paste0(
  #     "https://github.com/orgs/", org,
  #     "/policies/applications/551569"
  #   )
  #
  #   url_stop(
  #     "You may need to allow access for the rtravis GitHub app to your organization ", org,
  #     url = org_perm_url
  #   )
  # }

    message(sprintf(
      "query membership for organization ", org, ". ",
      "Check if you are a member of this organization"
    )
    )

 return(req$role)
}

check_write_org <- function(org) {
  role_in_org <- get_role_in_org(org)
  if (role_in_org != "admin") {
    stopc("Must have role admin to edit organization ", org, ", not ", role_in_org)
  }
}
