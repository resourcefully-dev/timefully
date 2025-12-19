# Increase time resolution of a timeseries data frame

Increase time resolution of a timeseries data frame

## Usage

``` r
increase_timeseries_resolution(
  dtf,
  resolution,
  method = c("interpolate", "repeat", "divide")
)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- resolution:

  integer, interval of minutes between two consecutive datetime values

- method:

  character, being `interpolate`, `repeat` or `divide` as valid options.
  See `increase_numeric_resolution` function for more information.

## Value

tibble
