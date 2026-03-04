auto_map_columns <- function(df) {
  # Detect date columns
  date_cols <- character(0)
  for (col_name in names(df)) {
    if (inherits(df[[col_name]], "Date") || inherits(df[[col_name]], "POSIXct")) {
      date_cols <- c(date_cols, col_name)
    } else if (is.character(df[[col_name]])) {
      parsed <- suppressWarnings(lubridate::parse_date_time(
        head(df[[col_name]], 20),
        orders = c("ymd", "mdy", "dmy", "Y", "Ym", "ymd HMS", "ymd HM")
      ))
      if (sum(!is.na(parsed)) > length(parsed) * 0.7) {
        date_cols <- c(date_cols, col_name)
      }
    }
  }

  numeric_cols <- names(df)[sapply(df, is.numeric)]
  char_cols <- setdiff(
    names(df)[sapply(df, function(x) is.character(x) || is.factor(x))],
    date_cols
  )

  # Sort character columns by cardinality (lowest first = best category)
  if (length(char_cols) > 1) {
    cardinalities <- sapply(char_cols, function(c) length(unique(df[[c]])))
    char_cols <- char_cols[order(cardinalities)]
  }

  list(
    category = if (length(char_cols) >= 1) char_cols[1] else NULL,
    series   = if (length(char_cols) >= 2) char_cols[2] else NULL,
    date     = if (length(date_cols) >= 1) date_cols[1] else NULL,
    measure1 = if (length(numeric_cols) >= 1) numeric_cols[1] else NULL,
    measure2 = if (length(numeric_cols) >= 2) numeric_cols[2] else NULL
  )
}
