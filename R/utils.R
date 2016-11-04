url_message <- function(..., url) {
  message(format_url_msg(..., url = url))
  utils::browseURL(url)
}

url_stop <- function(..., url) {
  utils::browseURL(url)
  stopc(format_url_msg(..., url = url))
}

format_url_msg <- function(..., url) {
  paste0(..., ". Please visit\n  ", url, "\nA browser windows will be opened.")
}

stopc <- function(...) {
  stop(..., call. = FALSE, domain = NA)
}
