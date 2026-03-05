#' Fill gaps with a specific value
#'
#' This is useful when the gaps in a numeric timeseries can be
#' filled with the same number (e.g. zero)
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param varnames character or vector of characters,
#' column names with NA values
#' @param with numeric, value to fill NA values
#'
#' @return tibble or data.frame
#' @export
#'
#' @examples
#' past_data <- data.frame(
#'   datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
#'   consumption = c(1.2, NA, NA, 2.5)
#' )
#' fill_na(past_data, "consumption", with = 0)
#'
fill_na <- function(dtf, varnames, with = 0) {
  for (col in varnames) {
    dtf[is.na(dtf[[col]]), col] <- with
  }
  return(dtf)
}

#' Fill from past values
#'
#' If back index ( NA index - `back`) is lower than zero then the it is filled with the first value of the data frame.
#' If the value in the back index is also NA, it iterates backwards until finding a non-NA value.
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param varnames character or vector of characters,
#' column names with NA values
#' @param back integer, number of indices (rows) to go back and get the filling value
#'
#' @return tibble or data.frame
#' @export
#'
#' @examples
#' past_data <- data.frame(
#'   datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
#'   consumption = c(1.2, NA, NA, 2.5)
#' )
#' fill_from_past(past_data, "consumption", back = 1)
#'
fill_from_past <- function(dtf, varnames, back = 24) {
  if (length(back) != 1 || is.na(back) || !is.finite(back)) {
    stop("Error: `back` must be a single positive number.")
  }
  back <- as.integer(back)
  if (back < 1) {
    stop("Error: `back` must be at least 1.")
  }

  tbl_to_fill <- dtf[varnames]
  for (col in varnames) {
    col_values <- tbl_to_fill[[col]]
    na_idx <- which(is.na(col_values))
    for (idx in na_idx) {
      back_idx <- idx
      while (is.na(col_values[back_idx])) {
        back_idx <- back_idx - back
        if (is.na(back_idx) || !is.finite(back_idx) || back_idx <= 0) {
          back_idx <- 1
          break
        }
      }
      col_values[idx] <- col_values[back_idx]
    }
    tbl_to_fill[[col]] <- col_values
  }
  dtf[varnames] <- tbl_to_fill
  return(dtf)
}


#' Fill down tibble columns until a maximum number of time slots
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param varnames character or vector of characters,
#' column names with NA values
#' @param max_timeslots integer, maximum number of time slots to fill
#'
#' @return tibble
#' @export
#'
#' @importFrom dplyr lag
#'
#' @examples
#' down_data <- data.frame(
#'   datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:5 * 3600,
#'   temperature = c(15, 15, NA, NA, NA, 16)
#' )
#' fill_down_until(down_data, "temperature", max_timeslots = 2)
#'
fill_down_until <- function(dtf, varnames, max_timeslots = 1) {
  for (var_name in varnames) {
    var_values <- dtf[[var_name]]
    na_idxs <- which(is.na(var_values) & !is.na(dplyr::lag(var_values)))
    na_idxs <- na_idxs[na_idxs != 1]
    var_values_filled <- var_values
    for (na_idx in na_idxs) {
      for (i in na_idx:(na_idx + max_timeslots - 1)) {
        if (!is.na(var_values_filled[i]) | length(var_values_filled) < i) {
          break
        }
        var_values_filled[i] <- var_values_filled[na_idx - 1]
      }
    }
    dtf[[var_name]] <- var_values_filled
  }

  return(dtf)
}


#' Fill NA values of a datetime sequence vector
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#'
#' @importFrom lubridate date
#' @importFrom dplyr tibble left_join
#'
#' @return tibble
#' @export
#'
#' @examples
#' dtf_gaps <- timefully::dtf[c(1, 2, 3, 8, 9, 10), ]
#' print(dtf_gaps)
#' complete_timeseries_datetime(dtf_gaps)
#'
complete_timeseries_datetime <- function(dtf) {
  dtf_start_dttm <- min(dtf$datetime)
  dtf_end_dttm <- max(dtf$datetime)
  dtf_resolution <- get_timeseries_resolution(dtf, units = "mins")
  dtf_tz <- get_timeseries_tzone(dtf)

  #  Get the desired date time sequence
  datetime_seq_out <- get_datetime_seq(
    start_date = date(dtf_start_dttm),
    end_date = date(dtf_end_dttm),
    tzone = dtf_tz,
    resolution = dtf_resolution
  )
  # datetime_seq_out <- datetime_seq_out[
  #   datetime_seq_out >= dtf_start_dttm &
  #     datetime_seq_out <= dtf_end_dttm
  # ] # --> We consider full days in all timefully environment

  # Join the original data with the sequence
  dtf_out <- tibble(
    datetime = datetime_seq_out
  ) |>
    left_join(dtf, by = "datetime")

  if (nrow(dtf_out) > nrow(dtf)) {
    message(paste(
      "Added",
      nrow(dtf_out) - nrow(dtf),
      "rows to the data frame to fill in missing timestamps."
    ))
  }

  return(dtf_out)
}
