

#' Datetime sequence
#'
#' @param year integer, year of the datetime sequence
#' @param tzone character, time-zone of the datetime sequence
#' @param resolution_mins integer, interval of minutes between two consecutive datetime values
#' @param fullyear boolean, whether to return a full-year sequence
#' @param start_date Date, if `fullyear` is `FALSE` set a starting date. Ignored when `fullyear` is `TRUE`.
#' @param end_date Date, if `fullyear` is `FALSE` set a final date. Ignored when `fullyear` is `TRUE`.
#'
#' @return vector of datetime values
#' @export
#'
#' @importFrom lubridate as_datetime dmy round_date minutes dmy_hm
#'
get_datetime_seq <- function(year, tzone, resolution_mins, fullyear = TRUE, start_date = NULL, end_date = NULL) {
    if (!fullyear && is.null(start_date) && is.null(end_date)) {
        message("if start_date and end_date are not provided, fullyear must be TRUE")
        return(NULL)
    }
    if (fullyear) {
        return(
            seq.POSIXt(
                from = dmy(paste0("01/01/", year), tz = tzone),
                to = dmy(paste0("01/01/", year + 1), tz = tzone) - minutes(resolution_mins),
                by = paste(resolution_mins, "min")
            )
        )
    } else {
        if (is.null(start_date) || is.null(end_date)) {
            message("both start_date and end_date must be provided")
            return(NULL)
        }
        return(
            seq.POSIXt(
                from = as_datetime(start_date, tz = tzone),
                to = as_datetime(end_date, tz = tzone) - minutes(resolution_mins),
                by = paste(resolution_mins, "min")
            )
        )
    }
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
#' # Example data set with 2 identical building profiles
#' dtf2 <- dplyr::select(
#'   dtf, datetime, building1 = building, building2 = building
#' )
#' head(dtf2)
#'
#' # Aggregate the total building demand
#' head(aggregate_timeseries(dtf2, varname = "total_buildings"))
#'
aggregate_timeseries <- function(dtf, varname, omit = NULL) {
  dtf2 <- dtf['datetime']
  omit_col_n <- which(colnames(dtf) %in% c('datetime', omit))
  dtf2[[varname]] <- rowSums(dtf[-omit_col_n])
  if (!is.null(omit)) {
    for (omit_var in omit) {
      dtf2[[omit_var]] <- dtf[[omit_var]]
    }
  }
  return( dtf2 )
}





#' Adapt time-series dataframe to timezone, date range and fill gaps
#'
#' @param dtf data.frame or tibble, first column of name `datetime` being 
#' of class datetime and rest of columns being numeric
#' @param start_date Date, start date of the output datetime sequence
#' @param end_date Date, end date of the output datetime sequence
#' @param tzone character, time-zone of the datetime sequence.
#' If NULL, the timezone of `dtf$datetime` is kept.
#' @param fill_gaps boolean, whether to fill gaps based on same yearweekday 
#' and daytime, and if not available, with last week same day same hour
#'
#' @importFrom dplyr mutate left_join select rename_with across everything group_by summarise cur_column
#' @importFrom lubridate with_tz wday week hour minute tz
#' @importFrom rlang .data
#' @return tibble
#' @export
#'
#' @examples
#' 
#' # Original date range
#' range(dtf$datetime)
#' 
#' # Timeseries adapted to January 2021
#' dtf2 <- adapt_timeseries(
#'  dtf, 
#'  start_date = as.Date("2021-01-01"), 
#'  end_date = as.Date("2021-01-31"),
#'  tzone = "Europe/Paris", 
#'  fill_gaps = FALSE
#' )
#' 
#' # New date range
#' range(dtf2$datetime)
#' 
adapt_timeseries <- function(dtf, start_date, end_date, tzone = NULL, fill_gaps = FALSE) {

  # 1. Change timezone
  if (is.null(tzone)) {
    tzone <- tz(dtf$datetime)
  } else {
    if (!(tzone %in% OlsonNames())) {
      stop(paste0(
        "Error: '", tzone, "' is not a valid time-zone. ",
        "See ?OlsonNames for valid names."
      ))
    }
    dtf_tz <- tz(dtf$datetime)
    if (dtf_tz != tzone) {
      dtf <- dtf |>
        mutate(
          datetime = with_tz(.data$datetime, tzone)
        )
    }
  }

  # 2. Change date range
  dtf_resolution <- get_time_resolution(dtf$datetime, units = "mins")
  dttm_seq <- get_datetime_seq(
    year = year(start_date),
    tzone = tzone,
    resolution_mins = dtf_resolution,
    fullyear = FALSE,
    start_date = start_date,
    end_date = end_date
  )

  dtf_out <- tibble(datetime = dttm_seq) |>
    left_join(dtf, by = "datetime")

  # If there are no gaps, return the data frame
  if (!any(is.na(dtf_out[-1]))) {
    return( dtf_out )
  }

  # If there are gaps, try to use the most recent data
  # based on the same yearweekday and daytime
  dtf_out <- dtf_out |>
    mutate(
      ywday = ywday(.data$datetime),
      dtime = dtime(.data$datetime)
    ) |>
    left_join(
      dtf |>
        mutate(
          ywday = ywday(.data$datetime),
          dtime = dtime(.data$datetime)
        ) |>
        group_by(.data$ywday, .data$dtime) |>
        summarise(
          across(everything(), ~ tail(.x, n = 1)),
          .groups = "drop"
        ) |>  # Get last available data
        rename_with(
          ~ paste0(.x, "0"), .cols = -c("ywday", "dtime")
        ),
      by = c("ywday", "dtime")
    ) |>
    mutate(across(
      names(dtf[-1]),
      ~ ifelse(is.na(.x), get(paste0(cur_column(), "0")), .x)
    )) |>
    select(names(dtf))

  # 3. Fill missing data
  # If we still have gaps (so we don't have data 
  # from the same yearweekday or daytime),
  # fill these gaps with last week same day same hour
  if (any(is.na(dtf_out[-1]))) {
    if (fill_gaps) {
      dtf_out <- dtf_out |>
        fill_from_past(
          names(dtf[-1]), back = 7*24*60/dtf_resolution
        )
    } else {
      message("Warning: Some NA generated in `df`. Gather more data or use `fill_gaps = TRUE`.")
    }
  }

  return( dtf_out )
}

ywday <- function(datetime) {
  # `week` returns the number of full weeks + 1
  wday(datetime, week_start = 1)*100 + week(datetime)
}

# datetime must not have seconds
dtime <- function(datetime) {
  hour(datetime)*100 + minute(datetime)
}
