line_chart_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("chart"), height = "300px")
}

line_chart_server <- function(id, data, theme, col_map) {
  moduleServer(id, function(input, output, session) {
    output$chart <- renderPlotly({
      req(data(), theme(), col_map())
      df <- data()
      th <- theme()
      cm <- col_map()

      date_col <- cm$date
      val_col  <- cm$measure1
      series_col <- cm$series
      req(val_col)
      if (!val_col %in% names(df)) return(NULL)

      colors <- theme_colorway(th)

      # Use date column if available, otherwise fall back to category
      x_col <- if (!is.null(date_col) && date_col %in% names(df)) date_col else cm$category
      req(x_col)
      if (!x_col %in% names(df)) return(NULL)

      if (!is.null(series_col) && series_col %in% names(df)) {
        agg <- df %>%
          dplyr::group_by(dplyr::across(dplyr::all_of(c(x_col, series_col)))) %>%
          dplyr::summarise(value = sum(.data[[val_col]], na.rm = TRUE), .groups = "drop") %>%
          dplyr::arrange(.data[[x_col]])

        series_vals <- unique(agg[[series_col]])

        p <- plot_ly()
        for (i in seq_along(series_vals)) {
          s <- series_vals[i]
          sub <- agg[agg[[series_col]] == s, ]
          p <- p %>% add_lines(
            x = sub[[x_col]],
            y = sub$value,
            name = s,
            line = list(color = colors[((i - 1) %% length(colors)) + 1], width = 2)
          )
        }
      } else {
        agg <- df %>%
          dplyr::group_by(dplyr::across(dplyr::all_of(x_col))) %>%
          dplyr::summarise(value = sum(.data[[val_col]], na.rm = TRUE), .groups = "drop") %>%
          dplyr::arrange(.data[[x_col]])

        p <- plot_ly(
          agg,
          x = ~.data[[x_col]],
          y = ~value,
          type = "scatter",
          mode = "lines",
          line = list(color = colors[1], width = 2)
        )
      }

      p <- p %>% layout(
        xaxis = list(title = ""),
        yaxis = list(title = val_col)
      )

      apply_theme_to_plotly(p, th, title = paste(val_col, "over Time"))
    })
  })
}
