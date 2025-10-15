test_that("timeseries is adapted", {

  # Timeseries adapted to January 2021
  dtf2 <- adapt_timeseries(
    dtf, 
    start_date = as.Date("2021-01-01"), 
    end_date = as.Date("2021-01-31"),
    tzone = "America/New_York", 
    fill_gaps = FALSE
  )

  expect_true(
    lubridate::year(dtf2$datetime[1]) == 2021 &
      lubridate::month(dtf2$datetime[1]) == 1 &
      lubridate::day(dtf2$datetime[1]) == 1
  )
  
})
