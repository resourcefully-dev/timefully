# Convert date or datetime value to timestamp number

Convert date or datetime value to timestamp number

## Usage

``` r
date_to_timestamp(date, tzone = "Europe/Paris", milliseconds = TRUE)
```

## Arguments

- date:

  date or datetime value

- tzone:

  character, time-zone of the current time

- milliseconds:

  logical, whether the timestamp is in milliseconds or seconds

## Value

numeric

## Examples

``` r
date_to_timestamp(as.Date("2024-01-01"))
#> [1] 1.704064e+12
date_to_timestamp(as.POSIXct("2024-01-01 08:00:00", tz = "UTC"), milliseconds = FALSE)
#> [1] 1704092400
```
