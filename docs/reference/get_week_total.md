# Summarise dataframe with weekly total column values

Converts the numeric columns of a time-series data frame to total values
per week (sum). Note that if the input values are in power units (e.g.,
kW), the output values will be in energy units (e.g., kWh).

## Usage

``` r
get_week_total(dtf)
```

## Arguments

- dtf:

  data.frame or tibble, first column of name `datetime` being of class
  datetime and rest of columns being numeric

## Value

tibble

## Examples

``` r
get_week_total(dtf[1:100, ])
#> # A tibble: 2 × 3
#>   week       solar building
#>   <date>     <dbl>    <dbl>
#> 1 2023-01-02  0        1.63
#> 2 2023-12-25  5.33    36.3 
```
