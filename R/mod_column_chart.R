column_chart_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("chart"), height = "300px")
}

column_chart_server <- function(id, data, theme, col_map) {
  moduleServer(id, function(input, output, session) {
    output$chart <- renderPlotly({
      req(data(), theme(), col_map())
      df <- data()
      th <- theme()
      cm <- col_map()

      cat_col <- cm$category
      val_col <- cm$measure1
      series_col <- cm$series
      req(cat_col, val_col)
      if (!cat_col %in% names(df) || !val_col %in% names(df)) return(NULL)

      colors <- theme_colorway(th)

      if (!is.null(series_col) && series_col %in% names(df)) {
        # Stacked column chart by series
        agg <- df %>%
          dplyr::group_by(dplyr::across(dplyr::all_of(c(cat_col, series_col)))) %>%
          dplyr::summarise(value = sum(.data[[val_col]], na.rm = TRUE), .groups = "drop")

        series_vals <- unique(agg[[series_col]])

        p <- plot_ly()
        for (i in seq_along(series_vals)) {
          s <- series_vals[i]
          sub <- agg[agg[[series_col]] == s, ]
          p <- p %>% add_bars(
            x = sub[[cat_col]],
            y = sub$value,
            name = s,
            marker = list(color = colors[((i - 1) %% length(colors)) + 1])
          )
        }
        p <- p %>% layout(barmode = "group", xaxis = list(title = ""), yaxis = list(title = val_col))
      } else {
        agg <- df %>%
          dplyr::group_by(dplyr::across(dplyr::all_of(cat_col))) %>%
          dplyr::summarise(value = sum(.data[[val_col]], na.rm = TRUE), .groups = "drop")

        bar_colors <- colors[((seq_len(nrow(agg)) - 1) %% length(colors)) + 1]

        p <- plot_ly(
          agg,
          x = ~.data[[cat_col]],
          y = ~value,
          type = "bar",
          marker = list(color = bar_colors)
        ) %>%
          layout(xaxis = list(title = ""), yaxis = list(title = val_col))
      }

      apply_theme_to_plotly(p, th, title = paste(val_col, "by", cat_col))
    })
  })
}
