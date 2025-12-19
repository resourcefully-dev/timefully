# Check if there are any gaps in the datetime sequence

This means all rows a part from "datetime" will be NA. Note that
timefully considers a full datetime sequence when days are complete.

## Usage

``` r
check_timeseries_gaps(dtf)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

## Value

tibble

## Examples

``` r
# Sample just some hours
dtf_gaps <- dtf[c(1:3, 7:10), ]

# Note that the full day is provided
check_timeseries_gaps(
   dtf_gaps
)
#> Warning: There are gaps in the data.
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
