card_kpi_ui <- function(id) {
  ns <- NS(id)
  uiOutput(ns("kpi_card"))
}

card_kpi_server <- function(id, data, theme, measure_col, label_text) {
  moduleServer(id, function(input, output, session) {
    output$kpi_card <- renderUI({
      req(data(), theme(), measure_col())
      th <- theme()
      df <- data()
      col <- measure_col()

      if (!col %in% names(df)) return(NULL)

      callout <- th$textClasses$callout
      label   <- th$textClasses$label

      value <- sum(df[[col]], na.rm = TRUE)

      # Format based on magnitude
      if (abs(value) >= 1e6) {
        formatted <- paste0(formatC(value / 1e6, format = "f", digits = 1, big.mark = ","), "M")
      } else if (abs(value) >= 1e3) {
        formatted <- paste0(formatC(value / 1e3, format = "f", digits = 1, big.mark = ","), "K")
      } else {
        formatted <- formatC(value, format = "f", digits = 0, big.mark = ",")
      }

      div(
        style = sprintf("text-align:center;padding:20px 10px;background-color:%s;", th$background),
        div(
          style = sprintf(
            "font-family:'%s',sans-serif;font-size:%dpx;color:%s;line-height:1.2;font-weight:300;",
            callout$fontFace, callout$fontSize, callout$color
          ),
          formatted
        ),
        div(
          style = sprintf(
            "font-family:'%s',sans-serif;font-size:%dpx;color:%s;margin-top:6px;opacity:0.8;",
            label$fontFace, label$fontSize + 2, label$color
          ),
          label_text()
        )
      )
    })
  })
}
