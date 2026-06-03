# Pad a time series to a complete datetime sequence

Expands `dtf` onto the complete datetime sequence that spans the same
date range at the same resolution, inserting the missing time slots as
rows with `NA` values. Note that timefully considers a full datetime
sequence when days are complete.

## Usage

``` r
pad_timeseries(dtf, verbose = TRUE)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

- verbose:

  logical, when `TRUE` (default) report the number of rows added and the
  dates with gaps

## Value

tibble

## Examples

``` r
# Sample just some hours
dtf_gaps <- dtf[c(1:3, 7:10), ]

# Note that the full day is provided
pad_timeseries(
   dtf_gaps
)
#> ℹ Padded 89 missing slots across 1 date: "2023-01-01"
#> # A tibble: 96 × 3
#>    datetime            solar building
#>    <dttm>              <dbl>    <dbl>
#>  1 2023-01-01 00:00:00     0    1.31 
#>  2 2023-01-01 00:15:00     0    1.21 
#>  3 2023-01-01 00:30:00     0    1.12 
#>  4 2023-01-01 00:45:00    NA   NA    
#>  5 2023-01-01 01:00:00    NA   NA    
#>  6 2023-01-01 01:15:00    NA   NA    
#>  7 2023-01-01 01:30:00     0    0.852
#>  8 2023-01-01 01:45:00     0    0.814
#>  9 2023-01-01 02:00:00     0    0.777
#> 10 2023-01-01 02:15:00     0    0.774
#> # ℹ 86 more rows
```
