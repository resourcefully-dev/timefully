# Fill gaps with a specific value

This is useful when the gaps in a numeric timeseries can be filled with
the same number (e.g. zero)

## Usage

``` r
fill_na(dtf, varnames, with = 0)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- varnames:

  character or vector of characters, column names with NA values

- with:

  numeric, value to fill NA values

## Value

tibble or data.frame

## Examples

``` r
past_data <- data.frame(
  datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
  consumption = c(1.2, NA, NA, 2.5)
)
fill_na(past_data, "consumption", with = 0)
#>              datetime consumption
#> 1 2024-01-01 00:00:00         1.2
#> 2 2024-01-01 01:00:00         0.0
#> 3 2024-01-01 02:00:00         0.0
#> 4 2024-01-01 03:00:00         2.5
```
