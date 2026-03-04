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
      tagList(
        tags$div(
          style = "margin-top:8px;",
          tags$strong("Active: "), th$name
        ),
        tags$div(style = "margin-top:6px;", swatches)
      )
    })

    current_theme
  })
}
