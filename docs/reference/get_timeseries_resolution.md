# Return the time resolution of a time series dataframe

Return the time resolution of a time series dataframe

## Usage

``` r
get_timeseries_resolution(dtf, units = "mins")
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- units:

  character being one of "auto", "secs", "mins", "hours", "days" and
  "weeks"

## Value

numeric

## Examples

``` r
get_timeseries_resolution(dtf, units = "mins")
#> [1] 15
```
