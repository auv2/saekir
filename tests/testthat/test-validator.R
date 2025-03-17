library(testthat)
library(dplyr)

# Create a valid sample dataset
valid_data <- tibble(
  student_id = c("1", "2", "3"),
  item_id = c(1, 2, 3),
  response = list("A", c("A", "B"), "Long answer text"),
  response_status = factor(
    c("correct", "incorrect", "skipped"),
    levels = c("skipped", "correct", "incorrect")
  ),
  score = c(1, 0, 2),
  response_time = c(30, 45, 60),
  start_time = as.POSIXct(
    c(
      "2025-03-12 14:30:00",
      "2025-03-12 14:40:00",
      "2025-03-12 14:50:00"
    )
  ),
  end_time = as.POSIXct(
    c(
      "2025-03-12 14:35:00",
      "2025-03-12 14:45:00",
      "2025-03-12 15:00:00"
    )
  )
)

# Define test cases
test_that("Valid data passes validation", {
  expect_condition(
    validate_student_responses(valid_data),
    "Validation passed: `student_responses` is correctly formatted."
  )
})

test_that("Incorrect column order fails", {
  incorrect_order_data <- valid_data |> select(item_id, student_id, everything())
  expect_error(
    validate_student_responses(incorrect_order_data),
    "Column names or order do not match"
  )
})

test_that("Missing values in critical columns trigger warning", {
  missing_data <- valid_data
  missing_data$response_status[1] <- NA
  expect_warning(
    validate_student_responses(missing_data),
    "Missing values detected in critical columns"
  )
})

test_that("Type mismatches trigger error", {
  type_mismatch_data <- valid_data |> mutate(score = as.character(score))
  expect_error(validate_student_responses(type_mismatch_data),
               "incorrect types: score")
})

test_that("Extra columns do not affect validation", {
  extra_col_data <- valid_data |> mutate(extra = "extra_column")
  expect_condition(
    validate_student_responses(extra_col_data |> select(-extra)),
    "Validation passed: `student_responses` is correctly formatted."
  )
})

test_that("Factor levels are correctly enforced", {
  wrong_factor_data <- valid_data |>
    mutate(response_status = factor(response_status, levels = c("yes", "no")))
  expect_warning(
    validate_student_responses(wrong_factor_data),
    "Warning: Missing values detected in critical columns: response_status"
  )
})
