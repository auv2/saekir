#PATH <- "data/TAO_test_data.csv"

#' Read and process TAO response data
#'
#' This function reads a CSV file containing student responses from the TAO test delivery system,
#' cleans and reshapes the data, and returns a standardized tibble.
#'
#' @param PATH Character string specifying the path to the TAO CSV file.
#'
#' @return A tibble with standardized columns:
#'   \itemize{
#'     \item \code{student_id}: Character, unique student identifier.
#'     \item \code{item_id}: Numeric, item number in the test.
#'     \item \code{response}: Character, student response (single character, multiple responses, or long text).
#'     \item \code{response_status}: Factor, indicating if the response was correct, skipped, etc.
#'     \item \code{score}: Numeric, score for the item.
#'     \item \code{response_time}: Numeric, time spent on the item (in seconds).
#'     \item \code{start_time}: POSIXct, timestamp when the test session started.
#'     \item \code{end_time}: POSIXct, timestamp when the test session ended.
#'   }
#'
#' @importFrom readr read_csv parse_number
#' @importFrom janitor clean_names
#' @importFrom dplyr select mutate transmute arrange ends_with
#' @importFrom tidyr pivot_longer pivot_wider
#' @importFrom stringr str_remove
#' @export
read_TAO_responses <- function(PATH) {
  vars <- c("_duration",
            "_outcomes_score",
            "_status_correct",
            "_responses_response_value")

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
      item_id = readr::parse_number(var),
      var = stringr::str_remove(var, "item_\\d+_")
    ) |>
    tidyr::pivot_wider(names_from = "var", values_from = "val") |>
    dplyr::transmute(
      student_id = as.character(login),
      item_id = as.numeric(item_id),
      response = responses_response_value,
      response_status = factor(status_correct),
      score = as.numeric(outcomes_score),
      response_time = as.numeric(duration),
      start_time = as.POSIXct(session_start_time),
      end_time = as.POSIXct(session_end_time)
    ) |>
    dplyr::arrange(item_id, student_id)
}
