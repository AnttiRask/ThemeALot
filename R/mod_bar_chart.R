bar_chart_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("chart"), height = "300px")
}

bar_chart_server <- function(id, data, theme, col_map) {
  moduleServer(id, function(input, output, session) {
    output$chart <- renderPlotly({
      req(data(), theme(), col_map())
      df <- data()
      th <- theme()
      cm <- col_map()

      cat_col <- cm$category
      val_col <- cm$measure1
      req(cat_col, val_col)
      if (!cat_col %in% names(df) || !val_col %in% names(df)) return(NULL)

      agg <- df %>%
        dplyr::group_by(dplyr::across(dplyr::all_of(cat_col))) %>%
        dplyr::summarise(value = sum(.data[[val_col]], na.rm = TRUE), .groups = "drop") %>%
        dplyr::arrange(value)

      colors <- theme_colorway(th)
      bar_colors <- colors[((seq_len(nrow(agg)) - 1) %% length(colors)) + 1]

      p <- plot_ly(
        agg,
        y = ~reorder(.data[[cat_col]], value),
        x = ~value,
        type = "bar",
        orientation = "h",
        marker = list(color = bar_colors)
      ) %>%
        layout(
          yaxis = list(title = "", ticksuffix = "  "),
          xaxis = list(title = val_col)
        )

      apply_theme_to_plotly(p, th, title = paste(val_col, "by", cat_col))
    })
  })
}
