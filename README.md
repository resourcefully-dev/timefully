
# timefully

<!-- badges: start -->
<!-- badges: end -->

The goal of timefully is to facilitate the management of time-series data frames to adapt the timezone, time resolution, and date range.

## Installation

You can install the development version of timefully like so:

``` r
pak::pak("resourcefully-dev/timefully")
```

## Getting started

If you have a time-series data frame like the following one:

```r
library(timefully)

# Example data set
print(dtf)

# Original date range
range(dtf$datetime)
```

You can adapt the original data to the desired time range:

```r
# Timeseries adapted to January 2021
dtf2 <- adapt_timeseries(
    dtf, 
    start_date = as.Date("2021-01-01"), 
    end_date = as.Date("2021-01-31"),
    tzone = "America/New_York", 
    fill_gaps = FALSE
)

# New date range
range(dtf2$datetime)
```

Or change time resolution:

```r
change_timeseries_resolution(
    dtf, resolution_out = 60, method = "average"
)
```


