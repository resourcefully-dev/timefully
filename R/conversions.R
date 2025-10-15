#' Convert numeric time value to a datetime period (hour-based)
#'
#' @param time_num Numeric time value (hour-based)
#'
#' @importFrom lubridate hours minutes
#' @export
#'
convert_time_num_to_period <- function(time_num) {
  h <- time_num %/% 1
  m <- (time_num - h)*60 %/% 1
  hours(as.integer(h)) + minutes(as.integer(m))
}


#' Convert date or datetime value to timestamp number
#'
#' @param date date or datetime value
#' @param tzone character, time-zone of the current time
#' @param milliseconds logical, whether the timestamp is in milliseconds or seconds
#'
#' @return numeric
#' @export
#'
#' @importFrom lubridate force_tz as_datetime
#'
date_to_timestamp <- function(date, tzone = "Europe/Paris", milliseconds = T) {
  timestamp <- as.integer(
    force_tz(
      as_datetime(date, tz = "UTC"),
      tzone
    )
  )
  if (milliseconds) {
    return ( timestamp*1000 )
  } else {
    return( timestamp )
  }
}





#' Week date from datetime value
#'
#' @param dttm datetime vector
#'
#' @return date vector
#' @export
#'
#' @importFrom lubridate as_date year isoweek
#'
get_week_from_datetime <- function(dttm) {
    as_date(paste(year(dttm), isoweek(dttm), 1), format = "%Y %W %u")
}


#' Summarise dataframe with weekly total column values
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being 
#' of class datetime and rest of columns being numeric
#'
#' @return tibble
#' @export
#'
#' @importFrom dplyr mutate select group_by summarise_if mutate_if arrange
#' @importFrom rlang .data
#'
get_week_total <- function(dtf) {
    resolution <- as.numeric(dtf$datetime[2] - dtf$datetime[1], units = "mins")
    dtf |>
        mutate_if(
            is.numeric,
            `*`,
            resolution / 60
        ) |>
        group_by(
            week = get_week_from_datetime(.data$datetime)
        ) |>
        summarise_if(
            is.numeric,
            sum
        ) |>
        arrange(.data$week)
}
