data_manager_ui <- function(id) {
  ns <- NS(id)
  tagList(
    fileInput(ns("csv_upload"), "Upload CSV Data (optional)", accept = ".csv"),
    conditionalPanel(
      condition = sprintf("output['%s']", ns("show_mapping")),
      tags$h6("Column Mapping", class = "sidebar-section-title"),
      selectInput(ns("map_category"), "Category", choices = NULL),
      selectInput(ns("map_series"),   "Series (color)", choices = NULL),
      selectInput(ns("map_date"),     "Date", choices = NULL),
      selectInput(ns("map_measure1"), "Measure 1", choices = NULL),
      selectInput(ns("map_measure2"), "Measure 2", choices = NULL)
    )
  )
}

data_manager_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    sample_df <- generate_sample_data()
    uploaded_df <- reactiveVal(NULL)

    observeEvent(input$csv_upload, {
      req(input$csv_upload)
      df <- tryCatch(
        read.csv(input$csv_upload$datapath, stringsAsFactors = FALSE),
        error = function(e) {
          showNotification(paste("Error reading CSV:", e$message), type = "error")
          NULL
        }
      )
      if (!is.null(df)) {
        uploaded_df(df)
        auto <- auto_map_columns(df)
        all_cols <- c("(none)", names(df))
        updateSelectInput(session, "map_category", choices = all_cols, selected = auto$category %||% "(none)")
        updateSelectInput(session, "map_series",   choices = all_cols, selected = auto$series %||% "(none)")
        updateSelectInput(session, "map_date",     choices = all_cols, selected = auto$date %||% "(none)")
        updateSelectInput(session, "map_measure1", choices = all_cols, selected = auto$measure1 %||% "(none)")
        updateSelectInput(session, "map_measure2", choices = all_cols, selected = auto$measure2 %||% "(none)")
      }
    })

    output$show_mapping <- reactive(!is.null(uploaded_df()))
    outputOptions(output, "show_mapping", suspendWhenHidden = FALSE)

    current_data <- reactive({
      if (!is.null(uploaded_df())) uploaded_df() else sample_df
    })

    col_map <- reactive({
      if (is.null(uploaded_df())) {
        list(
          category = "Product",
          series   = "Region",
          date     = "Date",
          measure1 = "Revenue",
          measure2 = "Profit"
        )
      } else {
        nullify <- function(x) if (is.null(x) || x == "(none)") NULL else x
        list(
          category = nullify(input$map_category),
          series   = nullify(input$map_series),
          date     = nullify(input$map_date),
          measure1 = nullify(input$map_measure1),
          measure2 = nullify(input$map_measure2)
        )
      }
    })

    list(data = current_data, col_map = col_map)
  })
}
