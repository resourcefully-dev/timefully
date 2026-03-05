# Format datetime axis

Format datetime axis

## Usage

``` r
format_datetime_axis(format_list, locale = "nl-NL")
```

## Arguments

- format_list:

  (named list) ORDER matters key and type of output as value

- locale:

  (str) locale to use in settings for example nl-NL (default)

## Value

js code as a string to change datetime axis

JS function to pass to dyAxis function

## Details

The `format_list` entries map to the JavaScript `toLocaleString`
options:

|         |           |                                  |                 |
|---------|-----------|----------------------------------|-----------------|
| Option  | Value     | Description                      | Example (nl-NL) |
| year    | "numeric" | Full year                        | "2023"          |
| year    | "2-digit" | Last two digits of the year      | "23"            |
| month   | "numeric" | Month as a number                | "1"             |
| month   | "2-digit" | Month as a two-digit number      | "01"            |
| month   | "long"    | Full month name                  | "januari"       |
| month   | "short"   | Abbreviated month name           | "jan."          |
| day     | "numeric" | Day of the month                 | "5"             |
| day     | "2-digit" | Day with leading zero            | "05"            |
| weekday | "long"    | Full weekday name                | "vrijdag"       |
| weekday | "short"   | Abbreviated weekday name         | "vr."           |
| weekday | "narrow"  | Single-letter weekday            | "V"             |
| hour    | "numeric" | Hour (24-hour format by default) | "14"            |
| hour    | "2-digit" | Two-digit hour                   | "14"            |
| minute  | "numeric" | Minute                           | "30"            |
| minute  | "2-digit" | Two-digit minute                 | "30"            |
| second  | "numeric" | Second                           | "15"            |
| second  | "2-digit" | Two-digit second                 | "15"            |

## Examples

``` r
if (FALSE) { # \dontrun{

 dyplot <- plot_ts(dtf)
 xaxis_format <- format_date_axis(
   list(day = "2-digit", month = "short"),
   locale = "nl_NL"
 )
 dyplot |>
   dyAxis("x", axisLabelFormatter = JS(xaxis_format))

} # }
```
