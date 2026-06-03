# timefully 0.1.0

* First release

# timefully 0.1.1

* Added `pad_timeseries()` to expand a time series onto the complete datetime
  sequence, inserting missing slots as `NA` rows and reporting the padded gaps
* Added `time_gaps()` and `has_timeseries_gaps()` helpers to inspect gaps in a
  datetime sequence or data frame
* Bug fix in `change_timeseries_tzone` function
