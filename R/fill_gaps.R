
#' Fill gaps with a specific value
#' 
#' This is usefull when the gaps in a numeric timeseries can be
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
  return( dtf )
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
fill_from_past <- function(dtf, varnames, back=24) {
  tbl_to_fill <- dtf[varnames]
  for (col in varnames) {
    na_idx <- which(is.na(tbl_to_fill[col]))
    for (idx in na_idx) {
      back_idx <- idx
      # if (back_idx <= 0) back_idx <- 1
      while (is.na(tbl_to_fill[back_idx, col])) {
        back_idx <- back_idx - back
        if (back_idx <= 0) {
          back_idx <- 1
          break
        }
      }
      new_value <- tbl_to_fill[back_idx, col]
      if (is.na(new_value)) {
        message(paste(
            "Could not find numeric values in the past for column", 
            col, "and index", idx
        ))
      }
      tbl_to_fill[idx, col] <- tbl_to_fill[back_idx, col]
    }
  }
  dtf[varnames] <- tbl_to_fill
  return( dtf )
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
      for (i in na_idx:(na_idx+max_timeslots-1)) {
        if (!is.na(var_values_filled[i]) | length(var_values_filled) < i)
          break
        var_values_filled[i] <- var_values_filled[na_idx-1]
      }
    }
    dtf[[var_name]] <- var_values_filled
  }

  return( dtf )
}



#' Fill NA values of a datetime sequence vector
#'
#' @param dttm datetime sequence vector
#'
#' @return filled datetime sequence vector
#' @export
#'
#' @importFrom lubridate minutes
#'
#' @examples
#' incomplete_seq <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:4 * 3600
#' incomplete_seq[c(2, 3)] <- NA
#' fill_datetime(incomplete_seq)
#'
fill_datetime <- function(dttm) {
  # detect the time interval of the sequence
  dttm_diff <- as.numeric(dttm - lag(dttm), units = 'mins')
  time_interval_minutes <- as.integer(dttm_diff[which(!is.na(dttm_diff))[1]])

  # find missing values
  dttm_na_i <- which(is.na(dttm))

  # fill missing values
  while (sum(is.na(dttm)) > 0) {
    for (i in dttm_na_i) {
      last_i <- i - 1
      next_i <- i + 1

      if ((last_i %in% dttm_na_i) | (last_i < 1)) {
        if ((next_i %in% dttm_na_i) | (next_i > length(dttm))) {
          next
        } else {
          dttm[i] <- dttm[next_i] - minutes(time_interval_minutes)
        }
      } else {
        dttm[i] <- dttm[last_i] + minutes(time_interval_minutes)
      }
    }
  }

  return(dttm)
}
