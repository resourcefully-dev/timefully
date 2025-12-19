# Change time resolution of a time-series data frame

Change time resolution of a time-series data frame

## Usage

``` r
change_timeseries_resolution(dtf, resolution, method)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- resolution:

  integer, desired interval of minutes between two consecutive datetime
  values

- method:

  character, being `interpolate`, `repeat` or `divide` if the resolution
  has to be increased, or `average`, `first` or `sum` if the resolution
  has to be decreased. See Examples for more information.

## Value

tibble

## Examples

``` r
fifteen_min <- data.frame(
  datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:7 * 900,
  load = c(10, 12, 14, 16, 14, 12, 10, 8)
)
change_timeseries_resolution(
  fifteen_min,
  resolution = 60,
  method = "average"
)
#> # A tibble: 2 × 2
#>   datetime             load
#>   <dttm>              <dbl>
#> 1 2024-01-01 00:00:00    13
#> 2 2024-01-01 01:00:00    11


```
