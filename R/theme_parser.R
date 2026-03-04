`%||%` <- function(a, b) if (!is.null(a)) a else b

parse_text_class <- function(raw_class, default_class) {
  if (is.null(raw_class)) return(default_class)
  list(
    fontFace = (raw_class$fontFace %||% raw_class$fontFamily) %||% default_class$fontFace,
    fontSize = raw_class$fontSize %||% default_class$fontSize,
    color    = raw_class$color    %||% default_class$color
  )
}

parse_theme_json <- function(json_path) {
  raw <- jsonlite::fromJSON(json_path, simplifyVector = TRUE)
  default <- builtin_themes[["Default"]]

  list(
    name        = raw$name        %||% "Custom Theme",
    dataColors  = raw$dataColors  %||% default$dataColors,
    background  = raw$background  %||% default$background,
    foreground  = raw$foreground  %||% default$foreground,
    tableAccent = raw$tableAccent %||% default$tableAccent,
    good        = raw$good        %||% default$good,
    neutral     = raw$neutral     %||% default$neutral,
    bad         = raw$bad         %||% default$bad,
    textClasses = list(
      label   = parse_text_class(raw$textClasses$label,   default$textClasses$label),
      title   = parse_text_class(raw$textClasses$title,   default$textClasses$title),
      callout = parse_text_class(raw$textClasses$callout, default$textClasses$callout),
      header  = parse_text_class(raw$textClasses$header,  default$textClasses$header)
    )
  )
}

get_theme <- function(builtin_name = NULL, upload_path = NULL) {
  if (!is.null(upload_path)) {
    return(parse_theme_json(upload_path))
  }
  if (!is.null(builtin_name) && builtin_name %in% names(builtin_themes)) {
    return(builtin_themes[[builtin_name]])
  }
  builtin_themes[["Default"]]
}
