COMMON_FONTS <- c(
  "Segoe UI", "Segoe UI Light", "Segoe UI Semibold", "Segoe UI Bold",
  "Arial", "Arial Black", "Calibri", "Cambria", "Century Gothic",
  "Consolas", "Corbel", "DIN", "Franklin Gothic Medium",
  "Georgia", "Helvetica", "Lato", "Montserrat", "Open Sans",
  "Roboto", "Times New Roman", "Trebuchet MS", "Verdana"
)

# ── UI ─────────────────────────────────────────────────────────────────────────

theme_creator_ui <- function(id) {
  ns <- NS(id)

  layout_columns(
    col_widths = c(6, 6),
    gap = "20px",

    # ── LEFT: Form ──────────────────────────────────────────────────────────────
    div(
      accordion(
        id = ns("accordion"),
        open = c("basic", "datacolors"),

        # ── Basic ──────────────────────────────────────────────────────────────
        accordion_panel(
          "Basic",
          value = "basic",
          icon  = bsicons::bs_icon("palette"),
          textInput(ns("name"), "Theme name", value = "My Theme"),
          colourpicker::colourInput(ns("background"),  "Background",       value = "#FFFFFF"),
          colourpicker::colourInput(ns("foreground"),  "Foreground / text", value = "#252423"),
          colourpicker::colourInput(ns("tableAccent"), "Table accent",     value = "#118DFF")
        ),

        # ── Data Colors ────────────────────────────────────────────────────────
        accordion_panel(
          "Data Colors",
          value = "datacolors",
          icon  = bsicons::bs_icon("droplet-fill"),
          p("Colors used for chart series, cycling when more series than colors.",
            class = "text-muted small"),
          uiOutput(ns("data_color_pickers")),
          div(
            style = "margin-top:10px;display:flex;gap:8px;",
            actionButton(ns("add_color"),    "Add color",    class = "btn btn-sm btn-outline-secondary",
                         icon = icon("plus")),
            actionButton(ns("remove_color"), "Remove last",  class = "btn btn-sm btn-outline-secondary",
                         icon = icon("minus"))
          )
        ),

        # ── Sentiment Colors ───────────────────────────────────────────────────
        accordion_panel(
          "Sentiment Colors",
          value  = "sentiment",
          icon   = bsicons::bs_icon("emoji-smile"),
          p("Used in KPIs, gauge needles, and conditional formatting.",
            class = "text-muted small"),
          colourpicker::colourInput(ns("good"),    "Good",    value = "#1EAB40"),
          colourpicker::colourInput(ns("neutral"), "Neutral", value = "#D9B300"),
          colourpicker::colourInput(ns("bad"),     "Bad",     value = "#D64550")
        ),

        # ── Divergent Colors ───────────────────────────────────────────────────
        accordion_panel(
          "Divergent Colors",
          value = "divergent",
          icon  = bsicons::bs_icon("arrow-left-right"),
          p("Used for diverging color scales (e.g. conditional formatting gradients).",
            class = "text-muted small"),
          colourpicker::colourInput(ns("div_min"),    "Minimum",       value = "#118DFF"),
          colourpicker::colourInput(ns("div_middle"), "Middle (opt.)", value = "#FFFFFF"),
          colourpicker::colourInput(ns("div_max"),    "Maximum",       value = "#D64550"),
          div(
            style = "margin-top:8px;",
            checkboxInput(ns("div_include_middle"), "Include middle color in output", value = FALSE)
          )
        ),

        # ── Text Classes ───────────────────────────────────────────────────────
        accordion_panel(
          "Text Classes",
          value = "textclasses",
          icon  = bsicons::bs_icon("type"),
          p("Defines font, size, and color for each text role.",
            class = "text-muted small"),
          navset_tab(
            nav_panel("Label",   text_class_ui(ns, "label",   "#252423", 9,  "Segoe UI")),
            nav_panel("Title",   text_class_ui(ns, "title",   "#252423", 12, "Segoe UI Semibold")),
            nav_panel("Callout", text_class_ui(ns, "callout", "#252423", 28, "Segoe UI Light")),
            nav_panel("Header",  text_class_ui(ns, "header",  "#252423", 12, "Segoe UI Semibold"))
          )
        ),

        # ── Global Visual Styles ───────────────────────────────────────────────
        accordion_panel(
          "Global Visual Styles",
          value = "visualstyles",
          icon  = bsicons::bs_icon("grid-1x2"),
          p("Applied to all visuals via visualStyles[\"*\"][\"*\"].",
            class = "text-muted small"),

          tags$h6("Background", class = "mt-2 fw-semibold"),
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:12px;",
            div(colourpicker::colourInput(ns("vs_bg_color"), "Color", value = "#FFFFFF")),
            div(numericInput(ns("vs_bg_transparency"), "Transparency (0–100)", value = 0, min = 0, max = 100))
          ),

          tags$h6("Border", class = "mt-3 fw-semibold"),
          checkboxInput(ns("vs_border_show"), "Show border", value = FALSE),
          colourpicker::colourInput(ns("vs_border_color"), "Color", value = "#000000"),
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:12px;",
            div(numericInput(ns("vs_border_radius"), "Radius (px)", value = 0, min = 0, max = 50)),
            div(numericInput(ns("vs_border_width"),  "Width (px)",  value = 1, min = 1, max = 20))
          ),

          tags$h6("Shadow", class = "mt-3 fw-semibold"),
          checkboxInput(ns("vs_shadow_show"), "Show shadow", value = FALSE),
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:12px;",
            div(colourpicker::colourInput(ns("vs_shadow_color"), "Color", value = "#000000")),
            div(numericInput(ns("vs_shadow_transparency"), "Transparency (0–100)", value = 60, min = 0, max = 100)),
            div(selectInput(ns("vs_shadow_position"), "Position",
                            choices = c("Center" = "center", "Top" = "top", "Bottom" = "bottom"),
                            selected = "center")),
            div(numericInput(ns("vs_shadow_blur"), "Blur (px)", value = 10, min = 0, max = 100))
          ),

          tags$h6("Title", class = "mt-3 fw-semibold"),
          checkboxInput(ns("vs_title_show"), "Show visual title", value = TRUE),
          selectInput(ns("vs_title_font"), "Font",
                      choices = COMMON_FONTS, selected = "Segoe UI Semibold"),
          div(
            style = "display:grid;grid-template-columns:1fr 1fr;gap:12px;",
            div(numericInput(ns("vs_title_size"),  "Size (pt)", value = 12, min = 6, max = 72)),
            div(colourpicker::colourInput(ns("vs_title_color"), "Color", value = "#252423"))
          )
        )
      ) # end accordion
    ), # end left column

    # ── RIGHT: JSON output + download ──────────────────────────────────────────
    div(
      card(
        card_header(
          div(
            style = "display:flex;justify-content:space-between;align-items:center;padding:4px 0;",
            span("theme.json", style = "font-family:monospace;font-weight:600;"),
            downloadButton(ns("download"), "Download .json",
                           class = "btn btn-sm btn-primary",
                           style = "margin-left:24px;")
          )
        ),
        card_body(
          style = "padding:0;",
          verbatimTextOutput(ns("json_preview"))
        )
      )
    )
  )
}

# ── Helper: single text class form block ───────────────────────────────────────

text_class_ui <- function(ns, prefix, default_color, default_size, default_font) {
  div(
    style = "padding:12px 4px;",
    div(
      style = "display:grid;grid-template-columns:2fr 1fr;gap:12px;",
      div(selectInput(ns(paste0(prefix, "_font")), "Font family",
                      choices  = COMMON_FONTS,
                      selected = default_font)),
      div(numericInput(ns(paste0(prefix, "_size")), "Size (pt)",
                       value = default_size, min = 6, max = 72))
    ),
    div(colourpicker::colourInput(ns(paste0(prefix, "_color")), "Color",
                                  value = default_color))
  )
}

# ── Server ─────────────────────────────────────────────────────────────────────

theme_creator_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    DEFAULT_DATA_COLORS <- c(
      "#118DFF", "#12239E", "#E66C37", "#6B007B",
      "#E044A7", "#744EC2", "#D9B300", "#D64550",
      "#197278", "#1AAB40", "#4472C4", "#A5A5A5"
    )

    # Stores the authoritative color list; re-rendering uses these values
    stored_colors <- reactiveVal(DEFAULT_DATA_COLORS[1:8])

    # Snapshot current inputs, then append a new default color
    observeEvent(input$add_color, {
      cols <- stored_colors()
      n <- length(cols)
      if (n < 12) {
        current <- vapply(seq_len(n), function(i) {
          input[[paste0("dc_", i)]] %||% cols[i]
        }, character(1))
        stored_colors(c(current, DEFAULT_DATA_COLORS[min(n + 1, length(DEFAULT_DATA_COLORS))]))
      }
    })

    # Snapshot current inputs, then drop the last color
    observeEvent(input$remove_color, {
      cols <- stored_colors()
      n <- length(cols)
      if (n > 1) {
        current <- vapply(seq_len(n), function(i) {
          input[[paste0("dc_", i)]] %||% cols[i]
        }, character(1))
        stored_colors(current[-n])
      }
    })

    output$data_color_pickers <- renderUI({
      cols <- stored_colors()
      ns   <- session$ns
      rows <- lapply(seq_along(cols), function(i) {
        colourpicker::colourInput(
          inputId = ns(paste0("dc_", i)),
          label   = paste("Color", i),
          value   = cols[i]
        )
      })
      div(
        style = "display:grid;grid-template-columns:repeat(2,1fr);gap:10px;",
        rows
      )
    })

    # ── Build the theme list ───────────────────────────────────────────────────
    built_theme <- reactive({
      cols <- stored_colors()
      n    <- length(cols)

      data_colors <- vapply(seq_len(n), function(i) {
        input[[paste0("dc_", i)]] %||% cols[i]
      }, character(1))

      theme <- list(
        name        = input$name %||% "My Theme",
        dataColors  = as.list(data_colors),
        background  = input$background  %||% "#FFFFFF",
        foreground  = input$foreground  %||% "#252423",
        tableAccent = input$tableAccent %||% "#118DFF",
        good        = input$good        %||% "#1EAB40",
        neutral     = input$neutral     %||% "#D9B300",
        bad         = input$bad         %||% "#D64550",
        textClasses = list(
          label   = build_text_class(input, "label"),
          title   = build_text_class(input, "title"),
          callout = build_text_class(input, "callout"),
          header  = build_text_class(input, "header")
        )
      )

      # Divergent colors
      div_list <- list(
        minimum = input$div_min %||% "#118DFF",
        maximum = input$div_max %||% "#D64550"
      )
      if (isTRUE(input$div_include_middle)) {
        div_list$middle <- input$div_middle %||% "#FFFFFF"
      }
      theme$divergentColors <- div_list

      # Visual styles — only include sections where user turned on non-default options
      vs_star <- list()

      vs_bg <- list(
        color        = input$vs_bg_color         %||% "#FFFFFF",
        transparency = input$vs_bg_transparency  %||% 0
      )
      vs_star$background <- list(vs_bg)

      if (isTRUE(input$vs_border_show)) {
        vs_star$border <- list(list(
          show   = TRUE,
          color  = input$vs_border_color  %||% "#000000",
          radius = input$vs_border_radius %||% 0,
          width  = input$vs_border_width  %||% 1
        ))
      } else {
        vs_star$border <- list(list(show = FALSE))
      }

      if (isTRUE(input$vs_shadow_show)) {
        vs_star$shadow <- list(list(
          show         = TRUE,
          color        = input$vs_shadow_color        %||% "#000000",
          transparency = input$vs_shadow_transparency %||% 60,
          position     = input$vs_shadow_position     %||% "center",
          blur         = input$vs_shadow_blur         %||% 10
        ))
      } else {
        vs_star$shadow <- list(list(show = FALSE))
      }

      vs_star$title <- list(list(
        show       = isTRUE(input$vs_title_show),
        fontFamily = input$vs_title_font  %||% "Segoe UI Semibold",
        fontSize   = input$vs_title_size  %||% 12,
        color      = list(solid = list(color = input$vs_title_color %||% "#252423"))
      ))

      theme$visualStyles <- list(`*` = list(`*` = vs_star))

      theme
    })

    # ── JSON output ────────────────────────────────────────────────────────────
    output$json_preview <- renderText({
      jsonlite::toJSON(built_theme(), pretty = TRUE, auto_unbox = TRUE)
    })

    output$download <- downloadHandler(
      filename = function() {
        name <- gsub("[^A-Za-z0-9_-]", "_", input$name %||% "my_theme")
        paste0(name, ".json")
      },
      content = function(file) {
        json <- jsonlite::toJSON(built_theme(), pretty = TRUE, auto_unbox = TRUE)
        writeLines(json, file)
      }
    )
  })
}

# ── Helpers ────────────────────────────────────────────────────────────────────

build_text_class <- function(input, prefix) {
  defaults <- list(
    label   = list(fontFace = "Segoe UI",          fontSize = 9,  color = "#252423"),
    title   = list(fontFace = "Segoe UI Semibold", fontSize = 12, color = "#252423"),
    callout = list(fontFace = "Segoe UI Light",    fontSize = 28, color = "#252423"),
    header  = list(fontFace = "Segoe UI Semibold", fontSize = 12, color = "#252423")
  )[[prefix]]

  list(
    fontFace = input[[paste0(prefix, "_font")]]  %||% defaults$fontFace,
    fontSize = input[[paste0(prefix, "_size")]]  %||% defaults$fontSize,
    color    = input[[paste0(prefix, "_color")]] %||% defaults$color
  )
}
