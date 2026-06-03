# Find the missing time slots in a datetime sequence

Builds the complete datetime sequence that would span the same date
range (full days) at the same resolution as `dttm_seq` and returns the
datetime values that are missing from it. Note that timefully considers
a full datetime sequence when days are complete.

## Usage

``` r
time_gaps(dttm_seq)
```

## Arguments

- dttm_seq:

  datetime sequence

## Value

vector of datetime values missing from `dttm_seq`

## Examples

``` r
seq_15m <- get_datetime_seq(
  start_date = as.Date("2024-01-01"),
  end_date = as.Date("2024-01-01"),
  tzone = "UTC",
  resolution = 15
)

# Drop a couple of slots to create gaps
time_gaps(seq_15m[-c(5, 6)])
#> [1] "2024-01-01 01:00:00 UTC" "2024-01-01 01:15:00 UTC"
```
