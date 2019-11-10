travis_attr <- function(x) {
  is_attr <- grepl("^@", names(x))
  x[is_attr]
}

travis_no_attr <- function(x) {
  is_attr <- grepl("^@", names(x))
  x[!is_attr]
}

new_travis <- function(x, attr, subclass) {
  attr[["names"]] <- names(x)
  attributes(x) <- attr
  suppressWarnings(structure(x, class = c(paste0("travis_", subclass), "travis")))
}

new_travis_object <- function(x, subclass) {
  new_travis(travis_no_attr(x), travis_attr(x), subclass)
}

new_travis_collection <- function(x, attr, subclass) {
  new_travis(x, attr, c(subclass, "collection"))
}

`[.travis_collection` <- function(x, i) {
  reconstruct(NextMethod(), x)
}

reconstruct <- function(new, orig) {
  mostattributes(new) <- attributes(orig)
  new
}

#' @export
format.travis_collection <- function(x, ...) {
  paste0(
    "A collection of ", length(x), " Travis CI ", attr(x, "@type"), ":\n",
    bullets(vapply(shorten(x), format, short = TRUE, character(1)))
  )
}

bullets <- function(x) {
  if (length(x) == 0) {
    return(character())
  }
  paste0("- ", x, collapse = "\n")
}

shorten <- function(x) {
  N_MAX <- 6
  if (length(x) > N_MAX) {
    c(x[seq_len(N_MAX - 1)], "...")
  } else {
    x
  }
}

key_value <- function(x) {
  paste0(
    ifelse(names(x) == "", "", paste0(names(x), ": ")),
    x
  )
}

#' @export
format.travis <- function(x, ..., short = FALSE) {
  kv <- key_value(shorten(x))
  if (short) {
    paste0(kv, collapse = ", ")
  } else {
    bullets(kv)
  }
}

#' @export
print.travis <- function(x, ...) {
  cat(format(x))
  invisible(x)
}
