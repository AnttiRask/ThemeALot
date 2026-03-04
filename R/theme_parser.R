`%||%` <- function(a, b) if (!is.null(a)) a else b

# ── Input sanitization for security ───────────────────────────────────────────

# Validate hex color format (#RGB, #RRGGBB, or #RRGGBBAA)
# Returns default if invalid to prevent CSS injection
sanitize_color <- function(color, default = "#000000") {
  if (is.null(color) || !is.character(color) || length(color) != 1) {
    return(default)
  }
  # Only allow valid hex color patterns

  if (grepl("^#([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$", color)) {
    return(color)
  }
  default
}

# Sanitize a vector of colors
sanitize_colors <- function(colors, defaults) {
  if (is.null(colors) || !is.character(colors)) {
    return(defaults)
  }
  mapply(sanitize_color, colors, defaults[seq_along(colors)], USE.NAMES = FALSE)
}

# Sanitize font face - only allow safe characters (letters, numbers, spaces, hyphens, commas)
sanitize_font_face <- function(font, default = "Segoe UI") {
  if (is.null(font) || !is.character(font) || length(font) != 1) {
    return(default)
  }
  # Remove any characters that could be used for CSS injection
  clean <- gsub("[^a-zA-Z0-9 ,'-]", "", font)
  if (nchar(clean) == 0) {
    return(default)
  }
  clean
}

# Sanitize font size - must be a positive number within reasonable range
sanitize_font_size <- function(size, default = 12) {
  if (is.null(size) || !is.numeric(size) || length(size) != 1) {
    return(default)
  }
  # Clamp to reasonable range (6-72pt)
  max(6, min(72, as.integer(size)))
}

# Sanitize theme name - remove potential XSS characters
sanitize_name <- function(name, default = "Custom Theme") {
  if (is.null(name) || !is.character(name) || length(name) != 1) {
    return(default)
  }
  # Remove HTML/script tags and limit length
  clean <- gsub("<[^>]*>", "", name)
  clean <- gsub("[<>\"'&]", "", clean)
  substr(clean, 1, 100)
}

# ── Theme parsing ─────────────────────────────────────────────────────────────

parse_text_class <- function(raw_class, default_class) {
  if (is.null(raw_class)) return(default_class)
  list(
    fontFace = sanitize_font_face(
      (raw_class$fontFace %||% raw_class$fontFamily) %||% default_class$fontFace,
      default_class$fontFace
    ),
    fontSize = sanitize_font_size(
      raw_class$fontSize %||% default_class$fontSize,
      default_class$fontSize
    ),
    color = sanitize_color(
      raw_class$color %||% default_class$color,
      default_class$color
    )
  )
}

parse_theme_json <- function(json_path) {
  raw <- jsonlite::fromJSON(json_path, simplifyVector = TRUE)
  default <- builtin_themes[["Default"]]

  list(
    name        = sanitize_name(raw$name %||% "Custom Theme"),
    dataColors  = sanitize_colors(raw$dataColors, default$dataColors),
    background  = sanitize_color(raw$background  %||% default$background, default$background),
    foreground  = sanitize_color(raw$foreground  %||% default$foreground, default$foreground),
    tableAccent = sanitize_color(raw$tableAccent %||% default$tableAccent, default$tableAccent),
    good        = sanitize_color(raw$good        %||% default$good, default$good),
    neutral     = sanitize_color(raw$neutral     %||% default$neutral, default$neutral),
    bad         = sanitize_color(raw$bad         %||% default$bad, default$bad),
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
