test_that("tictoc works", {
  tic()
  Sys.sleep(2)
  elapsed <- round(toc())
  expect_equal(elapsed, 2)
})
