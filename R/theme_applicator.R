adjust_alpha <- function(hex_color, alpha) {
  rgb_vals <- col2rgb(hex_color)
  sprintf("rgba(%d,%d,%d,%.2f)", rgb_vals[1], rgb_vals[2], rgb_vals[3], alpha)
}

theme_color <- function(theme, index) {
  colors <- theme$dataColors
  colors[((index - 1) %% length(colors)) + 1]
}

theme_colorway <- function(theme) {
  theme$dataColors
}

apply_theme_to_plotly <- function(p, theme, title = NULL) {
  title_tc <- theme$textClasses$title
  label_tc <- theme$textClasses$label

  p <- p %>% plotly::layout(
    paper_bgcolor = theme$background,
    plot_bgcolor  = theme$background,

    title = if (!is.null(title)) list(
      text = title,
      font = list(
        family = paste0(title_tc$fontFace, ", sans-serif"),
        size   = title_tc$fontSize * 1.5,
        color  = title_tc$color
      ),
      x = 0.02,
      xanchor = "left"
    ),

    xaxis = list(
      tickfont  = list(family = paste0(label_tc$fontFace, ", sans-serif"),
                       size = label_tc$fontSize * 1.2,
                       color = label_tc$color),
      titlefont = list(family = paste0(label_tc$fontFace, ", sans-serif"),
                       size = label_tc$fontSize * 1.4,
                       color = label_tc$color),
      gridcolor = adjust_alpha(theme$foreground, 0.1),
      zerolinecolor = adjust_alpha(theme$foreground, 0.15)
    ),

    yaxis = list(
      tickfont  = list(family = paste0(label_tc$fontFace, ", sans-serif"),
                       size = label_tc$fontSize * 1.2,
                       color = label_tc$color),
      titlefont = list(family = paste0(label_tc$fontFace, ", sans-serif"),
                       size = label_tc$fontSize * 1.4,
                       color = label_tc$color),
      gridcolor = adjust_alpha(theme$foreground, 0.1),
      zerolinecolor = adjust_alpha(theme$foreground, 0.15)
    ),

    legend = list(
      font = list(family = paste0(label_tc$fontFace, ", sans-serif"),
                  size = label_tc$fontSize * 1.2,
                  color = label_tc$color),
      bgcolor = "rgba(0,0,0,0)"
    ),

    margin = list(t = 50, b = 40, l = 60, r = 20)
  )

  p <- p %>% plotly::config(displayModeBar = FALSE)
  p
}

generate_canvas_css <- function(theme) {
  bg  <- theme$background
  fg  <- theme$foreground
  ttl <- theme$textClasses$title
  lbl <- theme$textClasses$label
  cal <- theme$textClasses$callout

  # Determine if background is dark for card styling
  bg_rgb <- col2rgb(bg)
  is_dark <- mean(bg_rgb) < 128
  card_border <- if (is_dark) adjust_alpha("#FFFFFF", 0.15) else adjust_alpha(fg, 0.12)

  sprintf("
    .report-canvas {
      background-color: %s;
      padding: 16px;
      min-height: 80vh;
      font-family: '%s', sans-serif;
      color: %s;
    }
    .visual-card {
      background-color: %s;
      border: 1px solid %s;
      border-radius: 6px;
      padding: 14px;
    }
    .visual-card .card-title {
      font-family: '%s', sans-serif;
      font-size: %dpx;
      color: %s;
      margin-bottom: 8px;
      font-weight: 600;
    }
    .visual-card .kpi-value {
      font-family: '%s', sans-serif;
      font-size: %dpx;
      color: %s;
    }
    .visual-card .kpi-label {
      font-family: '%s', sans-serif;
      font-size: %dpx;
      color: %s;
    }
    .sidebar-section-title {
      font-weight: 600;
      margin-bottom: 8px;
    }
  ", bg, lbl$fontFace, fg, bg, card_border,
     ttl$fontFace, ttl$fontSize, ttl$color,
     cal$fontFace, cal$fontSize, cal$color,
     lbl$fontFace, lbl$fontSize, lbl$color)
}
