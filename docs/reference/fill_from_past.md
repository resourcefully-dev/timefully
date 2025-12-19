# Fill from past values

If back index ( NA index - `back`) is lower than zero then the it is
filled with the first value of the data frame. If the value in the back
index is also NA, it iterates backwards until finding a non-NA value.

## Usage

``` r
fill_from_past(dtf, varnames, back = 24)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- varnames:

  character or vector of characters, column names with NA values

- back:

  integer, number of indices (rows) to go back and get the filling value

## Value

tibble or data.frame

## Examples

``` r
past_data <- data.frame(
  datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
  consumption = c(1.2, NA, NA, 2.5)
)
fill_from_past(past_data, "consumption", back = 1)
#>              datetime consumption
#> 1 2024-01-01 00:00:00         1.2
#> 2 2024-01-01 01:00:00         1.2
#> 3 2024-01-01 02:00:00         1.2
#> 4 2024-01-01 03:00:00         2.5
```
