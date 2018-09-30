check_write_org <- function(org, gh_token) {
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

  if (role_in_org != "admin") {
    stopc("Must have role admin to edit organization ", org, ", not ", role_in_org)
  }
}
