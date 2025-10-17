
#' Return the time resolution of a datetime sequence
#'
#' @param dttm_seq datetime sequence
#' @param units character being one of "auto", "secs", "mins", "hours", "days" and "weeks"
#'
#' @return numeric
#' @export
#'
#' @examples
#' seq_15m <- as.POSIXct(
#'   c("2024-01-01 00:00:00", "2024-01-01 00:15:00", "2024-01-01 00:30:00"),
#'   tz = "UTC"
#' )
#' get_time_resolution(seq_15m, units = "mins")
#'
get_time_resolution <- function(dttm_seq, units = 'mins') {
  as.numeric(dttm_seq[2] - dttm_seq[1], units)
}


#' Change time resolution of a time-series data frame
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being 
#' of class datetime and rest of columns being numeric
#' @param resolution_out integer, desired interval of minutes between two consecutive datetime values
#' @param method character, being `interpolate`, `repeat` or `divide` if the resolution has to be increased,
#' or `average`, `first` or `sum` if the resolution has to be decreased. See Examples for more information.
#'
#' @return tibble
#' @export
#'
#' @importFrom dplyr tibble select_if
#'
#' @examples
#' fifteen_min <- data.frame(
#'   datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:7 * 900,
#'   load = c(10, 12, 14, 16, 14, 12, 10, 8)
#' )
#' change_timeseries_resolution(
#'   fifteen_min,
#'   resolution_out = 60,
#'   method = "average"
#' )
#'
#'
#'
change_timeseries_resolution <- function(dtf, resolution_out, method) {
  current_resolution <- get_time_resolution(dtf$datetime, units = "mins")
  if (current_resolution == resolution_out) {
    return(dtf)
  } else if (resolution_out > current_resolution) {
    if (method %in% c("average", "first", "sum")) {
      return(decrease_timeseries_resolution(dtf, resolution_out, method))
    } else {
      stop("Error: method not valid for decreasing resolution")
    }
  } else {
    if (method %in%  c("interpolate", "repeat", "divide")) {
      return(increase_timeseries_resolution(dtf, resolution_out, method))
    } else {
      stop("Error: method not valid for increasing resolution")
    }
  }
}



#' Interpolate `n` values between two numeric values
#'
#' @param y1 first value
#' @param y2 second value
#' @param n integer, number of intra-values (counting the original value as the first one)
#'
#' @importFrom dplyr tibble
#' @importFrom stats lm predict
#'
#' @keywords internal
#' @return numeric vector
#'
interpolation <- function(y1, y2, n) {
  if (is.na(y1) | is.na(y2)) {
    return( rep(y1, n) )
  }
  as.numeric(
    predict(
      lm(
        y ~ x,
        tibble(x = c(1, (n+1)), y = c(y1, y2))
      ),
      tibble(x=c(1:n))
    )
  )
}

#' Increase numeric vector resolution
#'
#' @param y original numeric vector
#' @param n integer, number of intra-values (counting the original value as the first one)
#' @param method character, being `interpolate`, `repeat` or `divide` as valid options
#'
#' @return numeric vector
#' @keywords internal
#'
#' @importFrom dplyr tibble lead
#' @importFrom purrr pmap simplify
#'
#' @details
#' if we have a vector v = c(1, 2), and we choose the `interpolate` method,
#' then:
#'
#' `increase_numeric_resolution(v, 4, 'interpolate')`
#'
#' returns `c(1, 1.25, 1.5, 1.75, 2)`
#'
#' if we choose the `repeat` method, then:
#'
#' `increase_numeric_resolution(v, 4, 'repeat')`
#'
#' returns c(1, 1, 1, 1, 2)
#'
increase_numeric_resolution <- function(y, n, method = c('interpolate', 'repeat', 'divide')) {
  if (method == 'interpolate') {
    tibble(y1 = y, y2 = lead(y, default = 0)) |>
      pmap(~ interpolation(..1, ..2, n)) |>
      simplify() |>
      as.double()
  } else if (method == 'repeat') {
    rep(y, each = n)
  } else if (method == 'divide') {
    rep(y/n, each = n)
  } else {
    stop("Error: method not valid")
  }
}

#' Increase datetime vector resolution
#'
#' @param y vector of datetime values
#' @param resolution_mins integer, interval of minutes between two consecutive datetime values
#'
#' @return datetime vector
#' @keywords internal
#'
#' @importFrom lubridate minutes as_datetime tz
#'
increase_datetime_resolution <- function(y, resolution_mins) {
  seq.POSIXt(y[1], y[length(y)]+(y[2]-y[1])-minutes(resolution_mins), by = paste(resolution_mins, 'min')) |> as_datetime(tz = tz(y))
}

#' Increase time resolution of a timeseries data frame
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being 
#' of class datetime and rest of columns being numeric
#' @param resolution_mins integer, interval of minutes between two consecutive datetime values
#' @param method character, being `interpolate`, `repeat` or `divide` as valid options.
#' See `increase_numeric_resolution` function for more information.
#'
#' @return tibble
#' @keywords internal
#'
#' @importFrom dplyr tibble select_if
#'
increase_timeseries_resolution <- function(dtf, resolution_mins, method = c('interpolate', 'repeat', 'divide')) {
  new_df <- tibble(datetime = increase_datetime_resolution(dtf$datetime, resolution_mins))
  current_resolution <- get_time_resolution(dtf$datetime, units = "mins")
  numeric_df <- dtf |> select_if(is.numeric)
  for (col in colnames(numeric_df)) {
    new_df[[col]] <- increase_numeric_resolution(numeric_df[[col]], n = current_resolution/resolution_mins, method)
  }
  return( new_df )
}


#' Decrease resolution of a numeric vector
#'
#' @param y original numeric vector
#' @param n integer, number of intra-values (counting the original value as the first one)
#' @param method character, being `average`, `first` or `sum` as valid options
#'
#' @return numeric vector
#' @keywords internal
#'
#' @importFrom dplyr group_by summarise pull tibble
#' @importFrom rlang .data
#'
decrease_numeric_resolution <- function(y, n, method = c('average', 'first', 'sum')) {
  if ((length(y)%%n) > 0) {
    stop("Error decreasing resolution: the original vector should have a length multiple of `n`.")
  }

  if (method == 'average') {
    return(
      tibble(
        idx = rep(seq(1, length(y)/n), each = n),
        y = y
      ) |>
        group_by(.data$idx) |>
        summarise(y = mean(y)) |>
        pull(y) |>
        as.numeric()
    )
  } else if (method == 'first') {
    return(
      y[seq(1, length(y), n)]
    )
  } else if (method == 'sum') {
    return(
      tibble(
        idx = rep(seq(1, length(y)/n), each = n),
        y = y
      ) |>
        group_by(.data$idx) |>
        summarise(y = sum(y)) |>
        pull(y) |>
        as.numeric()
    )
  } else {
    stop("Error: method not valid")
  }
}

#' Decrease time resolution of timeseries data frame
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being 
#' of class datetime and rest of columns being numeric
#' @param resolution_mins integer, interval of minutes between two consecutive datetime values
#' @param method character, being `average`, `first` or `sum` as valid options
#'
#' @return tibble
#' @keywords internal
#'
#' @importFrom dplyr mutate group_by summarise_all distinct
#' @importFrom lubridate floor_date
#' @importFrom rlang .data
#'
decrease_timeseries_resolution <- function(dtf, resolution_mins, method = c('average', 'first', 'sum')) {
  dtf2 <- dtf |>
    mutate(datetime = floor_date(.data$datetime, paste(resolution_mins, 'minute')))
  if (method == 'average') {
    return(
      dtf2 |>
        group_by(.data$datetime) |>
        summarise_all(mean)
    )
  } else if (method == 'first') {
    return(
      dtf2 |>
        distinct(.data$datetime, .keep_all = T)
    )
  } else if (method == 'sum') {
    return(
      dtf2 |>
        group_by(.data$datetime) |>
        summarise_all(sum)
    )
  } else {
    stop("Error: method not valid")
  }
}
