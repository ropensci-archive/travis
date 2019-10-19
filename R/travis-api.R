TRAVIS_GET <- function(url, ..., accept = NULL, token = auth_travis()) {
  if (is.null(accept)) {
    accept <- httr::accept("application/vnd.travis-ci.2+json")
  }

  httr::GET(sprintf("%s%s", travis(".org"), url),
    httr::user_agent("ropenscilabs/travis"),
    accept,
    httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_GET3 <- function(url, ..., token = auth_travis()) {
  TRAVIS_GET(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

TRAVIS_GET_TEXT3 <- function(url, ..., token = auth_travis()) {
  TRAVIS_GET3(url, ..., accept = httr::accept("text/plain"), token = token)
}

TRAVIS_POST <- function(url, ..., encode = "json", token = auth_travis()) {
  httr::POST(sprintf("%s%s", travis(".org"), url),
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.travis-ci.2+json"),
    if (!is.null(token)) httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_POST3 <- function(url, ..., token = auth_travis()) {
  TRAVIS_POST(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

TRAVIS_PATCH <- function(url, ..., token = auth_travis()) {
  httr::PATCH(sprintf("%s%s", travis(".org"), url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.travis-ci.2+json"),
    if (!is.null(token)) httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_PATCH3 <- function(url, ..., token = auth_travis()) {
  TRAVIS_PATCH(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

TRAVIS_DELETE <- function(url, ..., token  = auth_travis()) {
  httr::DELETE(sprintf("%s%s", travis(".org"), url),
    httr::user_agent("ropenscilabs/travis"),
    httr::add_headers(Authorization = paste("token", token)),
    ...
  )
}

TRAVIS_DELETE3 <- function(url, ..., token = auth_travis()) {
  TRAVIS_DELETE(url, ..., httr::add_headers("Travis-API-Version" = 3), token = token)
}

encode_slug <- function(repo) {
  utils::URLencode(as.character(repo), reserved = TRUE)
}
