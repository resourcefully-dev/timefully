# Convert numeric time value to a datetime period (hour-based)

Convert numeric time value to a datetime period (hour-based)

## Usage

``` r
convert_time_num_to_period(time_num)
```

## Arguments

- time_num:

  Numeric time value (hour-based)

## Value

[`lubridate::period`](https://lubridate.tidyverse.org/reference/period.html)
vector with hours and minutes corresponding to the numeric input.

## Examples

``` r
convert_time_num_to_period(1.5)
#> [1] "1H 30M 0S"
convert_time_num_to_period(c(0.25, 2))
#> [1] "15M 0S"   "2H 0M 0S"
```
