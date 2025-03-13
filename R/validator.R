#' Validate student_responses DataFrame
#'
#' This function checks whether the `student_responses` DataFrame conforms to the expected schema.
#' It verifies column names, data types, and missing values in key columns.
#'
#' @param df A data frame to validate.
#' @return The validated data frame (invisibly) if no errors are found.
#' @importFrom dplyr tibble summarise across
#' @importFrom rlang abort
#' @importFrom purrr map2_lgl
#' @importFrom glue glue
#' @export
validate_student_responses <- function(df) {
  expected_schema <- dplyr::tibble(
    student_id = character(),
    item_id = numeric(),
    response = list(),  # Can be character, multiple responses, or long text
    response_status = factor(levels = c("skipped", "correct", "incorrect")),
    score = numeric(),
    response_time = numeric(),
    timestamp = as.POSIXct(character())
  )

  # Check column names and order
  if (!all(names(df) == names(expected_schema))) {
    rlang::abort("Error: Column names or order do not match expected schema.")
  }

  # Check column types
  type_mismatch <- purrr::map2_lgl(df, expected_schema, ~ !inherits(.x, class(.y)))

  if (any(type_mismatch)) {
    rlang::abort(glue::glue("Error: The following columns have incorrect types: {paste(names(df)[type_mismatch], collapse = ', ')}"))
  }

  # Check for missing values in key columns
  critical_cols <- c("student_id", "item_id", "response_status", "score", "response_time", "timestamp")

  missing_values <- df |>
    dplyr::summarise(dplyr::across(dplyr::all_of(critical_cols), ~ sum(is.na(.))))

  if (any(missing_values > 0)) {
    warning(glue::glue("Warning: Missing values detected in critical columns: {paste(names(missing_values)[missing_values > 0], collapse = ', ')}"))
  }

  message("Validation passed: `student_responses` is correctly formatted.")
  return(invisible(df))
}
