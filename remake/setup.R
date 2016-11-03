create_id <- function(value = NULL) {
  if (is.null(value)) {
    value <- gsub("_", "-", ids::adjective_animal())
  }
  value
}

create_github_user <- function(user) {
  clipr::write_clip(user)
  menu(c("OK"), title = paste0("Please create GitHub user ", user))
}

user1 <- create_id("quasiprogressive-bustard")
user2 <- create_id("plucky-bear")

create_github_user(user1)
create_github_user(user2)

repo_base <- tempfile()
dir.create(repo_base)

repo1_path <- file.path(repo_base, "repo1")
dir.create(repo1_path)

repo1 <- git2r::init(repo1_path)
writeLines(character(), file.path(repo1_path, ".gitignore"))
