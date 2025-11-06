#' Date time sequence with time zone and resolution
#'
#' @param start_date Date, start date of the output datetime sequence
#' @param end_date Date, end date of the output datetime sequence (included)
#' @param tzone character, desired time-zone of the datetime sequence
#' @param resolution integer, interval of minutes between two consecutive datetime values
#'
#' @return vector of datetime values
#' @export
#'
#' @importFrom lubridate as_datetime minutes days
#'
#' @examples
#' get_datetime_seq(
#'   start_date = as.Date("2024-01-01"),
#'   end_date = as.Date("2024-01-03"),
#'   tzone = "UTC",
#'   resolution = 120
#' )
#'
get_datetime_seq <- function(start_date, end_date, tzone, resolution) {
  dttm_seq <- seq.POSIXt(
    from = as_datetime(start_date, tz = tzone),
    to = as_datetime(end_date, tz = tzone) + days(1) - minutes(resolution),
    by = paste(resolution, "min")
  )
  return(dttm_seq)
}


#' Yearly date time sequence with time zone and resolution
#'
#' @param year integer, year of the datetime sequence
#' @param tzone character, desired time-zone of the datetime sequence
#' @param resolution integer, interval of minutes between two consecutive datetime values
#'
#' @return vector of datetime values
#' @export
#'
#' @examples
#' get_yearly_datetime_seq(
#'   year = 2024,
#'   tzone = "UTC",
#'   resolution = 60
#' )
#'
get_yearly_datetime_seq <- function(year, tzone, resolution) {
  dttm_seq <- get_datetime_seq(
    start_date = as.Date(sprintf("%s-01-01", year)),
    end_date = as.Date(sprintf("%s-12-31", year)),
    tzone = tzone,
    resolution = resolution
  )

  return(dttm_seq)
}


#' Aggregate multiple timeseries columns to a single one
#'
#' The first column `datetime` will be kept.
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param varname character, name of the aggregation column
#' @param omit character, name of columns to not aggregate
#'
#' @return tibble
#' @export
#'
#' @examples
#' building_flows <- data.frame(
#'   datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
#'   building1 = c(2.1, 2.5, 2.3, 2.0),
#'   building2 = c(1.0, 1.1, 0.9, 1.2)
#' )
#' aggregate_timeseries(building_flows, varname = "total_building")
#'
aggregate_timeseries <- function(dtf, varname, omit = NULL) {
  dtf2 <- dtf["datetime"]
  omit_col_n <- which(colnames(dtf) %in% c("datetime", omit))
  dtf2[[varname]] <- rowSums(dtf[-omit_col_n])
  if (!is.null(omit)) {
    for (omit_var in omit) {
      dtf2[[omit_var]] <- dtf[[omit_var]]
    }
  }
  return(dtf2)
}



#' Add an extra day at the beginning and the end of datetime sequence
#' using the last and first day of the data
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#'
#' @return tibble
#' @export
#'
#' @importFrom dplyr filter %>% bind_rows arrange
#' @importFrom lubridate date days
#'
add_extra_days <- function(dtf) {
  first_day <- dtf %>%
    filter(date(.data$datetime) == min(date(.data$datetime)))
  first_day$datetime <- first_day$datetime - days(1)

  last_day <- dtf %>%
    filter(date(.data$datetime) == max(date(.data$datetime)))
  last_day$datetime <- last_day$datetime + days(1)

  bind_rows(
    first_day, dtf, last_day
  ) %>%
    arrange(.data$datetime)
}


#' Get the time zone of a time series dataframe
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @return character
#' @export
#' @examples
#' get_timeseries_tzone(dtf)
#'
get_timeseries_tzone <- function(dtf) {
  return(tz(dtf$datetime[1]))
}


#' Adapt the timezone of a time series dataframe
#'
#' The timezone of the `datetime` column is changed while
#' keeping the same date time sequence.
#' This is useful when the time series data is known to be in a different timezone.
#' If you just want the same time series in a different timezone,
#' use `lubridate::force_tz` function instead.
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param tzone character, desired time-zone of the datetime sequence
#'
#' @return tibble
#' @export
#'
#' @importFrom lubridate date with_tz
#' @importFrom dplyr %>% mutate tibble left_join
#' @importFrom rlang .data
#'
#' @examples
#' # Example data set
#' get_timeseries_tzone(dtf)
#' range(dtf$datetime)
#'
#' #  Change timezone
#' new_dtf <- change_timeseries_tzone(dtf, tzone = "Europe/Paris")
#' get_timeseries_tzone(new_dtf)
#' range(new_dtf$datetime)
#'
change_timeseries_tzone <- function(dtf, tzone = "Europe/Amsterdam") {
  dtf_start_date <- date(min(dtf$datetime))
  dtf_end_date <- date(max(dtf$datetime))
  dtf_resolution <- get_timeseries_resolution(dtf, units = "mins")
  dtf_tz <- get_timeseries_tzone(dtf)

  if (dtf_tz == tzone) {
    return(dtf)
  }

  #  Get the desired date time sequence
  datetime_seq_out <- get_datetime_seq(
    start_date = dtf_start_date,
    end_date = dtf_end_date,
    tzone = tzone,
    resolution = dtf_resolution
  )

  # Join the original data with the new time zone
  # to the desired date time sequence
  dtf_tz_out <- dtf %>%
    mutate(
      datetime = with_tz(.data$datetime, tzone)
    )
  dtf_out <- tibble(
    datetime = datetime_seq_out
  ) %>%
    left_join(
      dtf_tz_out,
      by = "datetime"
    )

  # Check if there is hour shift
  dtf_out_idx_missing_data <- !(dtf_out$datetime %in% dtf_tz_out$datetime)
  dtf_tz_out_idx_shift_data <- !(dtf_tz_out$datetime %in% dtf_out$datetime)
  if (any(dtf_out_idx_missing_data)) {
    # Find the data values that have not been inserted in the output
    #  Insert these values back in the output dataframe
    dtf_out[dtf_out_idx_missing_data, -1] <- dtf_tz_out[dtf_tz_out_idx_shift_data, -1]
  }

  return(dtf_out)
}



#' Adapt time-series dataframe to timezone, date range and fill gaps
#' 
#' This function adapts the date range of a time series by reusing historical 
#' patterns based on the same weekday occurrence within the year and decimal 
#' hour of the day. It also can fill gaps in the data based on past data, 
#' so it is recommended to use it for time series with weekly or yearly patterns
#' (so for example energy demand but not solar generation).
#' It can also adapt the timezone of the time series, for example if the data
#' was stored in UTC but corresponds to a different timezone.
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' @param start_date Date, start date of the output datetime sequence
#' @param end_date Date, end date of the output datetime sequence (included)
#' @param tzone character, desired time-zone of the datetime sequence.
#' If NULL, the timezone of `dtf$datetime` is kept.
#' @param fill_gaps boolean, whether to fill gaps based on
#' same weekday and hour from past data (See `fill_from_past` function).
#'
#' @importFrom dplyr mutate left_join select rename_with across everything group_by summarise cur_column
#' @importFrom lubridate with_tz days
#' @importFrom rlang .data
#' @importFrom utils tail
#' @importFrom stats complete.cases
#' @return tibble
#' @export
#'
#' @examples
#' # Example data set
#' print(dtf)
#'
#' # Original date range
#' range(dtf$datetime)
#'
#' dtf2 <- adapt_timeseries(
#'   dtf,
#'   start_date = as.Date("2021-01-01"),
#'   end_date = as.Date("2021-01-31"),
#'   tzone = "America/New_York",
#'   fill_gaps = FALSE
#' )
#'
#' # New date range
#' range(dtf2$datetime)
#'
adapt_timeseries <- function(dtf, start_date, end_date, tzone = NULL, fill_gaps = FALSE) {
  
  # 1. Fill missing data
  # If we have some gaps in the data, try to fill them first
  # based on same weekday and same hour
  dtf_resolution <- get_timeseries_resolution(dtf, units = "mins")
  if (anyNA(dtf[-1])) {
    if (fill_gaps) {
      dtf <- dtf |>
        fill_from_past(
          names(dtf[-1]),
          back = 7 * 24 * 60 / dtf_resolution
        )
    } else {
      stop("Error: there are NA values in `dtf`. Fix it or use `fill_gaps = TRUE`.")
    }
  }
  
  # 2. Change timezone to UTC
  # This way, when changing date range we avoid issues with daylight saving time
  dtf_utc <- change_timeseries_tzone(
    dtf, tzone = "UTC"
  )

  # 3. Change date range
  dttm_seq_utc <- get_datetime_seq(
    start_date = start_date,
    end_date = end_date,
    tzone = "UTC",
    resolution = dtf_resolution
  )

  dtf_utc_out <- tibble(datetime = dttm_seq_utc) |>
    left_join(dtf, by = "datetime")

  # If real data is not available, try to use the most
  # recent data based on the same yearweekday and daytime
  if (anyNA(dtf_utc_out[-1])) {
    dtf_utc_recentdata <- dtf_utc |>
      mutate(
        ywday = ywday(.data$datetime),
        dhours = dhours(.data$datetime)
      ) |>
      group_by(.data$ywday, .data$dhours) |>
      summarise(
        across(everything(), ~ tail(.x, n = 1)),
        .groups = "drop"
      ) |> # Get last available data
      rename_with(
        ~ paste0(.x, "0"),
        .cols = -c("ywday", "dhours")
      )

    dtf_utc_out <- dtf_utc_out |>
      mutate(
        ywday = ywday(.data$datetime),
        dhours = dhours(.data$datetime)
      ) |>
      left_join(
        dtf_utc_recentdata,
        by = c("ywday", "dhours")
      ) |>
      mutate(across(
        names(dtf[-1]),
        ~ ifelse(is.na(.x), get(paste0(cur_column(), "0")), .x)
      )) |>
      select(names(dtf))
    
    # If we still have missing data (e.g., 31st Dec),
    # we cannot fill it based on ywday and dhours
    # so we fill it from past data directly
    if (anyNA(dtf_utc_out[-1])) {
      na_rows <- which(!complete.cases(dtf_utc_out))
      dtf_utc_out_missing_dates <- unique(date(
        dtf_utc_out$datetime[na_rows]
      ))

      # If more than 2 days are missing, it's not due the
      # yearweekday/daytime method, so we can't fill them properly
      if (length(dtf_utc_out_missing_dates) > 2) {
        warning("More than 2 days of data are missing. Use more data as input.")
      } else {
        dtf_utc_out <- dtf_utc_out |>
          fill_from_past(
            names(dtf[-1]),
            back = 7 * 24 * 60 / dtf_resolution
          )
      }
    }

    # # With full-year time-series, the 31st Dec is always missing
    # # in dtf_utc_out and cannot be filled by ywday and dhours
    # # (different number of weekdays according to the year).
    # # However the last available 31st Dec from `dtf_utc_recentdata`
    # # is at the same time not used in `dtf_utc_out`.
    # dtf_utc_recentdata_missing_idx <- which(
    #   !(dtf_utc_recentdata$ywday %in% dtf_utc_out$ywday)
    # )
    # # dtf_utc_recentdata$datetime0[dtf_utc_recentdata_missing_idx]
    # Use `tail` because there could be multiple missing days 
    # (e.g., leap years)
    # dtf_utc_out_missing_idx <- tail(which(
    #   !(dtf_utc_out$ywday %in% dtf_utc_recentdata$ywday)
    # ), n = length(dtf_utc_recentdata_missing_idx))
    # dtf_utc_out$datetime[dtf_utc_out_missing_idx]
    
    # if (length(dtf_utc_out_missing_idx) > 0) {
    #   dtf_utc_out[dtf_utc_out_missing_idx, names(dtf[-1])] <-
    #     dtf_utc_recentdata[dtf_utc_recentdata_missing_idx, paste0(names(dtf[-1]), "0")]
    # }

    # dtf_utc_out <- dtf_utc_out |>
    #   select(names(dtf))
  }

  # 4. Change timezone to desired timezone
  if (is.null(tzone)) {
    tzone <- get_timeseries_tzone(dtf)
  }
  dtf_out <- change_timeseries_tzone(dtf_utc_out, tzone = tzone)

  return(dtf_out)
}

#' Year-weekday occurrence identifier
#'
#' Computes a stable index for each datetime by combining the weekday
#' (Monday = 1) with how many times that weekday has already occurred in the
#' year. The result can be used to align data such as "third Monday" across
#' different calendar years without depending on ISO week numbers.
#'
#' @param datetime POSIXct vector.
#'
#' @return Integer vector; for example, `402` denotes the second Thursday.
#' @keywords internal
#'
ywday <- function(datetime) {
  # `week` returns the number of full weeks + 1
  # (counting from day 1, not first Monday)
  lubridate::wday(datetime, week_start = 1) * 100 +
    lubridate::week(datetime)
}

#' Decimal hours from datetime
#'
#' Converts a datetime vector into decimal hours (hour plus minutes / 60).
#' The input must not include seconds because sub-minute resolution would make
#' the decimal representation ambiguous for matching time slots.
#'
#' @param datetime POSIXct vector.
#'
#' @return Numeric vector with decimal hours.
#' @keywords internal
#'
dhours <- function(datetime) {
  if (any(lubridate::second(datetime) != 0)) {
    stop("Error: datetime values must not have seconds")
  }
  lubridate::hour(datetime) +
    lubridate::minute(datetime) / 60
}

#' Check if there are any gaps in the datetime sequence
#' 
#' This means all rows a part from "datetime" will be NA.
#' Note that timefully considers a full datetime sequence 
#' when days are complete.
#' 
#' @param dtf data.frame or tibble, first column of name `datetime` being
#' of class datetime and rest of columns being numeric
#' 
#' @importFrom dplyr tibble left_join
#' 
#' 
#' @return tibble
#' @export 
#' 
#' @examples
#' # Sample just some hours
#' dtf_gaps <- dtf[c(1:3, 7:10), ]
#' 
#' # Note that the full day is provided
#' check_timeseries_gaps(
#'    dtf_gaps
#' )
check_timeseries_gaps <- function(dtf) {
  resolution <- get_timeseries_resolution(dtf)
  tzone <- get_timeseries_tzone(dtf)
  dtf_full <- tibble(
    datetime = get_datetime_seq(
      start_date = date(min(dtf$datetime)),
      end_date = date(max(dtf$datetime)),
      tzone = tzone, resolution = resolution
    )
  ) |>
    left_join(dtf, by = "datetime")

  if (nrow(dtf_full) > nrow(dtf)) {
    warning("There are gaps in the data.")
  }
  return( dtf_full )
}
