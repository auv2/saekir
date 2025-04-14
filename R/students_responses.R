#' Reshape wide-format response data
#'
#' Converts a wide-format dataset of item responses into a long-format structure,
#' extracting item metadata (e.g., item ID from qti_label).
#'
#' @param raw_data A data frame containing login, score, session times, and item_* variables.
#' @return A long-format tibble with columns: login, total_score, session times, item_number, var, val, and item_id.
#' @export

reshape_response_data <- function(raw_data) {
  # if (!all(c("login", "score", "session_start_time", "session_end_time") %in% names(raw_data))) {
  #   stop("Missing required columns in input data")
  # }

  responses <- raw_data |>
    dplyr::select(login,
                  total_score = score,
                  session_start_time,
                  session_end_time,
                  dplyr::starts_with("item_")) |>
    dplyr::mutate(across(everything(), as.character)) |>
    tidyr::pivot_longer(
      cols = dplyr::starts_with("item_"),
      names_to = "var",
      values_to = "val"
    ) |>
    dplyr::mutate(
      item_number = readr::parse_number(var),
      var = stringr::str_remove(var, "item_\\d+_")
    )

  item_id <- responses |>
    dplyr::filter(var == "qti_label") |>
    dplyr::mutate(item_id = val) |>
    dplyr::distinct(item_number, item_id)

  responses <- responses |>
    dplyr::left_join(item_id, by =  dplyr::join_by(item_number))
  return(responses)

}

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
#' @importFrom dplyr select mutate transmute arrange  filter distinct
#' @importFrom tidyr pivot_wider
#' @examples
#' \dontrun{
#' formatted <- format_responses(raw_long_response_data)
#' }
#'
#' @export

format_responses <- function(responses) {
  responses |>
    tidyr::pivot_wider(names_from = "var", values_from = "val") |>
    dplyr::distinct() |>
    dplyr::transmute(
      student_id = as.character(login),
      item_id = as.character(item_id),
      item_number = as.numeric(item_number),
      response = response_value,
      response_status = (status_correct),
      score = as.numeric(score),
      response_time = as.numeric(duration),
      start_time = get_time(item_start_time),
      end_time = get_time(item_end_time)
    ) |>
    dplyr::arrange(item_id, student_id)
}




#' Convert timestamp in milliseconds to POSIXct format
#'
#' This function converts a timestamp in milliseconds (Unix time) to POSIXct format, which
#' can be used to represent dates and times in R. The timestamp is assumed to be in UTC.
#'
#' @param timestamp A numeric or character vector containing the timestamp in milliseconds.
#'   This will be converted into seconds before being used to generate the corresponding POSIXct object.
#'
#' @return A POSIXct object representing the timestamp in UTC.
#'
#' @examples
#' timestamp <- 1620000000000
#' converted_time <- get_time(timestamp)
#' print(converted_time)
#'
#' @export
get_time <- function(timestamp) {
  timestamp_sec <- as.numeric(timestamp) / 1000
  converted_time <- as.POSIXct(timestamp_sec, origin = "1970-01-01", tz = "UTC")
  return(converted_time)
}

