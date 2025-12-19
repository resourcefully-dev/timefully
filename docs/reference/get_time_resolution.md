# Return the time resolution of a datetime sequence

Return the time resolution of a datetime sequence

## Usage

``` r
get_time_resolution(dttm_seq, units = "mins")
```

## Arguments

- dttm_seq:

  datetime sequence

- units:

  character being one of "auto", "secs", "mins", "hours", "days" and
  "weeks"

## Value

numeric

## Examples

``` r
seq_15m <- as.POSIXct(
  c("2024-01-01 00:00:00", "2024-01-01 00:15:00", "2024-01-01 00:30:00"),
  tz = "UTC"
)
get_time_resolution(seq_15m, units = "mins")
#> [1] 15
```
