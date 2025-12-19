# Aggregate multiple timeseries columns to a single one

The first column `datetime` will be kept.

## Usage

``` r
aggregate_timeseries(dtf, varname, omit = NULL)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- varname:

  character, name of the aggregation column

- omit:

  character, name of columns to not aggregate

## Value

tibble

## Examples

``` r
building_flows <- data.frame(
  datetime = as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:3 * 3600,
  building1 = c(2.1, 2.5, 2.3, 2.0),
  building2 = c(1.0, 1.1, 0.9, 1.2)
)
aggregate_timeseries(building_flows, varname = "total_building")
#>              datetime total_building
#> 1 2024-01-01 00:00:00            3.1
#> 2 2024-01-01 01:00:00            3.6
#> 3 2024-01-01 02:00:00            3.2
#> 4 2024-01-01 03:00:00            3.2
```
