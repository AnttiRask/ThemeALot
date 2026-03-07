# Helper to create a color swatch with tooltip showing hex and color name
make_color_swatch <- function(col, size = 20, border_radius = 3) {
  # Get color name using col2hex2col
  color_name <- tryCatch(
    col2hex2col::hex_to_color(col, fallback_nearest_color = TRUE),
    error = function(e) NA_character_
  )

  tooltip <- if (!is.na(color_name)) {
    sprintf("%s\n%s", toupper(col), tools::toTitleCase(color_name))
  } else {
    toupper(col)
  }

  tags$span(
    style = sprintf(
      "display:inline-block;width:%dpx;height:%dpx;background:%s;border-radius:%dpx;margin:1px;border:1px solid rgba(0,0,0,0.15);cursor:pointer;",
      size, size, col, border_radius
    ),
    title = tooltip
  )
}

# Helper to create a labeled color swatch (for theme colors section)
make_labeled_swatch <- function(col, label, size = 24) {
  color_name <- tryCatch(
    col2hex2col::hex_to_color(col, fallback_nearest_color = TRUE),
    error = function(e) NA_character_
  )

  tooltip <- if (!is.na(color_name)) {
    sprintf("%s\n%s", toupper(col), tools::toTitleCase(color_name))
  } else {
    toupper(col)
  }

  tags$div(
    style = "text-align:center;",
    tags$div(
      style = sprintf(
        "width:%dpx;height:%dpx;background:%s;border-radius:4px;margin:0 auto 2px;border:1px solid rgba(255,255,255,0.15);cursor:pointer;",
        size, size, col
      ),
      title = tooltip
    ),
    tags$small(label, style = "color:#B2B2B2;font-size:10px;")
  )
}

theme_selector_ui <- function(id) {
  ns <- NS(id)
  tagList(
    selectInput(ns("builtin"), "Built-in Theme",
                choices = names(builtin_themes),
                selected = "Default"),
    fileInput(ns("upload"), "Upload Custom theme.json",
              accept = ".json"),
    uiOutput(ns("active_info"))
  )
}

theme_selector_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    uploaded_theme <- reactiveVal(NULL)

    observeEvent(input$upload, {
      req(input$upload)
      parsed <- tryCatch(
        parse_theme_json(input$upload$datapath),
        error = function(e) {
          showNotification(paste("Invalid theme file:", e$message), type = "error")
          NULL
        }
      )
      uploaded_theme(parsed)
    })

    # Changing dropdown clears the upload
    observeEvent(input$builtin, {
      uploaded_theme(NULL)
    })

    current_theme <- reactive({
      if (!is.null(uploaded_theme())) {
        return(uploaded_theme())
      }
      builtin_themes[[input$builtin]]
    })

    output$active_info <- renderUI({
      th <- current_theme()
      colors <- th$dataColors[1:min(8, length(th$dataColors))]

      # Create data color swatches with tooltips
      swatches <- lapply(colors, make_color_swatch)

      # Extract font information from textClasses
      tc <- th$textClasses
      title_font <- if (!is.null(tc$title$fontFace)) tc$title$fontFace else "Segoe UI"
      label_font <- if (!is.null(tc$label$fontFace)) tc$label$fontFace else "Segoe UI"
      callout_font <- if (!is.null(tc$callout$fontFace)) tc$callout$fontFace else "Segoe UI Light"

      tagList(
        tags$div(
          style = "margin-top:8px;",
          tags$strong("Active: "), th$name
        ),
        tags$hr(style = "margin:12px 0;"),

        # Data Colors section
        tags$div(
          style = "font-size:12px;",
          tags$strong("Data Colors"),
          tags$div(style = "margin-top:6px;", swatches)
        ),
        tags$hr(style = "margin:12px 0;"),

        # Theme Colors section
        tags$div(
          style = "font-size:12px;",
          tags$strong("Theme Colors"),
          tags$div(
            style = "display:flex;gap:8px;margin-top:6px;flex-wrap:wrap;",
            make_labeled_swatch(th$background %||% "#FFFFFF", "Background"),
            make_labeled_swatch(th$foreground %||% "#252423", "Foreground"),
            make_labeled_swatch(th$tableAccent %||% th$dataColors[1], "Table Accent")
          )
        ),
        tags$hr(style = "margin:12px 0;"),

        # Sentiment Colors section
        tags$div(
          style = "font-size:12px;",
          tags$strong("Sentiment Colors"),
          tags$div(
            style = "display:flex;gap:8px;margin-top:6px;",
            make_labeled_swatch(th$good %||% "#1EAB40", "Good"),
            make_labeled_swatch(th$neutral %||% "#D9B300", "Neutral"),
            make_labeled_swatch(th$bad %||% "#D64550", "Bad")
          )
        ),
        tags$hr(style = "margin:12px 0;"),

        # Typography section
        tags$div(
          style = "font-size:12px;",
          tags$strong("Typography"),
          tags$div(
            style = "margin-top:6px;color:#B2B2B2;",
            # Title
            tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:2px;",
              tags$span("Title font:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", title_font)
            ),
            if (!is.null(tc$title$fontSize)) tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:8px;",
              tags$span("Title size:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", paste0(tc$title$fontSize, "pt"))
            ),
            # Label
            tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:2px;",
              tags$span("Label font:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", label_font)
            ),
            if (!is.null(tc$label$fontSize)) tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:8px;",
              tags$span("Label size:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", paste0(tc$label$fontSize, "pt"))
            ),
            # Callout
            tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:2px;",
              tags$span("Callout font:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", callout_font)
            ),
            if (!is.null(tc$callout$fontSize)) tags$div(
              style = "display:flex;justify-content:space-between;",
              tags$span("Callout size:"),
              tags$span(style = "font-weight:500;color:#FFFFFF;", paste0(tc$callout$fontSize, "pt"))
            )
          )
        )
      )
    })

    current_theme
  })
}
