# Decimal hours from datetime

Converts a datetime vector into decimal hours (hour plus minutes / 60).
The input must not include seconds because sub-minute resolution would
make the decimal representation ambiguous for matching time slots.

## Usage

``` r
dhours(datetime)
```

## Arguments

- datetime:

  POSIXct vector.

## Value

Numeric vector with decimal hours.
