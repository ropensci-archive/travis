travis <- function(endpoint = "") {
  paste0("https://api.travis-ci.org", endpoint)
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}
