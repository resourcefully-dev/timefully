

test_that("number is converted to period", {
  expect_equal(
    convert_time_num_to_period(15),
    lubridate::period(15, "hours")
  )
})

test_that("date is converted to timestamp", {
  expect_true(
    is.numeric(date_to_timestamp(Sys.Date()))
  )
  expect_true(
    is.numeric(date_to_timestamp(Sys.Date(), milliseconds = TRUE))
  )
  sample_time <- as.POSIXct("2024-01-01 08:00:00", tz = "UTC")
  expect_equal(
    date_to_timestamp(sample_time),
    date_to_timestamp(sample_time, milliseconds = FALSE) * 1000
  )
})

test_that("week is retrieved from datetime vector", {
  dttm <- as.POSIXct(
    c("2024-01-01 08:00:00", "2024-01-05 09:00:00", "2024-01-08 10:00:00"),
    tz = "UTC"
  )
  weeks <- get_week_from_datetime(dttm)
  expect_s3_class(weeks, "Date")
  expect_equal(
    weeks,
    as.Date(c("2024-01-01", "2024-01-01", "2024-01-08"))
  )
})

test_that("weekly totals are aggregated correctly", {
  hourly_data <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:5 * 3600,
    consumption = c(2, 3, 4, 3, 2, 2),
    generation = c(1, 0, 1, 0, 1, 0)
  )

  totals <- get_week_total(hourly_data)

  expect_equal(
    as.data.frame(totals),
    data.frame(
      week = as.Date("2024-01-01"),
      consumption = sum(hourly_data$consumption),
      generation = sum(hourly_data$generation),
      check.names = FALSE
    )
  )
})

test_that("minutes are converted to string", {
  expect_equal(
    to_hhmm(75), "01:15"
  )

  expect_error(
    to_hhmm(5000)
  )
})
