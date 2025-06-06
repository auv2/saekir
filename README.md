
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
students_responses <- read_TAO_responses_csv("data/TAO_test_data.csv")

dplyr::glimpse(students_responses)
#> Rows: 57
#> Columns: 9
#> $ student_id      <chr> "Sigrun_MMS", "gervinemandi_bergmann_4", "gervinemandi…
#> $ item_id         <chr> "Lesskilningur", "Lesskilningur", "Lesskilningur", "Lo…
#> $ item_number     <dbl> 4, 4, 4, 18, 18, 18, 19, 19, 19, 3, 3, 3, 17, 12, 11, …
#> $ response        <chr> NA, NA, NA, NA, NA, NA, "1234", "1234", "1234", NA, NA…
#> $ response_status <fct> seen, seen, seen, seen, seen, seen, correct, correct, …
#> $ score           <dbl> NA, NA, NA, NA, NA, NA, 1, 1, 1, NA, NA, NA, 0, 0, NA,…
#> $ response_time   <dbl> 2, 7, 0, 1, 37, 3, 6, 6, 7, 1, 46, 0, 0, 1, 6, 19, 1, …
#> $ start_time      <dttm> 2025-03-03 14:10:56, 2025-03-03 20:29:14, 2025-03-05 …
#> $ end_time        <dttm> 2025-03-10 10:54:16, 2025-03-03 20:40:10, 2025-03-05 …
```

``` r
get_item_matrix(students_responses)
#> Warning: Values from `score` are not uniquely identified; output will contain list-cols.
#> • Use `values_fn = list` to suppress this warning.
#> • Use `values_fn = {summary_fun}` to summarise duplicates.
#> • Use the following dplyr code to identify duplicates.
#>   {data} |>
#>   dplyr::summarise(n = dplyr::n(), .by = c(student_id, item_id)) |>
#>   dplyr::filter(n > 1L)
#> # A tibble: 3 × 9
#>   student_id              `Lykilorð 1234` Stærðfræði `Sýnispróf Hvolpar 01`
#>   <chr>                   <list>          <list>     <list>                
#> 1 Sigrun_MMS              <dbl [1]>       <dbl [6]>  <dbl [1]>             
#> 2 gervinemandi_bergmann_4 <dbl [1]>       <dbl [6]>  <dbl [1]>             
#> 3 gervinemandi_bergmann_5 <dbl [1]>       <dbl [6]>  <dbl [1]>             
#> # ℹ 5 more variables: `Sýnispróf Hvolpar 02` <list>,
#> #   `Sýnispróf Hvolpar 03` <list>, `Sýnispróf Hvolpar 04` <list>,
#> #   `Sýnispróf Hvolpar 05` <list>, `Sýnispróf Hvolpar 06` <list>
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
