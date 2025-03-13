
<!-- README.md is generated from README.Rmd. Please edit that file -->

# saekir

<!-- badges: start -->
<!-- badges: end -->

The goal of saekir is to …

## Installation

You can install the development version of saekir like so:

``` r
# FILL THIS IN! HOW CAN PEOPLE INSTALL YOUR DEV PACKAGE?
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(saekir)

# Create a valid sample dataset
valid_data <- dplyr::tibble(
  student_id = c("1", "2", "3", "2", "2", "2"),
  item_id = c(1, 2, 3, 1, 2, 3),
  response = list("A", c("A", "B"), "",
                  "B", c("A", "B"), "Long answer text"),
  response_status = factor(
    c("correct", "incorrect", "skipped",
      "incorrect", "incorrect", "correct"),
    levels = c("skipped", "correct", "incorrect")
  ),
  score = c(1, 0, 0,0, 0, 2),
  response_time = c(30, 45, 0,32, 41, 60),
  timestamp = as.POSIXct(
    c(
      "2025-03-12 14:35:00",
      "2025-03-12 14:40:00",
      "2025-03-12 14:45:00",
            "2025-03-12 14:35:00",
      "2025-03-12 14:40:00",
      "2025-03-12 14:45:00"
    )
  )
)


valid_data
#> # A tibble: 6 × 7
#>   student_id item_id response  response_status score response_time
#>   <chr>        <dbl> <list>    <fct>           <dbl>         <dbl>
#> 1 1                1 <chr [1]> correct             1            30
#> 2 2                2 <chr [2]> incorrect           0            45
#> 3 3                3 <chr [1]> skipped             0             0
#> 4 2                1 <chr [1]> incorrect           0            32
#> 5 2                2 <chr [2]> incorrect           0            41
#> 6 2                3 <chr [1]> correct             2            60
#> # ℹ 1 more variable: timestamp <dttm>
validate_student_responses(valid_data)
#> Validation passed: `student_responses` is correctly formatted.
```
