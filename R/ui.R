app_ui <- function() {
  page_navbar(
    title = "ThemeALot",
    theme = bs_theme(
      version = 5,
      bg = "#191414",
      fg = "#FFFFFF",
      primary = "#C1272D",
      secondary = "#C1272D",
      base_font = font_link(
        family = "Gotham",
        href = "https://fonts.cdnfonts.com/css/gotham-6"
      )
    ),
    header = tagList(
      tags$link(rel = "shortcut icon", type = "image/png", href = "favicon.png"),
      # Google Fonts for Power BI theme preview (fallbacks for proprietary MS fonts)
      tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
      tags$link(rel = "preconnect", href = "https://fonts.gstatic.com", crossorigin = NA),
      tags$link(
        rel = "stylesheet",
        href = "https://fonts.googleapis.com/css2?family=Comic+Neue:wght@300;400;700&family=Open+Sans:wght@300;400;600;700&family=Roboto:wght@300;400;500;700&family=Lato:wght@300;400;700&family=Source+Sans+3:wght@300;400;600;700&family=Noto+Sans:wght@300;400;600;700&family=IBM+Plex+Sans:wght@300;400;500;600;700&family=Inconsolata&family=Source+Code+Pro&family=Courier+Prime&display=swap"
      ),
      includeCSS("www/custom.css")
    ),

    # ── Tab 1: Preview Theme ─────────────────────────────────────────────────
    nav_panel(
      "Preview Theme",
      icon = bsicons::bs_icon("eye"),

      layout_sidebar(
        sidebar = sidebar(
          width = 320,
          title = "Settings",
          theme_selector_ui("theme"),
          hr(),
          data_manager_ui("data")
        ),

        # Dynamic CSS injected from theme
        uiOutput("dynamic_css"),

        # Report canvas
        div(
          class = "report-canvas",

          # Row 0: Typography preview
          div(
            style = "margin-bottom:16px;",
            div(class = "visual-card", typography_preview_ui("typography"))
          ),

          # Row 1: KPI cards
          div(
            style = "display:grid;grid-template-columns:repeat(3,1fr);gap:16px;",
            div(class = "visual-card", card_kpi_ui("kpi_revenue")),
            div(class = "visual-card", card_kpi_ui("kpi_units")),
            div(class = "visual-card", card_kpi_ui("kpi_profit"))
          ),

          # Row 2: Bar + Column
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:16px;",
            div(class = "visual-card", bar_chart_ui("bar")),
            div(class = "visual-card", column_chart_ui("col"))
          ),

          # Row 3: Line (full width)
          div(
            style = "margin-top:16px;",
            div(class = "visual-card", line_chart_ui("line"))
          ),

          # Row 4: Pie + Scatter
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:16px;margin-top:16px;",
            div(class = "visual-card", pie_chart_ui("pie")),
            div(class = "visual-card", scatter_plot_ui("scatter"))
          ),

          # Row 5: Table (full width)
          div(
            style = "margin-top:16px;",
            div(class = "visual-card", data_table_ui("table"))
          )
        )
      )
    ),

    # ── Tab 2: Create Theme ──────────────────────────────────────────────────
    nav_panel(
      "Create Theme",
      icon = bsicons::bs_icon("pencil-square"),
      div(
        style = "padding:20px;",
        theme_creator_ui("creator")
      )
    ),

    # ── Tab 3: Accessibility Checker ─────────────────────────────────────────
    nav_panel(
      "Accessibility Check",
      icon = bsicons::bs_icon("shield-check"),
      div(
        style = "padding:20px;",
        accessibility_checker_ui("accessibility")
      )
    )
  )
}
