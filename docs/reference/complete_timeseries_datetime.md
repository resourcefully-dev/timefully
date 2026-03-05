# Fill NA values of a datetime sequence vector

Fill NA values of a datetime sequence vector

## Usage

``` r
complete_timeseries_datetime(dtf)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

## Value

tibble

## Examples

``` r
dtf_gaps <- timefully::dtf[c(1, 2, 3, 8, 9, 10), ]
print(dtf_gaps)
#> # A tibble: 6 × 3
#>   datetime            solar building
#>   <dttm>              <dbl>    <dbl>
#> 1 2023-01-01 00:00:00     0    1.31 
#> 2 2023-01-01 00:15:00     0    1.21 
#> 3 2023-01-01 00:30:00     0    1.12 
#> 4 2023-01-01 01:45:00     0    0.814
#> 5 2023-01-01 02:00:00     0    0.777
#> 6 2023-01-01 02:15:00     0    0.774
complete_timeseries_datetime(dtf_gaps)
#> Added 90 rows to the data frame to fill in missing timestamps.
#> # A tibble: 96 × 3
#>    datetime            solar building
#>    <dttm>              <dbl>    <dbl>
#>  1 2023-01-01 00:00:00     0    1.31 
#>  2 2023-01-01 00:15:00     0    1.21 
#>  3 2023-01-01 00:30:00     0    1.12 
#>  4 2023-01-01 00:45:00    NA   NA    
#>  5 2023-01-01 01:00:00    NA   NA    
#>  6 2023-01-01 01:15:00    NA   NA    
#>  7 2023-01-01 01:30:00    NA   NA    
#>  8 2023-01-01 01:45:00     0    0.814
#>  9 2023-01-01 02:00:00     0    0.777
#> 10 2023-01-01 02:15:00     0    0.774
#> # ℹ 86 more rows
```
