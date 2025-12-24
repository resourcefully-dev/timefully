#' Interactive plot for time-series tibbles
#'
#' First column of the `df` tibble must be a `datetime` or date variable.
#' The rest of columns must be numeric of the same units. This functions makes
#' use of `dygraphs` package to generate an HTML dygraphs plot.
#'
#' @param df data.frame or tibble, first column of name `datetime` being of class datetime and rest of columns being numeric
#' @param title character, title of the plot (accepts HTML code)
#' @param xlab character, X axis label (accepts HTML code)
#' @param ylab character, Y axis label (accepts HTML code)
#' @param legend_show character, when to display the legend.
#' Specify "always" to always show the legend.
#' Specify "onmouseover" to only display it when a user mouses over the chart.
#' Specify "follow" to have the legend show as overlay to the chart which follows the mouse.
#' The default behavior is "auto", which results in "always" when more than one series
#' is plotted and "onmouseover" when only a single series is plotted.
#' @param legend_width integer, width (in pixels) of the div which shows the legend.
#' @param group character, dygraphs group to associate this plot with. The x-axis zoom level of dygraphs plots within a group is automatically synchronized.
#' @param width Width in pixels (optional, defaults to automatic sizing)
#' @param height Height in pixels (optional, defaults to automatic sizing)
#' @param ... extra arguments to pass to `dygraphs::dyOptions` function.
#'
#' @return dygraph
#' @export
#'
#' @importFrom dygraphs dygraph dyLegend dyOptions dyCSS
#'
#' @examples
#' plot_ts(dtf, ylab = "kW", legend_show = "onmouseover")
#'
plot_ts <- function(
  df,
  title = NULL,
  xlab = NULL,
  ylab = NULL,
  legend_show = "auto",
  legend_width = 250,
  group = NULL,
  width = NULL,
  height = NULL,
  ...
) {
  dygraph(
    df,
    main = title,
    xlab = xlab,
    ylab = ylab,
    group = group,
    width = width,
    height = height
  ) |>
    dyLegend(show = legend_show, width = legend_width, showZeroValues = TRUE) |>
    dyOptions(retainDateWindow = TRUE, useDataTimezone = TRUE, ...) |>
    dyCSS(system.file("www", "dystyle.css", package = "timefully"))
}


# CHANGE DATETIME AXIS ------------------------------------------------------------------------------------------------

# how to use
# change datetime format in the Xaxis
# dyAxis("x", axisLabelFormatter = JS(<dateformat))
# dyAxis("x", axisLabelFormatter = JS(<js code created by functions below))
# dateformat <- paste0(function(d) { return new Date(d).toLocaleDateString('<locale.eg.nl-NL>', { month: 'short' }); })

# ->            Option        Description                     Example Output (nl-NL)
# ------------------------------------------------------------------------------------
# -> year:      'numeric'     Full year                         "2023"
# -> year:      '2-digit'     Last two digits of the year       "23"
# -> month:     'numeric'     Month as a number                 "1"
# -> month:     '2-digit'     Month as a two-digit number       "01"
# -> month:     'long'        Full month name                   "januari"
# -> month:     'short'       Abbreviated month name            "jan."
# -> day:       'numeric'     Day of the month                  "5"
# -> day:       '2-digit'     Day with leading zero             "05"
# -> weekday:   'long'        Full weekday name                 "vrijdag"
# -> weekday:   'short'       Abbreviated weekday name          "vr."
# -> weekday:   'narrow'      Single-letter weekday             "V"
# -> hour:      'numeric'     Hour (24-hour format by default)  "14"
# -> hour:      '2-digit'     Two-digit hour                    "14"
# -> minute:    'numeric'     Minute                            "30"
# -> minute:    '2-digit'     Two-digit minute                  "30"
# -> second:    'numeric'     Second                            "15"
# -> second:    '2-digit'     Two-digit second                  "15"

format_day <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric")) {
    stop("Invalid format for day")
  }
  paste0("day: '", as, "'")
}

format_weekday <- function(as = "long") {
  if (!as %in% c("long", "short", "narrow")) {
    stop("Invalid format for weekday")
  }
  paste0("weekday: '", as, "'")
}

format_month <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric", "long", "short")) {
    stop("Invalid format for month")
  }
  paste0("month: '", as, "'")
}

format_year <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric")) {
    stop("Invalid format for day")
  }
  paste0("year: '", as, "'")
}

format_hour <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric")) {
    stop("Invalid format for day")
  }
  paste0("hour: '", as, "'")
}

format_minute <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric")) {
    stop("Invalid format for day")
  }
  paste0("minute: '", as, "'")
}

format_second <- function(as = "2-digit") {
  if (!as %in% c("2-digit", "numeric")) {
    stop("Invalid format for day")
  }
  paste0("second: '", as, "'")
}

formatter <- list(
  day = format_day,
  weekday = format_weekday,
  month = format_month,
  year = format_year,
  hour = format_hour,
  minute = format_minute,
  second = format_second
)

t_formatter <- function(formating) {
  f_list <- lapply(names(formating), function(key) {
    if (!key %in% c("hour", "minute", "second")) {
      stop("Format only for time cannot format date only time")
    }
    formatter[[key]](formating[[key]])
  })
  paste(f_list, collapse = ", ")
}

d_formatter <- function(formating) {
  f_list <- lapply(names(formating), function(key) {
    if (key %in% c("hour", "minute", "second")) {
      stop("Format only for dates cannot format time with date_format")
    }
    formatter[[key]](formating[[key]])
  })
  paste(f_list, collapse = ", ")
}


#' Change datetime format
#' @return js code as a string to change datetime axis
#' @param format_list (named list) ORDER matters key and type of output as value
#' @param locale (str) locale to use in settings for example nl-NL (default)
#' @keywords internal
format_date_axis <- function(format_list, locale = "nl-NL") {
  return(paste0(
    "function(d) { return new Date(d).toLocaleDateString('",
    locale,
    "', { ",
    d_formatter(format_list),
    " }); }"
  ))
}

#' Format time axis
#' @return js code as a string to change datetime axis
#' @param format_list (named list) ORDER matters key and type of output as value
#' @param locale (str) locale to use in settings for example nl-NL (default)
#' @keywords internal
format_time_axis <- function(format_list, locale = "nl-NL") {
  return(paste0(
    "function(d) { return new Date(d).toLocaleTimeString('",
    locale,
    "', { ",
    t_formatter(format_list),
    " }); }"
  ))
}

#' Format datetime axis
#' @return js code as a string to change datetime axis
#' @param format_list (named list) ORDER matters key and type of output as value
#' @param locale (str) locale to use in settings for example nl-NL (default)
#'
#' @return JS function to pass to dyAxis function
#' @export
#'
#' @details
#' The `format_list` entries map to the JavaScript `toLocaleString` options:
#'
#' | Option  | Value     | Description                        | Example (nl-NL) |
#' |---------|-----------|------------------------------------|-----------------|
#' | year    | "numeric" | Full year                          | "2023"          |
#' | year    | "2-digit" | Last two digits of the year        | "23"            |
#' | month   | "numeric" | Month as a number                  | "1"             |
#' | month   | "2-digit" | Month as a two-digit number        | "01"            |
#' | month   | "long"    | Full month name                    | "januari"       |
#' | month   | "short"   | Abbreviated month name             | "jan."          |
#' | day     | "numeric" | Day of the month                   | "5"             |
#' | day     | "2-digit" | Day with leading zero              | "05"            |
#' | weekday | "long"    | Full weekday name                  | "vrijdag"       |
#' | weekday | "short"   | Abbreviated weekday name           | "vr."           |
#' | weekday | "narrow"  | Single-letter weekday              | "V"             |
#' | hour    | "numeric" | Hour (24-hour format by default)   | "14"            |
#' | hour    | "2-digit" | Two-digit hour                     | "14"            |
#' | minute  | "numeric" | Minute                             | "30"            |
#' | minute  | "2-digit" | Two-digit minute                   | "30"            |
#' | second  | "numeric" | Second                             | "15"            |
#' | second  | "2-digit" | Two-digit second                   | "15"            |
#' 
#' @examples
#' \dontrun{
#'
#'  dyplot <- plot_ts(dtf)
#'  xaxis_format <- format_date_axis(
#'    list(day = "2-digit", month = "short"),
#'    locale = "nl_NL"
#'  )
#'  dyplot |>
#'    dyAxis("x", axisLabelFormatter = JS(xaxis_format))
#'
#' }
format_datetime_axis <- function(format_list, locale = "nl-NL") {
  date_format_list <- format_list[
    !names(format_list) %in% list("hour", "minute", "second")
  ]
  time_format_list <- format_list[
    names(format_list) %in% list("hour", "minute", "second")
  ]
  return(paste0(
    "function(d) {const datePart = d.toLocaleDateString('",
    locale,
    "', { ",
    d_formatter(date_format_list),
    " });const timePart = d.toLocaleTimeString('",
    locale,
    "', { ",
    t_formatter(time_format_list),
    " });return `${datePart} ${timePart}`;"
  ))
}
