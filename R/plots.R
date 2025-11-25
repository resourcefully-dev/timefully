
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
plot_ts <- function(df, title = NULL, xlab = NULL, ylab = NULL,
                    legend_show = "auto", legend_width = 250,
                    group = NULL, width = NULL, height = NULL, ...) {
  dygraph(df, main = title, xlab = xlab, ylab = ylab, group = group, width = width, height = height) |>
    dyLegend(show = legend_show, width = legend_width, showZeroValues = TRUE) |>
    dyOptions(retainDateWindow = TRUE, useDataTimezone = TRUE, ...) |>
    dyCSS(system.file("www", "dystyle.css", package = "timefully"))
}
