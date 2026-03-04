pie_chart_ui <- function(id) {
  ns <- NS(id)
  plotlyOutput(ns("chart"), height = "300px")
}

pie_chart_server <- function(id, data, theme, col_map) {
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
        dplyr::arrange(dplyr::desc(value))

      colors <- theme_colorway(th)
      label_tc <- th$textClasses$label

      p <- plot_ly(
        agg,
        labels = ~.data[[cat_col]],
        values = ~value,
        type = "pie",
        hole = 0.4,
        marker = list(
          colors = colors[((seq_len(nrow(agg)) - 1) %% length(colors)) + 1],
          line = list(color = th$background, width = 2)
        ),
        textfont = list(
          family = paste0(label_tc$fontFace, ", sans-serif"),
          size = label_tc$fontSize * 1.2,
          color = label_tc$color
        ),
        textinfo = "percent+label",
        hoverinfo = "label+value+percent"
      ) %>%
        layout(
          paper_bgcolor = th$background,
          showlegend = TRUE,
          legend = list(
            font = list(
              family = paste0(label_tc$fontFace, ", sans-serif"),
              size = label_tc$fontSize * 1.2,
              color = label_tc$color
            ),
            bgcolor = "rgba(0,0,0,0)"
          ),
          title = list(
            text = paste(val_col, "Distribution"),
            font = list(
              family = paste0(th$textClasses$title$fontFace, ", sans-serif"),
              size = th$textClasses$title$fontSize * 1.5,
              color = th$textClasses$title$color
            ),
            x = 0.02,
            xanchor = "left"
          ),
          margin = list(t = 50, b = 20, l = 20, r = 20)
        ) %>%
        plotly::config(displayModeBar = FALSE)

      p
    })
  })
}
