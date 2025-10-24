# Package environment -----------------------------------------------------------------

timefully_env <- new.env()


# Tic-toc -----------------------------------------------------------------

#' Time difference start function
#'
#' Use this function together with `toc()` to control time spent by functions
#'
#' @return numeric
#' @export
#'
tic <- function() {
  assign("tic", Sys.time(), envir = timefully_env)
}

#' Time difference end function
#'
#' Use this function together with `tic()` to control time spent by functions
#'
#' @param units character, one of "auto", "secs", "mins", "hours", "days" and "weeks"
#' @param digits integer, number of decimals
#'
#' @return numeric
#' @export
#'
toc <- function(units = "secs", digits = 2) {
  tic <- get("tic", envir = timefully_env)
  time_diff <- round(difftime(Sys.time(), tic, units = units)[[1]], digits)
  message(paste("---- Done in", time_diff, units))
  invisible(time_diff)
}
