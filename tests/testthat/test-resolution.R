test_that("get_time_resolution returns minute difference", {
  seq_15m <- as.POSIXct(
    c("2024-01-01 00:00:00", "2024-01-01 00:15:00", "2024-01-01 00:30:00"),
    tz = "UTC"
  )

  expect_equal(
    get_time_resolution(seq_15m, units = "mins"),
    15
  )

  expect_equal(
    get_timeseries_resolution(dtf, units = "mins"),
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
    resolution = 60,
    method = "first"
  )

  expect_true(
    nrow(hourly) < nrow(fifteen_min)
  )

  hourly <- change_timeseries_resolution(
    fifteen_min,
    resolution = 60,
    method = "sum"
  )

  expect_true(
    nrow(hourly) < nrow(fifteen_min)
  )

  hourly <- change_timeseries_resolution(
    fifteen_min,
    resolution = 60,
    method = "average"
  )

  expect_equal(
    dtf,
    change_timeseries_resolution(dtf, resolution = 15)
  )
  expect_equal(nrow(hourly), 2)
  expect_equal(
    hourly$load,
    c(mean(fifteen_min$load[1:4]), mean(fifteen_min$load[5:8]))
  )
})

test_that("change_timeseries_resolution works increasing resolution", {
  fifteen_min <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:7 * 900,
    load = c(10, 12, 14, 16, 20, 22, 24, 26)
  )

  higher_res <- change_timeseries_resolution(
    fifteen_min,
    resolution = 5,
    method = "repeat"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

  higher_res <- change_timeseries_resolution(
    fifteen_min,
    resolution = 5,
    method = "interpolate"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

    higher_res <- change_timeseries_resolution(
    fifteen_min,
    resolution = 5,
    method = "divide"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

})

test_that("interpolate holds the last value instead of ramping to zero", {
  # Two hourly values on a 15 min grid: the first block runs towards the
  # second value, the second block has no successor and holds its value.
  expect_equal(
    increase_numeric_resolution(c(1, 2), 4, "interpolate"),
    c(1, 1.25, 1.5, 1.75, 2, 2, 2, 2)
  )

  # A constant series stays constant through its last block.
  expect_equal(
    increase_numeric_resolution(rep(0.1, 3), 4, "interpolate"),
    rep(0.1, 12)
  )

  hourly <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:2 * 3600,
    price = c(10, 20, 30)
  )
  quarter_hourly <- change_timeseries_resolution(
    hourly,
    resolution = 15,
    method = "interpolate"
  )
  expect_equal(nrow(quarter_hourly), 12)
  # Interior blocks interpolate towards the next value as before.
  expect_equal(quarter_hourly$price[1:8], c(10, 12.5, 15, 17.5, 20, 22.5, 25, 27.5))
  # The last block holds 30 rather than sliding 30, 22.5, 15, 7.5.
  expect_equal(quarter_hourly$price[9:12], rep(30, 4))
})

test_that("error when method is invalid", {
  dtf <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 900,
    load = c(10, 12, 14, 16)
  )

  expect_error(
    change_timeseries_resolution(
      dtf,
      resolution = 60,
      method = "invalid_method"
    )
  )
  expect_error(
    change_timeseries_resolution(
      dtf,
      resolution = 5,
      method = "invalid_method"
    )
  )
})
