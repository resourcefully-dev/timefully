test_that("fill_from_past backfills missing values", {
  fill_input <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
    consumption = c(1.0, NA, NA, 4.0)
  )

  filled <- fill_from_past(fill_input, "consumption", back = 1)

  expect_equal(
    filled$consumption,
    c(1.0, 1.0, 1.0, 4.0)
  )
})

test_that("fill_down_until limits fills to max timeslots", {
  down_input <- data.frame(
    datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:5 * 3600,
    temperature = c(15, 15, NA, NA, NA, 16)
  )

  filled <- fill_down_until(down_input, "temperature", max_timeslots = 2)

  expect_equal(filled$temperature[3:4], c(15, 15))
  expect_true(is.na(filled$temperature[5]))
})

test_that("fill_datetime reconstructs missing timestamps", {
  seq_input <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:4 * 3600
  seq_input[c(3, 4)] <- NA

  filled <- fill_datetime(seq_input)

  expect_equal(
    filled,
    as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:4 * 3600
  )
})
