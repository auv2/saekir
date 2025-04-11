#' Format standardized response data
#'
#' This function formats long-form response data from assessment platforms (e.g., TAO)
#' into a tidy, rectangular structure suitable for analysis. It assigns item identifiers,
#' reshapes key response variables, and ensures consistent data types across fields.
#'
#' @param responses A long-format data frame where each row corresponds to one variable of one item
#' for one student (e.g., output from reshaping raw platform data), with columns `item_number`, `var`, and `val`.
#'
#' @return A tibble with one row per student-item response and the following columns:
#' \describe{
#'   \item{student_id}{Character, unique identifier for each student}
#'   \item{item_id}{Character, item label (e.g., from `qti_label`)}
#'   \item{item_number}{Numeric, item order number in the test}
#'   \item{response}{Character, the student’s submitted response}
#'   \item{response_status}{Factor, correctness or status of the response (e.g., correct/incorrect)}
#'   \item{score}{Numeric, item-level score}
#'   \item{response_time}{Numeric, time spent on the item (in seconds)}
#'   \item{start_time}{POSIXct, timestamp when the item was started}
#'   \item{end_time}{POSIXct, timestamp when the item was submitted}
#' }
#'
#' @examples
#' \dontrun{
#' formatted <- format_responses(raw_long_response_data)
#' }
#'
#' @export

format_responses <- function(responses) {
  item_id <- responses |>
    dplyr::filter(var == "qti_label") |>
    dplyr::mutate(item_id = val) |>
    dplyr::distinct(item_number, item_id)


  responses |>
    dplyr::left_join(item_id, by =  dplyr::join_by(item_number)) |>
    tidyr::pivot_wider(names_from = "var", values_from = "val") |>
    dplyr::transmute(
      student_id = as.character(login),
      item_id = as.character(item_id),
      item_number = as.numeric(item_number),
      response = responses_response_value,
      response_status = factor(status_correct),
      score = as.numeric(outcomes_score),
      response_time = as.numeric(duration),
      start_time = as.POSIXct(session_start_time),
      end_time = as.POSIXct(session_end_time)
    ) |>
    dplyr::arrange(item_id, student_id)

}

