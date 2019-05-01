travis <- function(endpoint = "") {
  paste0("https://api.travis-ci.org", endpoint)
}

TRAVIS_GET <- function(url, ..., accept = NULL, token) {
  if (is.null(accept)) {
    accept <- httr::accept("application/vnd.travis-ci.2+json")
  }

  httr::GET(travis(url),
    httr::user_agent("ropenscilabs/travis"),
    accept,
    httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_GET3 <- function(url, ..., token) {
  TRAVIS_GET(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

TRAVIS_GET_TEXT3 <- function(url, ..., token) {
  TRAVIS_GET3(url, ..., accept = httr::accept("text/plain"), token = token)
}

TRAVIS_POST <- function(url, ..., encode = "json", token) {
  httr::POST(travis(url),
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.travis-ci.2+json"),
    if (!is.null(token)) httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_POST3 <- function(url, ..., token) {
  TRAVIS_POST(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
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

TRAVIS_DELETE <- function(url, ..., token) {
  httr::DELETE(travis(url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.travis-ci.2+json"),
    httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_DELETE3 <- function(url, ..., token) {
  TRAVIS_DELETE(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}
