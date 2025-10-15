test_that("multiplication works", {
  dtf2 <-  change_timeseries_resolution(
    dtf, resolution_out = 60, method = "average"
  )
  expect_true(
    nrow(dtf) > nrow(dtf2)
  )
})
