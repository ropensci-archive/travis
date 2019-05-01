github <- function(endpoint = "") {
  paste0("https://api.github.com", endpoint)
}

GITHUB_GET <- function(url, ..., token) {
  httr::GET(github(url),
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.github.v3+json"),
    httr::config(token = token),
    ...
  )
}

GITHUB_PUT <- function(url, ..., token) {
  httr::PUT(github(url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.github.v3+json"),
    httr::config(token = token),
    ...
  )
}

GITHUB_POST <- function(url, ..., token) {
  httr::POST(github(url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.github.v3+json"),
    httr::config(token = token),
    ...
  )
}

GITHUB_DELETE <- function(url, ..., token) {
  httr::DELETE(github(url),
    encode = "json",
    httr::user_agent("ropenscilabs/travis"),
    httr::accept("application/vnd.github.v3+json"),
    httr::config(token = token),
    ...
  )
}
