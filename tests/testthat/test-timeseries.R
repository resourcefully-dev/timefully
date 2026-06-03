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
    building2 = c(1, 1, 2, 1),
    solar = c(0, 0, 1, 2)
  )

  aggregated <- aggregate_timeseries(energy, varname = "total", omit = "solar")

  expect_equal(
    aggregated$total,
    rowSums(energy[c("building1", "building2")])
  )
  expect_equal(colnames(aggregated), c("datetime", "total", "solar"))
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
  dtf_example <- timefully::dtf
  dtf_example$building[c(100, 250, 534, 785)] <- rep(NA, 4)  # remove random timeslots
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

test_that("test add_extra_days works", {
  dtf_example <- timefully::dtf |> dplyr::filter(
    lubridate::month(datetime) == 2
  )

  extended <- add_extra_days(
    dtf_example
  )

  expect_equal(
    nrow(extended),
    nrow(dtf_example) + 48*60/15 # 2 extra days
  )
  expect_equal(
    lubridate::date(range(extended$datetime)),
    c(as.Date("2023-01-31"), as.Date("2023-03-01"))
  )
})

test_that("pad_timeseries pads gaps to a full sequence and reports them", {
  dtf_gaps <- dtf[c(1, 2, 3, 8, 9, 10), ]

  expect_message(
    padded <- pad_timeseries(dtf_gaps)
  )
  # Padded to a full day-aligned sequence (15-min resolution -> 96 slots)
  expect_equal(nrow(padded), 96)
  expect_false(has_timeseries_gaps(padded))

  # verbose = FALSE stays silent
  expect_no_message(
    pad_timeseries(dtf_gaps, verbose = FALSE)
  )
})

test_that("time_gaps returns the missing slots", {
  seq_15m <- get_datetime_seq(
    as.Date("2024-01-01"), as.Date("2024-01-01"), "UTC", 15
  )

  # No gaps in a complete sequence
  expect_length(time_gaps(seq_15m), 0)

  # Dropping two slots returns exactly those slots
  expect_equal(time_gaps(seq_15m[-c(5, 6)]), seq_15m[c(5, 6)])
})

test_that("has_timeseries_gaps returns TRUE/FALSE", {
  expect_false(has_timeseries_gaps(dtf))
  expect_true(has_timeseries_gaps(dtf[c(1:3, 7:10), ]))
})