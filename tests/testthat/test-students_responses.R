library(testthat)
library(dplyr)
library(tibble)
library(readr)

# Create a temporary CSV file for testing
df <- tribble(
        ~score, ~outcomes.SCORE_TOTAL_MAX, ~outcomes.SCORE_RATIO, ~outcomes.SCORE_TOTAL,       ~sessionEndTime,       ~ltiParameters.name,     ~sessionStartTime,                    ~login, ~maxScore, ~`items.item-9.duration`, ~`items.item-9.outcomes.SCORE`, ~`items.item-9.outcomes.MAXSCORE`, ~`items.item-9.outcomes.completionStatus`, ~`items.item-9.statusCorrect`, ~`items.item-9.qtiTitle`, ~`items.item-9.responses.RESPONSE.correct`, ~`items.item-9.responses.RESPONSE.value`, ~`items.item-9.qtiLabel`, ~`items.item-18.duration`, ~`items.item-18.outcomes.completionStatus`, ~`items.item-18.statusCorrect`, ~`items.item-18.qtiTitle`, ~`items.item-18.responses`, ~`items.item-18.qtiLabel`, ~`items.item-8.duration`, ~`items.item-8.outcomes.SCORE`, ~`items.item-8.outcomes.MAXSCORE`, ~`items.item-8.outcomes.completionStatus`, ~`items.item-8.statusCorrect`, ~`items.item-8.qtiTitle`, ~`items.item-8.responses.RESPONSE.correct`, ~`items.item-8.responses.RESPONSE.value`,
            4L,                       13L,     0.307692307692308,                    4L, "2025-03-03 20:40:10", "gervinemandi_bergmann_4", "2025-03-03 20:29:14", "gervinemandi_bergmann_4",       13L,                       1L,                             0L,                                1L,                               "completed",                     "skipped",                       NA,                                      FALSE,                                       NA,   "Sýnispróf Hvolpar 05",                       37L,                                "completed",                         "seen",                        NA,                       "{}",                 "Lokaorð",                       1L,                             0L,                                1L,                               "completed",                   "incorrect",                       NA,                                      FALSE,                               "choice_3",
            1L,                       13L,    0.0769230769230769,                    1L, "2025-03-05 10:21:08", "gervinemandi_bergmann_5", "2025-03-05 10:11:32", "gervinemandi_bergmann_5",       13L,                       0L,                             0L,                                1L,                               "completed",                     "skipped",                       NA,                                      FALSE,                                       NA,   "Sýnispróf Hvolpar 05",                        3L,                                "completed",                         "seen",                        NA,                       "{}",                 "Lokaorð",                      36L,                             0L,                                1L,                               "completed",                   "incorrect",                       NA,                                      FALSE,                               "choice_1",
            1L,                       13L,    0.0769230769230769,                    1L, "2025-03-10 10:54:16",                  "Sigrún", "2025-03-03 14:10:56",              "Sigrun_MMS",       13L,                       0L,                             0L,                                1L,                               "completed",                     "skipped",                       NA,                                      FALSE,                                       NA,   "Sýnispróf Hvolpar 05",                        1L,                                "completed",                         "seen",                        NA,                       "{}",                 "Lokaorð",                       0L,                             0L,                                1L,                               "completed",                     "skipped",                       NA,                                      FALSE,                                       NA
        )


# Create a temporary file
temp_file <- tempfile(fileext = ".csv")

# Write data to the temporary CSV
write.csv(df, temp_file, row.names = FALSE)

# Run the function on the test CSV
test_data <- read_TAO_responses_csv(temp_file)

test_that("Function returns a tibble with correct column names", {
  expected_cols <- c("student_id", "item_id", "response", "response_status",
                     "score", "response_time")

  expect_true(all(expected_cols %in% names(test_data)))
})

test_that("Data types match expected format", {
  expect_type(test_data$student_id, "character")
  expect_type(test_data$item_id, "character")
  expect_type(test_data$response, "character")
  expect_type(test_data$response_status, "character")
  expect_type(test_data$score, "double") # as.numeric()
  expect_type(test_data$response_time, "double") # as.numeric()
})



