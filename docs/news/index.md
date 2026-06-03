# Changelog

## timefully 0.1.0

CRAN release: 2025-12-10

- First release

## timefully 0.1.1

- Added
  [`pad_timeseries()`](https://resourcefully-dev.github.io/timefully/reference/pad_timeseries.md)
  to expand a time series onto the complete datetime sequence, inserting
  missing slots as `NA` rows and reporting the padded gaps
- Added
  [`time_gaps()`](https://resourcefully-dev.github.io/timefully/reference/time_gaps.md)
  and
  [`has_timeseries_gaps()`](https://resourcefully-dev.github.io/timefully/reference/has_timeseries_gaps.md)
  helpers to inspect gaps in a datetime sequence or data frame
- Bug fix in `change_timeseries_tzone` function
