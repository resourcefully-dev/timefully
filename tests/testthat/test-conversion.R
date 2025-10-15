

test_that("number is converted to period", {
  expect_equal(
    convert_time_num_to_period(15),
    lubridate::period(15, "hours")
  )
})

