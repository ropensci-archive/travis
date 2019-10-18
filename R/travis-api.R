travis <- function(endpoint = "") {
  paste0("https://api.travis-ci.org", endpoint)
}

TRAVIS_PATCH <- function(url, ..., token) {
  httr::PATCH(travis(url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.travis-ci.2+json"),
    if (!is.null(token)) httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_PATCH3 <- function(url, ..., token) {
  TRAVIS_PATCH(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}
