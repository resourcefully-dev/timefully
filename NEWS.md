# timefully 0.1.0

* First release

# timefully 0.1.1

* Added `pad_timeseries()` to expand a time series onto the complete datetime
  sequence, inserting missing slots as `NA` rows and reporting the padded gaps
* Added `time_gaps()` and `has_timeseries_gaps()` helpers to inspect gaps in a
  datetime sequence or data frame
* Bug fix in `change_timeseries_tzone` function

# timefully 0.1.2

* Bug fix in `change_timeseries_resolution(method = "interpolate")`: the last
  value now holds through its block instead of interpolating towards 0, so an
  upsampled series no longer ends with a ramp to zero
