# Typography Preview Module

# Map proprietary fonts to web font alternatives
map_font_to_web <- function(font_name) {
  font_map <- list(
    "Comic Sans MS" = "'Comic Neue', 'Comic Sans MS'",
    "Segoe UI" = "'Open Sans', 'Segoe UI'",
    "Segoe UI Light" = "'Open Sans', 'Segoe UI Light'",
    "Segoe UI Semibold" = "'Open Sans', 'Segoe UI Semibold'",
    "Calibri" = "'Lato', 'Calibri'",
    "Cambria" = "'Source Serif Pro', 'Cambria'",
    "Consolas" = "'Inconsolata', 'Consolas'",
    "Courier New" = "'Courier Prime', 'Courier New'",
    "Arial" = "'Roboto', 'Arial'",
    "Verdana" = "'Open Sans', 'Verdana'",
    "Trebuchet MS" = "'Open Sans', 'Trebuchet MS'",
    "Georgia" = "'Source Serif Pro', 'Georgia'",
    "Times New Roman" = "'Source Serif Pro', 'Times New Roman'",
    "Impact" = "'Arial Black', 'Impact'"
  )

  if (font_name %in% names(font_map)) {
    return(font_map[[font_name]])
  }
  sprintf("'%s'", font_name)
}

typography_preview_ui <- function(id) {
 ns <- NS(id)
 uiOutput(ns("preview"))
}

typography_preview_server <- function(id, theme) {
 moduleServer(id, function(input, output, session) {
   output$preview <- renderUI({
     req(theme())
     th <- theme()
     tc <- th$textClasses

     title_font <- tc$title$fontFace %||% "Segoe UI"
     title_size <- tc$title$fontSize %||% 12
     title_color <- tc$title$color %||% th$foreground

     callout_font <- tc$callout$fontFace %||% "Segoe UI Light"
     callout_size <- tc$callout$fontSize %||% 28
     callout_color <- tc$callout$color %||% th$foreground

     label_font <- tc$label$fontFace %||% "Segoe UI"
     label_size <- tc$label$fontSize %||% 9
     label_color <- tc$label$color %||% th$foreground

     # Map fonts to web alternatives
     title_font_css <- map_font_to_web(title_font)
     callout_font_css <- map_font_to_web(callout_font)
     label_font_css <- map_font_to_web(label_font)

     div(
       style = "display:flex;flex-direction:column;gap:8px;",
       # Title preview
       div(
         class = "card-title",
         style = sprintf(
           "font-family:%s,sans-serif;font-size:%dpx;color:%s;margin:0;",
           title_font_css, round(title_size * 1.5), title_color
         ),
         "Typography Preview"
       ),
       # Callout preview
       div(
         style = sprintf(
           "font-family:%s,sans-serif;font-size:%dpx;color:%s;",
           callout_font_css, callout_size, callout_color
         ),
         sprintf("%s %dpt", callout_font, callout_size)
       ),
       # Label preview
       div(
         style = sprintf(
           "font-family:%s,sans-serif;font-size:%dpx;color:%s;opacity:0.8;",
           label_font_css, round(label_size * 1.2), label_color
         ),
         sprintf("Label: %s %dpt  |  Title: %s %dpt", label_font, label_size, title_font, title_size)
       )
     )
   })
 })
}
