scatter_plot_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("chart"), height = "300px")
}

scatter_plot_server <- function(id, data, theme, col_map) {
  moduleServer(id, function(input, output, session) {
    output$chart <- renderPlotly({
      req(data(), theme(), col_map())
      df <- data()
      th <- theme()
      cm <- col_map()

      x_col <- cm$measure1
      y_col <- cm$measure2 %||% cm$measure1
      series_col <- cm$series
      req(x_col, y_col)
      if (!x_col %in% names(df) || !y_col %in% names(df)) return(NULL)

      colors <- theme_colorway(th)

      if (!is.null(series_col) && series_col %in% names(df)) {
        series_vals <- unique(df[[series_col]])

        p <- plot_ly()
        for (i in seq_along(series_vals)) {
          s <- series_vals[i]
          sub <- df[df[[series_col]] == s, ]
          p <- p %>% add_markers(
            x = sub[[x_col]],
            y = sub[[y_col]],
            name = s,
            marker = list(
              color = colors[((i - 1) %% length(colors)) + 1],
              size = 7,
              opacity = 0.7
            )
          )
        }
      } else {
        p <- plot_ly(
          df,
          x = ~.data[[x_col]],
          y = ~.data[[y_col]],
          type = "scatter",
          mode = "markers",
          marker = list(color = colors[1], size = 7, opacity = 0.7)
        )
      }

      p <- p %>% layout(
        xaxis = list(title = x_col),
        yaxis = list(title = y_col)
      )

      apply_theme_to_plotly(p, th, title = paste(y_col, "vs", x_col))
    })
  })
}
