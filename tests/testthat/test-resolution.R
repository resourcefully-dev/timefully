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
    resolution_out = 60,
    method = "first"
  )

  expect_true(
    nrow(hourly) < nrow(fifteen_min)
  )

  hourly <- change_timeseries_resolution(
    fifteen_min,
    resolution_out = 60,
    method = "sum"
  )

  expect_true(
    nrow(hourly) < nrow(fifteen_min)
  )

  hourly <- change_timeseries_resolution(
    fifteen_min,
    resolution_out = 60,
    method = "average"
  )

  expect_equal(
    dtf,
    change_timeseries_resolution(dtf, resolution_out = 15)
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
    resolution_out = 5,
    method = "repeat"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

  higher_res <- change_timeseries_resolution(
    fifteen_min,
    resolution_out = 5,
    method = "interpolate"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

    higher_res <- change_timeseries_resolution(
    fifteen_min,
    resolution_out = 5,
    method = "divide"
  )

  expect_true(
    nrow(higher_res) > nrow(fifteen_min)
  )

})

test_that("error when method is invalid", {
  dtf <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 900,
    load = c(10, 12, 14, 16)
  )

  expect_error(
    change_timeseries_resolution(
      dtf,
      resolution_out = 60,
      method = "invalid_method"
    )
  )
  expect_error(
    change_timeseries_resolution(
      dtf,
      resolution_out = 5,
      method = "invalid_method"
    )
  )
})
