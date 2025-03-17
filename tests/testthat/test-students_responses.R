library(testthat)
library(dplyr)
library(readr)

# Create a temporary CSV file for testing
df <- data.frame(
  login = c("S1", "S2", "S3"),
  sessionStartTime = c("2025-03-12 14:35:00", "2025-03-12 14:40:00", "2025-03-12 15:00:00"),
  sessionEndTime = c("2025-03-12 14:45:00", "2025-03-12 14:55:00", "2025-03-12 15:20:00"),
  items.item.1.duration = c(30, 50, NA),
  items.item.1.outcomes.SCORE = c(1, 2, 1),
  items.item.1.outcomes.MAXSCORE = c(2, 2, NA),
  items.item.1.status.correct = c("correct", "incorrect", "correct"),
  items.item.1.responses.RESPONSE.value = c("A", "C", NA),
  items.item.1.responses.RESPONSE.correct = c(TRUE, FALSE, TRUE),
  stringsAsFactors = FALSE
)

# Create a temporary file
temp_file <- tempfile(fileext = ".csv")

# Write data to the temporary CSV
write.csv(df, temp_file, row.names = FALSE)

# Run the function on the test CSV
test_data <- read_TAO_responses(temp_file)

test_that("Function returns a tibble with correct column names", {
  expected_cols <- c("student_id", "item_id", "response", "response_status",
                     "score", "response_time", "start_time", "end_time")

  expect_true(all(expected_cols %in% names(test_data)))
})

test_that("Data types match expected format", {
  expect_type(test_data$student_id, "character")
  expect_type(test_data$item_id, "double") # as.numeric()
  expect_type(test_data$response, "character")
  expect_s3_class(test_data$response_status, "factor")
  expect_type(test_data$score, "double") # as.numeric()
  expect_type(test_data$response_time, "double") # as.numeric()
  expect_s3_class(test_data$start_time, "POSIXct")
  expect_s3_class(test_data$end_time, "POSIXct")
})

test_that("Missing values are correctly handled", {
  expect_true(is.na(test_data$response_time[3]))  # Missing value from CSV
})

test_that("Data is sorted by item_id and student_id", {
  expect_true(all(diff(test_data$item_id) >= 0))  # Item ID should be increasing
})

test_that("Start and end times are parsed correctly", {
  expect_equal(test_data$start_time[1], as.POSIXct("2025-03-12 14:35:00"))
  expect_equal(test_data$end_time[1], as.POSIXct("2025-03-12 14:45:00"))
})

