app_server <- function(input, output, session) {

  # Theme module returns a reactive normalized theme list
  current_theme <- theme_selector_server("theme")

  # Data module returns reactive data and column mapping
  data_result <- data_manager_server("data")
  current_data <- data_result$data
  col_map      <- data_result$col_map

  # Inject dynamic CSS whenever theme changes
  output$dynamic_css <- renderUI({
    req(current_theme())
    tags$style(HTML(generate_canvas_css(current_theme())))
  })

  # KPI cards
  card_kpi_server("kpi_revenue",
    data = current_data, theme = current_theme,
    measure_col = reactive(col_map()$measure1),
    label_text  = reactive({
      col <- col_map()$measure1
      if (!is.null(col)) paste("Total", col) else "Total"
    })
  )

  card_kpi_server("kpi_units",
    data = current_data, theme = current_theme,
    measure_col = reactive({
      cm <- col_map()
      # Try to find a "units"-like column, otherwise use measure1
      df <- current_data()
      num_cols <- names(df)[sapply(df, is.numeric)]
      units_col <- grep("unit|qty|quantity|count", num_cols, ignore.case = TRUE, value = TRUE)
      if (length(units_col) > 0) units_col[1] else cm$measure1
    }),
    label_text = reactive({
      cm <- col_map()
      df <- current_data()
      num_cols <- names(df)[sapply(df, is.numeric)]
      units_col <- grep("unit|qty|quantity|count", num_cols, ignore.case = TRUE, value = TRUE)
      col <- if (length(units_col) > 0) units_col[1] else cm$measure1
      if (!is.null(col)) paste("Total", col) else "Total"
    })
  )

  card_kpi_server("kpi_profit",
    data = current_data, theme = current_theme,
    measure_col = reactive(col_map()$measure2 %||% col_map()$measure1),
    label_text  = reactive({
      col <- col_map()$measure2 %||% col_map()$measure1
      if (!is.null(col)) paste("Total", col) else "Total"
    })
  )

  # Charts
  bar_chart_server("bar", data = current_data, theme = current_theme, col_map = col_map)
  column_chart_server("col", data = current_data, theme = current_theme, col_map = col_map)
  line_chart_server("line", data = current_data, theme = current_theme, col_map = col_map)
  pie_chart_server("pie", data = current_data, theme = current_theme, col_map = col_map)
  scatter_plot_server("scatter", data = current_data, theme = current_theme, col_map = col_map)

  # Table
  data_table_server("table", data = current_data, theme = current_theme)

  # Theme creator tab
  theme_creator_server("creator")

  # Accessibility checker tab
  accessibility_checker_server("accessibility")
}
