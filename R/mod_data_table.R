data_table_ui <- function(id) {
  ns <- NS(id)
  reactableOutput(ns("themed_table"))
}

data_table_server <- function(id, data, theme) {
  moduleServer(id, function(input, output, session) {
    output$themed_table <- renderReactable({
      req(data(), theme())
      th <- theme()
      df <- data()
      header_tc <- th$textClasses$header
      label_tc  <- th$textClasses$label

      # Show a reasonable subset
      display_df <- head(df, 50)

      reactable(
        display_df,
        theme = reactableTheme(
          color             = th$foreground,
          backgroundColor   = th$background,
          borderColor        = adjust_alpha(th$foreground, 0.15),
          stripedColor       = adjust_alpha(th$tableAccent, 0.06),
          highlightColor     = adjust_alpha(th$tableAccent, 0.12),
          headerStyle        = list(
            fontFamily      = paste0(header_tc$fontFace, ", sans-serif"),
            fontSize        = paste0(header_tc$fontSize, "px"),
            color           = "#FFFFFF",
            backgroundColor = th$tableAccent,
            fontWeight      = 600,
            borderBottom     = paste0("2px solid ", th$tableAccent)
          ),
          cellStyle         = list(
            fontFamily = paste0(label_tc$fontFace, ", sans-serif"),
            fontSize   = paste0(label_tc$fontSize + 1, "px")
          )
        ),
        defaultPageSize = 8,
        striped         = TRUE,
        compact         = TRUE,
        highlight       = TRUE,
        bordered        = FALSE
      )
    })
  })
}
