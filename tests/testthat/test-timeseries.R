test_that("get_datetime_seq returns requested period", {
  seq_hourly <- get_datetime_seq(
    year = 2024,
    tzone = "UTC",
    resolution_mins = 60,
    fullyear = FALSE,
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-01-02")
  )

  expect_equal(length(seq_hourly), 24)
  expect_equal(lubridate::tz(seq_hourly), "UTC")
})

test_that("aggregate_timeseries sums numeric columns", {
  energy <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
    building1 = c(2, 3, 4, 3),
    building2 = c(1, 1, 2, 1)
  )

  aggregated <- aggregate_timeseries(energy, varname = "total")

  expect_equal(
    aggregated$total,
    rowSums(energy[c("building1", "building2")])
  )
  expect_equal(colnames(aggregated), c("datetime", "total"))
})

test_that("adapt_timeseries adjusts timezone and fills gaps", {
  base_seq <- as.POSIXct("2024-01-01 00:00:00", tz = "Europe/Paris") + 0:23 * 3600
  energy_profile <- data.frame(
    datetime = base_seq,
    demand = rep(c(1.2, 1.4, NA, 1.6), length.out = length(base_seq))
  )

  adapted <- adapt_timeseries(
    energy_profile,
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-01-02"),
    tzone = "Europe/Paris",
    fill_gaps = TRUE
  )

  expect_equal(nrow(adapted), 24)
  expect_equal(lubridate::tz(adapted$datetime), "Europe/Paris")
  expect_false(anyNA(adapted$demand))
})
