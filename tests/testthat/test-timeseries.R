test_that("get_datetime_seq returns requested period", {

  seq_hourly <- get_yearly_datetime_seq(
    year = 2025,
    tzone = "UTC",
    resolution = 60
  )
  expect_equal(length(seq_hourly), 8760)

  seq_hourly <- get_datetime_seq(
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-01-01"),
    tzone = "UTC",
    resolution = 60
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

test_that("change_timeseries_tzone changes timezone and keeps year", {
  base_seq <- get_yearly_datetime_seq(
    year = 2024,
    tzone = "UTC",
    resolution = 15
  )
  energy_profile <- data.frame(
    datetime = base_seq,
    demand = rep(c(1.2, 1.4, 1.5, 1.6), length.out = length(base_seq))
  )

  adapted <- change_timeseries_tzone(energy_profile, tzone = "Europe/Paris")

  expect_equal(nrow(adapted), nrow(energy_profile))
  expect_equal(lubridate::tz(adapted$datetime), "Europe/Paris")
  expect_equal(
    unique(lubridate::year(adapted$datetime)),
    unique(lubridate::year(energy_profile$datetime))
  )
})

test_that("adapt_timeseries adjusts timezone for the same date time sequence", {

  adapted <- change_timeseries_tzone(dtf, tzone = "America/Los_Angeles")
  expect_equal(lubridate::tz(adapted$datetime), "America/Los_Angeles")
  expect_equal(
    lubridate::date(range(dtf$datetime)),
    lubridate::date(range(adapted$datetime))
  )

})

test_that("adapt_timeseries adjusts timezone and year", {
  adapted <- adapt_timeseries(
    timefully::dtf,
    start_date = as.Date("2025-01-01"),
    end_date = as.Date("2025-12-31"),
    tzone = "Europe/Paris"
  )
  # adapted |>
  #   dplyr::filter(is.na(solar))

  expect_equal(nrow(adapted), nrow(timefully::dtf))
  expect_equal(lubridate::tz(adapted$datetime), "Europe/Paris")
  expect_false(anyNA(adapted$solar))
})

test_that("adapt_timeseries adjusts timezone and fills gaps", {
  adapted <- adapt_timeseries(
    timefully::dtf,
    start_date = as.Date("2024-01-01"),
    end_date = as.Date("2024-12-31"),
    tzone = "Europe/Paris",
    fill_gaps = TRUE
  )
  # adapted |>
  #   dplyr::filter(is.na(solar))

  expect_equal(nrow(adapted), nrow(timefully::dtf)+96) # leap year
  expect_equal(lubridate::tz(adapted$datetime), "Europe/Paris")
  expect_false(anyNA(adapted$solar))
})


test_that("adapt_timeseries adjusts date range with gaps", {
  dtf_example <- timefully::dtf |> dplyr::filter(
      lubridate::month(datetime) == 4
    )

    adapted <- adapt_timeseries(
      dtf_example,
      start_date = as.Date("2025-04-01"),
      end_date = as.Date("2025-04-30"),
      tzone = "Europe/Paris",
      fill_gaps = FALSE
    )
    adapted |>
      dplyr::filter(is.na(solar))

  expect_warning(
    adapted <- adapt_timeseries(
      dtf_example,
      start_date = as.Date("2025-04-15"),
      end_date = as.Date("2025-05-15"),
      tzone = "Europe/Paris",
      fill_gaps = FALSE
    )
  )
})
