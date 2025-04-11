#' Convert Student Responses to Item Score Matrix
#'
#' This function transforms the `students_responses` data frame into a rectangular format
#' where each row represents a student and each column represents an item, with values
#' corresponding to the students' scores.
#'
#' @param students_responses A data frame containing student responses with at least
#'   the following columns:
#'   \itemize{
#'     \item \code{student_id}: Character, unique identifier for each student.
#'     \item \code{item_id}: Numeric, unique identifier for each test item.
#'     \item \code{score}: Numeric, score obtained by the student on the item.
#'   }
#' @param responses Logical. If `FALSE`, the matrix contains scored items (numeric values).
#'   If `TRUE`, it contains raw responses (character values).
#' @return A data frame (wide format) where:
#'   \itemize{
#'     \item Rows represent unique students.
#'     \item Columns represent test items.
#'     \item Values represent the students' scores on each item.
#'   }
#'
#' @details
#' - Removes rows where `score` is missing (`NA`).
#' - Renames `item_id` using the helper function `name_item()`, which should return
#'   a standardized item name (e.g., "Item_1" instead of numeric IDs).
#' - Uses `pivot_wider()` to transform the data into a matrix-like format.
#'
#' @importFrom dplyr filter select mutate
#' @importFrom tidyr pivot_wider
#' @importFrom stringr str_pad
#' @export
get_item_matrix <- function(students_responses, responses = FALSE) {

  # name_item <- function(i, prefix) {
  #   paste0(prefix, stringr::str_pad(string = i, width = 2, pad = "0"))
  # }

  if (responses) {
    students_responses |>
      dplyr::filter(!is.na(response)) |>
      dplyr::select(student_id, item_id, response) |>
     # dplyr::mutate(item_id = name_item(item_id)) |>
      tidyr::pivot_wider(names_from = item_id, values_from = response)
  } else {
  students_responses |>
    dplyr::filter(!is.na(score)) |>
    dplyr::select(student_id, item_id, score) |>
   # dplyr::mutate(item_id = name_item(item_id)) |>
    tidyr::pivot_wider(names_from = item_id, values_from = score)
  }
}
