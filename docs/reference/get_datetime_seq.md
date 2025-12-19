# Date time sequence with time zone and resolution

Date time sequence with time zone and resolution

## Usage

``` r
get_datetime_seq(start_date, end_date, tzone, resolution)
```

## Arguments

- start_date:

  Date, start date of the output datetime sequence

- end_date:

  Date, end date of the output datetime sequence (included)

- tzone:

  character, desired time-zone of the datetime sequence

- resolution:

  integer, interval of minutes between two consecutive datetime values

## Value

vector of datetime values

## Examples

``` r
get_datetime_seq(
  start_date = as.Date("2024-01-01"),
  end_date = as.Date("2024-01-03"),
  tzone = "UTC",
  resolution = 120
)
#>  [1] "2024-01-01 00:00:00 UTC" "2024-01-01 02:00:00 UTC"
#>  [3] "2024-01-01 04:00:00 UTC" "2024-01-01 06:00:00 UTC"
#>  [5] "2024-01-01 08:00:00 UTC" "2024-01-01 10:00:00 UTC"
#>  [7] "2024-01-01 12:00:00 UTC" "2024-01-01 14:00:00 UTC"
#>  [9] "2024-01-01 16:00:00 UTC" "2024-01-01 18:00:00 UTC"
#> [11] "2024-01-01 20:00:00 UTC" "2024-01-01 22:00:00 UTC"
#> [13] "2024-01-02 00:00:00 UTC" "2024-01-02 02:00:00 UTC"
#> [15] "2024-01-02 04:00:00 UTC" "2024-01-02 06:00:00 UTC"
#> [17] "2024-01-02 08:00:00 UTC" "2024-01-02 10:00:00 UTC"
#> [19] "2024-01-02 12:00:00 UTC" "2024-01-02 14:00:00 UTC"
#> [21] "2024-01-02 16:00:00 UTC" "2024-01-02 18:00:00 UTC"
#> [23] "2024-01-02 20:00:00 UTC" "2024-01-02 22:00:00 UTC"
#> [25] "2024-01-03 00:00:00 UTC" "2024-01-03 02:00:00 UTC"
#> [27] "2024-01-03 04:00:00 UTC" "2024-01-03 06:00:00 UTC"
#> [29] "2024-01-03 08:00:00 UTC" "2024-01-03 10:00:00 UTC"
#> [31] "2024-01-03 12:00:00 UTC" "2024-01-03 14:00:00 UTC"
#> [33] "2024-01-03 16:00:00 UTC" "2024-01-03 18:00:00 UTC"
#> [35] "2024-01-03 20:00:00 UTC" "2024-01-03 22:00:00 UTC"
```
