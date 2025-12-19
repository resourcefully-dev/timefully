# Year-weekday occurrence identifier

Computes a stable index for each datetime by combining the weekday
(Monday = 1) with how many times that weekday has already occurred in
the year. The result can be used to align data such as "third Monday"
across different calendar years without depending on ISO week numbers.

## Usage

``` r
ywday(datetime)
```

## Arguments

- datetime:

  POSIXct vector.

## Value

Integer vector; for example, `402` denotes the second Thursday.
