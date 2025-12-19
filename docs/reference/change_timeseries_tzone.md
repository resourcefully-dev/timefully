# Adapt the timezone of a time series dataframe

The timezone of the `datetime` column is changed while keeping the same
date time sequence. This is useful when the time series data is known to
be in a different timezone. If you just want the same time series in a
different timezone, use
[`lubridate::force_tz`](https://lubridate.tidyverse.org/reference/force_tz.html)
function instead.

## Usage

``` r
change_timeseries_tzone(dtf, tzone = "Europe/Amsterdam")
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- tzone:

  character, desired time-zone of the datetime sequence

## Value

tibble

## Examples

``` r
# Example data set
get_timeseries_tzone(dtf)
#> [1] "Europe/Amsterdam"
range(dtf$datetime)
#> [1] "2023-01-01 00:00:00 CET" "2023-12-31 23:45:00 CET"

#  Change timezone
new_dtf <- change_timeseries_tzone(dtf, tzone = "Europe/Paris")
get_timeseries_tzone(new_dtf)
#> [1] "Europe/Paris"
range(new_dtf$datetime)
#> [1] "2023-01-01 00:00:00 CET" "2023-12-31 23:45:00 CET"
```
