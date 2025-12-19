# Week date from datetime value

Week date from datetime value

## Usage

``` r
get_week_from_datetime(dttm)
```

## Arguments

- dttm:

  datetime vector

## Value

date vector

## Examples

``` r
dttm <- as.POSIXct(
  c("2024-01-01 08:00:00", "2024-01-02 09:00:00", "2024-01-08 10:00:00"),
  tz = "UTC"
)
get_week_from_datetime(dttm)
#> [1] "2024-01-01" "2024-01-01" "2024-01-08"
```
