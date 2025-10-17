test_that("plot_ts returns a dygraph object", {
  plot_data <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
    consumption = c(1.5, 1.8, 1.6, 1.7)
  )

  graph <- plot_ts(plot_data, title = "Consumption", ylab = "kW")

  expect_s3_class(graph, "dygraphs")
  expect_s3_class(graph, "htmlwidget")
})
