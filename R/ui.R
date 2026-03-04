app_ui <- function() {
  page_navbar(
    title = "ThemeALot",
    theme = bs_theme(
      version  = 5,
      bootswatch = "flatly"
    ),

    # ── Tab 1: Preview ───────────────────────────────────────────────────────
    nav_panel(
      "Preview",
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
