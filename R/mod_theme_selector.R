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
      swatches <- lapply(colors, function(col) {
        tags$span(
          style = sprintf(
            "display:inline-block;width:20px;height:20px;background:%s;border-radius:3px;margin:1px;border:1px solid rgba(0,0,0,0.15);",
            col
          )
        )
      })

      # Extract font information from textClasses
      tc <- th$textClasses
      title_font <- if (!is.null(tc$title$fontFace)) tc$title$fontFace else "Segoe UI"
      label_font <- if (!is.null(tc$label$fontFace)) tc$label$fontFace else "Segoe UI"

      tagList(
        tags$div(
          style = "margin-top:8px;",
          tags$strong("Active: "), th$name
        ),
        tags$div(style = "margin-top:6px;", swatches),
        tags$hr(style = "margin:12px 0;"),
        tags$div(
          style = "font-size:12px;",
          tags$strong("Typography"),
          tags$div(
            style = "margin-top:6px;color:#666;",
            tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:4px;",
              tags$span("Title font:"),
              tags$span(style = "font-weight:500;", title_font)
            ),
            tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:4px;",
              tags$span("Label font:"),
              tags$span(style = "font-weight:500;", label_font)
            ),
            if (!is.null(tc$title$fontSize)) tags$div(
              style = "display:flex;justify-content:space-between;margin-bottom:4px;",
              tags$span("Title size:"),
              tags$span(style = "font-weight:500;", paste0(tc$title$fontSize, "pt"))
            ),
            if (!is.null(tc$callout$fontSize)) tags$div(
              style = "display:flex;justify-content:space-between;",
              tags$span("Callout size:"),
              tags$span(style = "font-weight:500;", paste0(tc$callout$fontSize, "pt"))
            )
          )
        ),
        tags$hr(style = "margin:12px 0;"),
        tags$div(
          style = "font-size:12px;",
          tags$strong("Sentiment Colors"),
          tags$div(
            style = "display:flex;gap:8px;margin-top:6px;",
            tags$div(
              style = "text-align:center;",
              tags$div(style = sprintf("width:24px;height:24px;background:%s;border-radius:4px;margin:0 auto 2px;border:1px solid rgba(0,0,0,0.1);",
                                       th$good %||% "#1EAB40")),
              tags$small("Good", style = "color:#666;font-size:10px;")
            ),
            tags$div(
              style = "text-align:center;",
              tags$div(style = sprintf("width:24px;height:24px;background:%s;border-radius:4px;margin:0 auto 2px;border:1px solid rgba(0,0,0,0.1);",
                                       th$neutral %||% "#D9B300")),
              tags$small("Neutral", style = "color:#666;font-size:10px;")
            ),
            tags$div(
              style = "text-align:center;",
              tags$div(style = sprintf("width:24px;height:24px;background:%s;border-radius:4px;margin:0 auto 2px;border:1px solid rgba(0,0,0,0.1);",
                                       th$bad %||% "#D64550")),
              tags$small("Bad", style = "color:#666;font-size:10px;")
            )
          )
        )
      )
    })

    current_theme
  })
}
