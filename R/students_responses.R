#' Reshape wide-format response data
#'
#' Converts a wide-format dataset of item responses into a long-format structure,
#' extracting item metadata (e.g., item ID from qti_label).
#'
#' @param raw_data A data frame containing login, score, session times, and item_* variables.
#' @return A long-format tibble with columns: login, total_score, session times, item_number, var, val, and item_id.
#' @importFrom stringi stri_c
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
    dplyr::left_join(item_id, by =  dplyr::join_by(item_number)) |>
    dplyr::mutate(var = gsub("response_\\d+_value", "response_value",var)) |>
    dplyr::summarise(
      val =  if (length(val) == 1) val else stringi::stri_c(val, collapse = ", "),
      .by = c(
        login,
        total_score,
        session_start_time,
        session_end_time,
        item_number,
        item_id,
        var
      )
    )
  return(responses)

}

#' Format long-form response data into a structured item-level format
#'
#' This function takes reshaped response data (e.g., from `reshape_response_data()`)
#' and converts it into a structured, tidy format with one row per student-item response.
#' It ensures consistent data types, extracts core response features (e.g., response, score, timing),
#' and is optimized for downstream analysis or scoring.
#'
#' @param responses A long-format tibble where each row corresponds to one response variable
#' for one item and one student. Must include columns `login`, `item_id`, `item_number`,
#' and wide-form variables (e.g., `response_value`, `status_correct`, `score`, `duration`,
#' `item_start_time`, `item_end_time`) after pivoting.
#'
#' @return A tibble with one row per student-item response, including:
#' \describe{
#'   \item{student_id}{Character. Unique identifier for each student (from `login`).}
#'   \item{item_id}{Character. Item label (e.g., from `qti_label`).}
#'   \item{item_number}{Numeric. Position of the item in the test sequence.}
#'   \item{response}{Character. The student’s submitted answer.}
#'   \item{response_status}{Factor. The correctness or status of the response (e.g., "correct", "incorrect").}
#'   \item{score}{Numeric. Points awarded for the item.}
#'   \item{response_time}{Numeric. Time spent on the item, in seconds.}
#'   \item{start_time}{POSIXct. Timestamp when the item was started.}
#'   \item{end_time}{POSIXct. Timestamp when the item was submitted.}
#' }
#'
#' @importFrom dplyr select mutate transmute arrange filter distinct
#' @importFrom tidyr pivot_wider
#' @examples
#' \dontrun{
#' reshaped <- reshape_response_data(raw_data)
#' formatted <- format_responses(reshaped)
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

