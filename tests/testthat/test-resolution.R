test_that("get_time_resolution returns minute difference", {
  seq_15m <- as.POSIXct(
    c("2024-01-01 00:00:00", "2024-01-01 00:15:00", "2024-01-01 00:30:00"),
    tz = "UTC"
  )

  expect_equal(
    get_time_resolution(seq_15m, units = "mins"),
    15
  )
})

test_that("change_timeseries_resolution averages to hourly data", {
  fifteen_min <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:7 * 900,
    load = c(10, 12, 14, 16, 20, 22, 24, 26)
  )

  hourly <- change_timeseries_resolution(
    fifteen_min,
    resolution_out = 60,
    method = "average"
  )

  expect_equal(nrow(hourly), 2)
  expect_equal(
    hourly$load,
    c(mean(fifteen_min$load[1:4]), mean(fifteen_min$load[5:8]))
  )
})
