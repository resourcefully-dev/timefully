# Adapt time-series dataframe to timezone, date range and fill gaps

This function adapts the date range of a time series by reusing
historical patterns based on the same weekday occurrence within the year
and decimal hour of the day. It also can fill gaps in the data based on
past data, so it is recommended to use it for time series with weekly or
yearly patterns (so for example energy demand but not solar generation).
It can also adapt the timezone of the time series, for example if the
data was stored in UTC but corresponds to a different timezone.

## Usage

``` r
adapt_timeseries(dtf, start_date, end_date, tzone = NULL, fill_gaps = FALSE)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- start_date:

  Date, start date of the output datetime sequence

- end_date:

  Date, end date of the output datetime sequence (included)

- tzone:

  character, desired time-zone of the datetime sequence. If NULL, the
  timezone of `dtf$datetime` is kept.

- fill_gaps:

  boolean, whether to fill gaps based on same weekday and hour from past
  data (See `fill_from_past` function).

## Value

tibble

## Examples

``` r
# Example data set
print(dtf)
#> # A tibble: 35,040 × 3
#>    datetime            solar building
#>    <dttm>              <dbl>    <dbl>
#>  1 2023-01-01 00:00:00     0    1.31 
#>  2 2023-01-01 00:15:00     0    1.21 
#>  3 2023-01-01 00:30:00     0    1.12 
#>  4 2023-01-01 00:45:00     0    1.02 
#>  5 2023-01-01 01:00:00     0    0.927
#>  6 2023-01-01 01:15:00     0    0.890
#>  7 2023-01-01 01:30:00     0    0.852
#>  8 2023-01-01 01:45:00     0    0.814
#>  9 2023-01-01 02:00:00     0    0.777
#> 10 2023-01-01 02:15:00     0    0.774
#> # ℹ 35,030 more rows

# Original date range
range(dtf$datetime)
#> [1] "2023-01-01 00:00:00 CET" "2023-12-31 23:45:00 CET"

dtf2 <- adapt_timeseries(
  dtf,
  start_date = as.Date("2021-01-01"),
  end_date = as.Date("2021-01-31"),
  tzone = "America/New_York",
  fill_gaps = FALSE
)

# New date range
range(dtf2$datetime)
#> [1] "2021-01-01 00:00:00 EST" "2021-01-31 23:45:00 EST"
```
