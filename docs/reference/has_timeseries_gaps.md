# Check whether a time series dataframe has gaps

Note that timefully considers a full datetime sequence when days are
complete.

## Usage

``` r
has_timeseries_gaps(dtf)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

## Value

logical, `TRUE` when there are missing time slots

## Examples

``` r
has_timeseries_gaps(dtf)
#> [1] FALSE

dtf_gaps <- dtf[c(1:3, 7:10), ]
has_timeseries_gaps(dtf_gaps)
#> [1] TRUE
```
