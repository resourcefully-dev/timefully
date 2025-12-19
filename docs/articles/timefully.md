# Get started with timefully

The goal of **timefully** is to make it straightforward to reshape,
re-timezone and visualise regularly spaced energy time series. This
tutorial walks through the core workflow using the package’s bundled
data frame
[`timefully::dtf`](https://resourcefully-dev.github.io/timefully/reference/dtf.md).

## Explore the sample data

`dtf` contains a full year of quarter-hour values recorded in the
**`Europe/Amsterdam` timezone during 2023**. We start by zooming into
one week so plots stay compact.

``` r

week_amsterdam <- timefully::dtf |>
  filter(datetime >= as.POSIXct("2023-06-01 00:00:00", tz = "Europe/Amsterdam"),
         datetime <  as.POSIXct("2023-06-08 00:00:00", tz = "Europe/Amsterdam"))

glimpse(week_amsterdam)
#> Rows: 672
#> Columns: 3
#> $ datetime <dttm> 2023-06-01 00:00:00, 2023-06-01 00:15:00, 2023-06-01 00:30:0…
#> $ solar    <dbl> 0.000000e+00, 0.000000e+00, 0.000000e+00, 0.000000e+00, 0.000…
#> $ building <dbl> 1.836046, 1.746280, 1.656513, 1.566747, 1.476981, 1.452224, 1…
```

The helper
[`plot_ts()`](https://resourcefully-dev.github.io/timefully/reference/plot_ts.md)
produces an interactive dygraph so we can inspect the raw values.

``` r

plot_ts(week_amsterdam, ylab = "kW", legend_show = "always",
        title = "Quarter-hour readings (Europe/Amsterdam)")
```

## Change the time resolution

To produce hourly averages we call
[`change_timeseries_resolution()`](https://resourcefully-dev.github.io/timefully/reference/change_timeseries_resolution.md)
with the desired resolution (in minutes) and the aggregation method. The
first column remains a datetime column and the numeric columns are
summarised accordingly.

``` r

week_hourly <- change_timeseries_resolution(
  week_amsterdam,
  resolution = 60,
  method = "average"
)

plot_ts(week_hourly, ylab = "kW", legend_show = "always",
        title = "Hourly averages")
```

## Convert to a different timezone

If the data should be reported in another timezone, but keeping the same
date range, we can use function
[`change_timeseries_tzone()`](https://resourcefully-dev.github.io/timefully/reference/change_timeseries_tzone.md):

``` r

week_paris <- change_timeseries_tzone(week_amsterdam, tzone = "America/Los_Angeles")

tz(week_amsterdam$datetime[1])
#> [1] "Europe/Amsterdam"
tz(week_paris$datetime[1])
#> [1] "America/Los_Angeles"

plot_ts(week_paris, ylab = "kW", legend_show = "always")
```

Note that the data points are moved in time to reflect the new timezone,
so the daily patterns shift accordingly. This is used to preserve the
local time context of the data. If you want to keep the same clock times
but just change the timezone label, use
[`lubridate::force_tz()`](https://lubridate.tidyverse.org/reference/force_tz.html)
instead.

## Adapt to a new date range

Finally,
[`adapt_timeseries()`](https://resourcefully-dev.github.io/timefully/reference/adapt_timeseries.md)
lets us change both the date range and the timezone in one step. Here we
request ten days of Paris time starting on 1 June 2025. The function
fills any missing slots using the most recent data with the same weekday
and time of day, falling back to
[`fill_from_past()`](https://resourcefully-dev.github.io/timefully/reference/fill_from_past.md)
when necessary.

``` r

adapted_paris <- adapt_timeseries(
  timefully::dtf,
  start_date = as.Date("2025-06-01"),
  end_date = as.Date("2025-06-10"),
  tzone = "Europe/Paris",
  fill_gaps = TRUE
)

plot_ts(adapted_paris, ylab = "kW", legend_show = "always",
        title = "Adapted time series (1–10 June 2025)")
```

These building blocks can be combined with the rest of the package to
prepare clean, timezone-aware time series ready for analysis or
reporting.
