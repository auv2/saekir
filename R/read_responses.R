# PATH <- "data/TAO_test_data.csv"
#' Read and process TAO response data from a CSV file
#'
#' This function reads a CSV file containing student responses exported from the TAO test delivery system.
#' It cleans, reshapes, and reformats the data into a standardized long-format tibble using `format_responses()`.
#'
#' The input file is expected to have wide-format item data (e.g., `items_item_01_label`, `items_item_01_outcomes_score`, etc.).
#'
#' @param PATH Character string specifying the file path to the TAO CSV file.
#'
#' @return A tibble with standardized columns:
#' \itemize{
#'   \item \code{student_id} – Character, unique student identifier
#'   \item \code{item_id} – Character, item label in the test
#'   \item \code{item_number} – Numeric, item number in the test
#'   \item \code{response} – Character, student response (single character, multiple responses, or long text)
#'   \item \code{response_status} – Factor, indicating if the response was correct, skipped, etc.
#'   \item \code{score} – Numeric, score for the item
#'   \item \code{response_time} – Numeric, time spent on the item (in seconds)
#'   \item \code{start_time} – POSIXct, timestamp when the test session started
#'   \item \code{end_time} – POSIXct, timestamp when the test session ended
#' }
#'
#' @seealso \code{\link{format_responses}}
#'
#' @importFrom readr read_csv
#' @importFrom janitor clean_names
#' @importFrom dplyr mutate
#' @export

read_TAO_responses_csv <- function(PATH) {

  raw_data <- readr::read_csv(PATH, show_col_types = FALSE) |>
    janitor::clean_names()

  ## Clean names
  names(raw_data) <- gsub("outcomes_", "", names(raw_data))
  names(raw_data) <- gsub("items_", "", names(raw_data))
  names(raw_data) <- gsub("responses_", "", names(raw_data))

  raw_data |>
    reshape_response_data() |>
    dplyr::mutate(
      item_start_time = NA,
      item_end_time = NA) |>
    format_responses()

}

#' Read and format TAO response data
#'
#' This function takes a TAO test data object or data frame, cleans the column names,
#' reshapes the item-level response variables into long format, and formats the result
#' into a standardized structure suitable for analysis.
#'
#' @param test_form A data frame or tibble with raw TAO test data, typically imported from a CSV or API.
#'
#' @return A tibble in long format with one row per student-item response. Includes standardized columns:
#' \describe{
#'   \item{student_id}{Unique identifier for each student}
#'   \item{item_id}{Item label (e.g., from `qti_label`)}
#'   \item{item_number}{Order number of the item in the test}
#'   \item{response}{Submitted student response}
#'   \item{response_status}{Correctness or status of the response (e.g., correct/incorrect)}
#'   \item{score}{Score awarded for the item}
#'   \item{response_time}{Time spent on the item (in seconds)}
#'   \item{start_time}{Timestamp when the item was started}
#'   \item{end_time}{Timestamp when the item was submitted}
#' }
#' @seealso [reshape_response_data()], [format_responses()]
#' @importFrom janitor clean_names
#' @examples
#' \dontrun{
#' test_form <- readr::read_rds("test_form.rds")
#' responses <- read_TAO_responses(test_form)
#' }
#'
#' @export

read_TAO_responses <- function(test_form) {
  raw_data <- test_form |>
    as.data.frame() |>
    janitor::clean_names()

  ## Clean names
  names(raw_data) <- gsub("response_\\d+_value", "response_value", names(raw_data))
  names(raw_data) <- gsub("items_", "", names(raw_data))
  names(raw_data) <- gsub("responses_", "", names(raw_data))

  raw_data |>
    reshape_response_data() |>
    format_responses()

}
