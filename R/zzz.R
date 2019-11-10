"_PACKAGE"
.onLoad <- function(libname, pkgname) {

  if (Sys.getenv("R_TRAVIS") != "") {
    cli::cli_text("{.pkg travis}: Using Travis endpoint '{Sys.getenv('R_TRAVIS')}' set via env var {.code R_TRAVIS}.")
  } else {
    cli::cli_text("Env var 'R_TRAVIS' not set. Defaulting to '.org' endpoint.")
  }
}
