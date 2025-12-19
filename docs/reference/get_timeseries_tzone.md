# Get the time zone of a time series dataframe

Get the time zone of a time series dataframe

## Usage

``` r
get_timeseries_tzone(dtf)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

## Value

character

## Examples

``` r
get_timeseries_tzone(dtf)
#> [1] "Europe/Amsterdam"
```
