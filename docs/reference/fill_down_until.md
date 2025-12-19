# Fill down tibble columns until a maximum number of time slots

Fill down tibble columns until a maximum number of time slots

## Usage

``` r
fill_down_until(dtf, varnames, max_timeslots = 1)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- varnames:

  character or vector of characters, column names with NA values

- max_timeslots:

  integer, maximum number of time slots to fill

## Value

tibble

## Examples

``` r
down_data <- data.frame(
  datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:5 * 3600,
  temperature = c(15, 15, NA, NA, NA, 16)
)
fill_down_until(down_data, "temperature", max_timeslots = 2)
#>              datetime temperature
#> 1 2024-01-01 00:00:00          15
#> 2 2024-01-01 01:00:00          15
#> 3 2024-01-01 02:00:00          15
#> 4 2024-01-01 03:00:00          15
#> 5 2024-01-01 04:00:00          NA
#> 6 2024-01-01 05:00:00          16
```
