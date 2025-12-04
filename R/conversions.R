#' Convert numeric time value to a datetime period (hour-based)
#'
#' @param time_num Numeric time value (hour-based)
#' @return `lubridate::period` vector with hours and minutes corresponding to
#' the numeric input.
#'
#' @examples
#' convert_time_num_to_period(1.5)
#' convert_time_num_to_period(c(0.25, 2))
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
#'
#' @examples
#' date_to_timestamp(as.Date("2024-01-01"))
#' date_to_timestamp(as.POSIXct("2024-01-01 08:00:00", tz = "UTC"), milliseconds = FALSE)
#'
#' @export
#'
#' @importFrom lubridate force_tz as_datetime
#'
date_to_timestamp <- function(date, tzone = "Europe/Paris", milliseconds = TRUE) {
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
#' @examples
#' dttm <- as.POSIXct(
#'   c("2024-01-01 08:00:00", "2024-01-02 09:00:00", "2024-01-08 10:00:00"),
#'   tz = "UTC"
#' )
#' get_week_from_datetime(dttm)
#'
#' @importFrom lubridate as_date year isoweek
#'
get_week_from_datetime <- function(dttm) {
    as_date(paste(year(dttm), isoweek(dttm), 1), format = "%Y %W %u")
}


#' Summarise dataframe with weekly total column values
#' 
#' Converts the numeric columns of a time-series data frame to total values per week (sum). 
#' Note that if the input values are in power units (e.g., kW), the output values will be in energy units (e.g., kWh).
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
#' @examples
#' get_week_total(dtf[1:100, ])
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

#' Convert a number of minutes in string format "HH:MM"
#' 
#' @param mins integer, number of minutes (from 0 to 1439)
#' 
#' @return character
#' @export
#' 
#' @examples 
#' to_hhmm(75)
#' 
to_hhmm <- function(mins) {
  if (mins > 1440) {
    stop("`mins` must be lower than 1439 (23:59)")
  }
  sprintf("%02d:%02d", mins %/% 60, mins %% 60)
}
