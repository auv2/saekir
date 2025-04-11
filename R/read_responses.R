#PATH <- "data/TAO_test_data.csv"
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
#' @importFrom readr read_csv parse_number
#' @importFrom janitor clean_names
#' @importFrom dplyr select mutate transmute arrange ends_with filter distinct
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom stringr str_remove
#' @export

read_TAO_responses_csv <- function(PATH) {
  vars <- c(
    "_label",
    "_duration",
    "_outcomes_score",
    "_status_correct",
    "_responses_response_value"
  )

  dat <- readr::read_csv(PATH, show_col_types = FALSE) |>
    janitor::clean_names()

  responses <- dat |>
    dplyr::select(# id,
      login,
      # score,
      # max_score,
      session_end_time,
      session_start_time,
      dplyr::ends_with(vars)) |>
    dplyr::mutate(across(everything(), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::contains(vars),
      names_to = "var",
      values_to = "val"
    ) |>
    dplyr::mutate(
      var = stringr::str_remove(var, "items_"),
      item_number = readr::parse_number(var),
      var = stringr::str_remove(var, "item_\\d+_")
    )

  format_responses(responses)

}
