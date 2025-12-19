# Fill NA values of a datetime sequence vector

Fill NA values of a datetime sequence vector

## Usage

``` r
fill_datetime(dttm)
```

## Arguments

- dttm:

  datetime sequence vector

## Value

filled datetime sequence vector

## Examples

``` r
incomplete_seq <- as.POSIXct("2024-01-01 00:00:00", tz = "UTC") + 0:4 * 3600
incomplete_seq[c(2, 3)] <- NA
fill_datetime(incomplete_seq)
#> [1] "2024-01-01 00:00:00 UTC" "2024-01-01 01:00:00 UTC"
#> [3] "2024-01-01 02:00:00 UTC" "2024-01-01 03:00:00 UTC"
#> [5] "2024-01-01 04:00:00 UTC"
```
