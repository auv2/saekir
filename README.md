
<!-- README.md is generated from README.Rmd. Please edit that file -->

# saekir

<!-- badges: start -->
<!-- badges: end -->

The goal of saekir is to fetch student responses from various test
delivery systems and return them in a standardized format.

## Installation

You can install the development version of saekir from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("auv2/saekir")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(saekir)
students_responses <- read_TAO_responses("data/TAO_test_data.csv")

dplyr::glimpse(students_responses)
#> Rows: 57
#> Columns: 8
#> $ student_id      <chr> "Sigrun_MMS", "gervinemandi_bergmann_4", "gervinemandi…
#> $ item_id         <dbl> 1, 1, 1, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, …
#> $ response        <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, "c…
#> $ response_status <fct> seen, seen, seen, seen, seen, seen, seen, seen, seen, …
#> $ score           <dbl> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, 0, 0, …
#> $ response_time   <dbl> 6, 70, 123, 1, 113, 0, 1, 46, 0, 2, 7, 0, 1, 225, 228,…
#> $ start_time      <dttm> 2025-03-03 14:10:56, 2025-03-03 20:29:14, 2025-03-05 …
#> $ end_time        <dttm> 2025-03-10 10:54:16, 2025-03-03 20:40:10, 2025-03-05 …
```

``` r
get_item_matrix(students_responses)
#> # A tibble: 3 × 14
#>   student_id     q05   q06   q07   q08   q09   q10   q12   q13   q14   q15   q16
#>   <chr>        <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1 Sigrun_MMS       0     0     0     0     0     0     0     0     0     0     0
#> 2 gervinemand…     0     0     0     0     0     1     0     0     1     0     1
#> 3 gervinemand…     0     0     0     0     0     0     0     0     0     0     0
#> # ℹ 2 more variables: q17 <dbl>, q19 <dbl>
```

## example of validation

``` r
# Create a valid sample dataset
valid_data <- dplyr::tibble(
  student_id = c("1", "2", "3", "2", "2", "2"),
  item_id = c(1, 2, 3, 1, 2, 3),
  response = list("A", c("A", "B"), "", "B", c("A", "B"), "Long answer text"),
  response_status = factor(
    c(
      "correct",
      "incorrect",
      "skipped",
      "incorrect",
      "incorrect",
      "correct"
    ),
    levels = c("skipped", "correct", "incorrect")
  ),
  score = c(1, 0, 0, 0, 0, 2),
  response_time = c(30, 45, 0, 32, 41, 60),
  start_time = as.POSIXct(
    c(
      "2025-03-12 14:30:00",
      "2025-03-12 14:35:00",
      "2025-03-12 14:40:00",
      "2025-03-12 14:30:00",
      "2025-03-12 14:35:00",
      "2025-03-12 14:40:00"
    )
  ),
  end_time = as.POSIXct(
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
#> # A tibble: 6 × 8
#>   student_id item_id response  response_status score response_time
#>   <chr>        <dbl> <list>    <fct>           <dbl>         <dbl>
#> 1 1                1 <chr [1]> correct             1            30
#> 2 2                2 <chr [2]> incorrect           0            45
#> 3 3                3 <chr [1]> skipped             0             0
#> 4 2                1 <chr [1]> incorrect           0            32
#> 5 2                2 <chr [2]> incorrect           0            41
#> 6 2                3 <chr [1]> correct             2            60
#> # ℹ 2 more variables: start_time <dttm>, end_time <dttm>
validate_student_responses(valid_data)
#> Validation passed: `student_responses` is correctly formatted.
```
