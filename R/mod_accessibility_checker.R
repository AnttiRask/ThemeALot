# ── Accessibility Checker Module ──────────────────────────────────────────────

# ── UI ────────────────────────────────────────────────────────────────────────

accessibility_checker_ui <- function(id) {
  ns <- NS(id)
  tagList(
    layout_columns(
      col_widths = c(4, 8),
      gap = "16px",

      card(
        card_header(bsicons::bs_icon("file-earmark-arrow-up"), " Upload Theme File"),
        card_body(
          fileInput(ns("theme_file"), NULL, accept = ".json",
                    buttonLabel = "Browse...", placeholder = "No file selected"),
          p("Upload a Power BI theme.json to run accessibility checks.",
            class = "text-muted small mb-0")
        )
      ),

      card(
        card_header(bsicons::bs_icon("clipboard-check"), " Summary"),
        card_body(uiOutput(ns("summary")))
      )
    ),

    uiOutput(ns("results"))
  )
}

# ── Server ────────────────────────────────────────────────────────────────────

accessibility_checker_server <- function(id) {
  moduleServer(id, function(input, output, session) {

    theme_data <- reactive({
      req(input$theme_file)
      tryCatch(
        parse_theme_json(input$theme_file$datapath),
        error = function(e) {
          showNotification(paste("Invalid theme file:", e$message), type = "error")
          NULL
        }
      )
    })

    check_results <- reactive({
      req(theme_data())
      run_all_checks(theme_data())
    })

    output$summary <- renderUI({
      req(check_results())
      cr  <- check_results()
      n_pass  <- sum(sapply(cr, function(x) x$status == "pass"))
      n_warn  <- sum(sapply(cr, function(x) x$status == "warn"))
      n_fail  <- sum(sapply(cr, function(x) x$status == "fail"))
      n_total <- length(cr)

      tagList(
        div(
          style = "display:flex;gap:8px;flex-wrap:wrap;margin-bottom:12px;",
          tags$span(class = "badge bg-success fs-6",   paste(n_pass, "Passed")),
          tags$span(class = "badge bg-warning fs-6", style = "color:#212529;", paste(n_warn, "Warnings")),
          tags$span(class = "badge bg-danger fs-6",    paste(n_fail, "Failed"))
        ),
        div(
          class = "progress",
          style = "height:10px;border-radius:6px;overflow:hidden;",
          div(class = "progress-bar bg-success",
              style = sprintf("width:%.0f%%", 100 * n_pass  / n_total)),
          div(class = "progress-bar bg-warning",
              style = sprintf("width:%.0f%%", 100 * n_warn  / n_total)),
          div(class = "progress-bar bg-danger",
              style = sprintf("width:%.0f%%", 100 * n_fail  / n_total))
        )
      )
    })

    output$results <- renderUI({
      req(check_results())
      sections <- list(
        "Contrast"      = 1:3,
        "Color Distinctiveness" = 4:7,
        "Sentiment & General"   = 8:10
      )
      tagList(lapply(names(sections), function(sec_name) {
        idx <- sections[[sec_name]]
        tagList(
          tags$h6(sec_name,
                  style = "margin:20px 0 8px;font-weight:700;text-transform:uppercase;
                           letter-spacing:.05em;font-size:11px;color:#6c757d;"),
          tagList(lapply(check_results()[idx], render_check_card))
        )
      }))
    })
  })
}

# ── Rendering helpers ─────────────────────────────────────────────────────────

render_check_card <- function(result) {
  border_col <- switch(result$status,
    pass = "#198754", warn = "#ffc107", fail = "#dc3545")
  badge <- switch(result$status,
    pass = tags$span(class = "badge bg-success",            "\u2713 Pass"),
    warn = tags$span(class = "badge bg-warning", style = "color:#212529;", "\u26A0 Warning"),
    fail = tags$span(class = "badge bg-danger",             "\u2717 Fail"))

  card(
    style = sprintf("border-left:4px solid %s;margin-bottom:10px;", border_col),
    card_header(
      div(
        style = "display:flex;justify-content:space-between;align-items:center;width:100%;gap:24px;",
        tags$strong(result$title),
        div(style = "flex-shrink:0;", badge)
      )
    ),
    card_body(
      p(result$summary, class = "text-muted small mb-2"),
      result$details
    )
  )
}

learn_more <- function(url, label = "Learn more") {
  tags$a(label, href = url, target = "_blank", rel = "noopener noreferrer",
         class = "small", style = "display:inline-block;margin-top:6px;")
}

color_swatches <- function(colors, size = 26) {
  swatches <- lapply(seq_along(colors), function(i) {
    tags$div(
      title = sprintf("Color %d: %s", i, colors[i]),
      style = sprintf(
        "display:inline-flex;width:%dpx;height:%dpx;background:%s;
         border-radius:4px;border:1px solid rgba(0,0,0,0.12);",
        size, size, colors[i]
      )
    )
  })
  div(style = "display:flex;flex-wrap:wrap;gap:4px;", swatches)
}

# ── Color math helpers ────────────────────────────────────────────────────────

wcag_luminance <- function(hex) {
  rgb <- col2rgb(hex)[, 1] / 255
  lin <- ifelse(rgb <= 0.03928, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  0.2126 * lin[[1]] + 0.7152 * lin[[2]] + 0.0722 * lin[[3]]
}

wcag_contrast <- function(hex1, hex2) {
  l1 <- wcag_luminance(hex1); l2 <- wcag_luminance(hex2)
  (max(l1, l2) + 0.05) / (min(l1, l2) + 0.05)
}

wcag_level <- function(ratio) {
  if (ratio >= 7)   "AAA"
  else if (ratio >= 4.5) "AA"
  else if (ratio >= 3)   "AA Large"
  else               "Fail"
}

hex_to_lab <- function(hex) {
  rgb <- col2rgb(hex)[, 1] / 255
  lin <- ifelse(rgb <= 0.04045, rgb / 12.92, ((rgb + 0.055) / 1.055)^2.4)
  x <- 0.4124564 * lin[[1]] + 0.3575761 * lin[[2]] + 0.1804375 * lin[[3]]
  y <- 0.2126729 * lin[[1]] + 0.7151522 * lin[[2]] + 0.0721750 * lin[[3]]
  z <- 0.0193339 * lin[[1]] + 0.1191920 * lin[[2]] + 0.9503041 * lin[[3]]
  x <- x / 0.95047; z <- z / 1.08883
  f <- function(t) ifelse(t > 0.008856, t^(1/3), 7.787 * t + 16 / 116)
  c(L = 116 * f(y) - 16, a = 500 * (f(x) - f(y)), b = 200 * (f(y) - f(z)))
}

delta_e <- function(hex1, hex2) {
  tryCatch(sqrt(sum((hex_to_lab(hex1) - hex_to_lab(hex2))^2)), error = function(e) NA_real_)
}

hex_hue <- function(hex) {
  rgb <- col2rgb(hex)[, 1] / 255
  r <- rgb[[1]]; g <- rgb[[2]]; b <- rgb[[3]]
  cmax <- max(r, g, b); cmin <- min(r, g, b); d <- cmax - cmin
  if (d == 0) return(0)
  hue <- if (cmax == r) 60 * (((g - b) / d) %% 6)
         else if (cmax == g) 60 * ((b - r) / d + 2)
         else 60 * ((r - g) / d + 4)
  hue %% 360
}

simulate_cvd <- function(colors, type) {
  tryCatch(
    switch(type,
      deutan = colorspace::deutan(colors, severity = 1),
      protan = colorspace::protan(colors, severity = 1),
      tritan = colorspace::tritan(colors, severity = 1)
    ),
    error = function(e) NULL
  )
}

pairwise_issues <- function(orig_colors, sim_colors, threshold_warn = 15, threshold_fail = 10) {
  n <- length(orig_colors)
  issues <- list()
  for (i in seq_len(n - 1)) {
    for (j in seq(i + 1, n)) {
      orig_de <- delta_e(orig_colors[i], orig_colors[j])
      sim_de  <- delta_e(sim_colors[i],  sim_colors[j])
      if (!is.na(orig_de) && !is.na(sim_de) && orig_de >= threshold_warn && sim_de < threshold_warn) {
        issues[[length(issues) + 1]] <- list(i = i, j = j, orig_de = orig_de, sim_de = sim_de)
      }
    }
  }
  issues
}

# ── Individual checks ─────────────────────────────────────────────────────────

check_fg_bg_contrast <- function(theme) {
  fg <- theme$foreground; bg <- theme$background
  ratio <- wcag_contrast(fg, bg)
  status <- if (ratio >= 4.5) "pass" else if (ratio >= 3) "warn" else "fail"

  details <- tagList(
    div(
      style = "display:flex;align-items:center;gap:12px;margin-bottom:8px;",
      div(style = sprintf("width:28px;height:28px;background:%s;border-radius:4px;border:1px solid rgba(0,0,0,0.1);", fg)),
      div(style = sprintf("width:28px;height:28px;background:%s;border-radius:4px;border:1px solid rgba(0,0,0,0.1);", bg)),
      tags$span(
        sprintf("%.2f:1 — WCAG %s", ratio, wcag_level(ratio)),
        class = if (ratio >= 4.5) "text-success" else if (ratio >= 3) "text-warning" else "text-danger"
      )
    ),
    p(sprintf("%s (foreground) on %s (background)", fg, bg), class = "text-muted small mb-1"),
    p("WCAG AA requires 4.5:1 for body text, 3:1 for large text (18pt+).", class = "text-muted small mb-0"),
    learn_more("https://www.w3.org/WAI/WCAG21/Understanding/contrast-minimum.html",
               "WCAG 1.4.3: Contrast (Minimum)")
  )

  list(title = "Foreground / Background Contrast", status = status,
       summary = sprintf("%.2f:1 contrast ratio — %s", ratio, wcag_level(ratio)),
       details = details)
}

check_data_bg_contrast <- function(theme) {
  bg <- theme$background; colors <- theme$dataColors
  ratios <- sapply(colors, function(col) tryCatch(wcag_contrast(col, bg), error = function(e) NA_real_))
  failing <- which(!is.na(ratios) & ratios < 3)
  warning  <- which(!is.na(ratios) & ratios >= 3 & ratios < 4.5)
  status <- if (length(failing) > 0) "fail" else if (length(warning) > 0) "warn" else "pass"

  rows <- lapply(seq_along(colors), function(i) {
    r <- ratios[i]
    if (is.na(r)) return(NULL)
    cls <- if (r >= 4.5) "text-success" else if (r >= 3) "text-warning" else "text-danger"
    div(
      style = "display:flex;align-items:center;gap:8px;margin-bottom:4px;",
      div(style = sprintf("width:18px;height:18px;background:%s;border-radius:3px;border:1px solid rgba(0,0,0,0.1);flex-shrink:0;", colors[i])),
      tags$code(style = "font-size:11px;min-width:80px;", colors[i]),
      tags$span(sprintf("%.2f:1 — %s", r, wcag_level(r)), class = paste(cls, "small"))
    )
  })

  details <- tagList(
    div(rows),
    p("WCAG 1.4.11 (Non-text contrast) requires 3:1 for chart elements on the background.", class = "text-muted small mt-2 mb-0"),
    learn_more("https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html",
               "WCAG 1.4.11: Non-text Contrast")
  )

  list(title = "Data Colors vs Background Contrast", status = status,
       summary = sprintf("%d / %d colors meet 3:1 contrast against the background",
                         length(colors) - length(failing), length(colors)),
       details = details)
}

check_table_accent_contrast <- function(theme) {
  accent <- theme$tableAccent; bg <- theme$background
  white_ratio <- tryCatch(wcag_contrast(accent, "#FFFFFF"), error = function(e) NA_real_)
  bg_ratio    <- tryCatch(wcag_contrast(accent, bg),        error = function(e) NA_real_)
  status <- if (is.na(white_ratio)) "warn"
            else if (white_ratio >= 4.5) "pass"
            else if (white_ratio >= 3)   "warn"
            else "fail"

  details <- tagList(
    div(
      style = "display:flex;align-items:center;gap:12px;margin-bottom:10px;",
      div(
        style = sprintf("padding:6px 14px;background:%s;color:white;border-radius:4px;font-size:13px;font-weight:600;", accent),
        "Table Header"
      ),
      if (!is.na(white_ratio))
        tags$span(sprintf("%.2f:1 with white text — %s", white_ratio, wcag_level(white_ratio)),
                  class = if (white_ratio >= 4.5) "text-success small" else if (white_ratio >= 3) "text-warning small" else "text-danger small")
    ),
    p(sprintf("Table accent: %s | vs white text: %s | vs background: %s",
              accent,
              if (!is.na(white_ratio)) sprintf("%.2f:1", white_ratio) else "—",
              if (!is.na(bg_ratio))    sprintf("%.2f:1", bg_ratio)    else "—"),
      class = "text-muted small mb-0"),
    learn_more("https://www.w3.org/WAI/WCAG21/Understanding/non-text-contrast.html",
               "WCAG 1.4.11: Non-text Contrast")
  )

  list(title = "Table Accent / Header Contrast", status = status,
       summary = sprintf("Table accent %s — %.2f:1 against white text", accent, white_ratio %||% 0),
       details = details)
}

check_data_distinctiveness <- function(theme) {
  colors <- theme$dataColors; n <- length(colors)
  pairs_fail <- list(); pairs_warn <- list()

  for (i in seq_len(n - 1)) {
    for (j in seq(i + 1, n)) {
      de <- delta_e(colors[i], colors[j])
      if (!is.na(de)) {
        if (de < 10)       pairs_fail[[length(pairs_fail) + 1]] <- list(i=i, j=j, de=de)
        else if (de < 20)  pairs_warn[[length(pairs_warn) + 1]] <- list(i=i, j=j, de=de)
      }
    }
  }

  status <- if (length(pairs_fail) > 0) "fail" else if (length(pairs_warn) > 0) "warn" else "pass"

  issue_rows <- c(
    lapply(pairs_fail, function(p) p(class = "text-danger small mb-1",
      sprintf("\u274C Colors %d & %d are very similar (ΔE = %.1f)", p$i, p$j, p$de))),
    lapply(pairs_warn, function(p) p(class = "text-warning small mb-1",
      sprintf("\u26A0 Colors %d & %d may be confused (ΔE = %.1f)", p$i, p$j, p$de)))
  )

  details <- tagList(
    color_swatches(colors),
    div(
      style = "margin-top:10px;",
      if (length(issue_rows) == 0)
        p("\u2705 All color pairs are clearly distinct (ΔE \u2265 20).", class = "text-success small mb-0")
      else
        tagList(issue_rows)
    ),
    p("Guideline: ΔE \u2265 20 = clearly distinct; ΔE < 10 = very hard to tell apart.", class = "text-muted small mt-2 mb-0"),
    learn_more("https://colorbrewer2.org/", "ColorBrewer: Color advice for cartography"),
    tags$span(" · ", class = "small text-muted"),
    learn_more("https://www.vis4.net/palettes/", "Vis4 Palette Designer")
  )

  list(title = "Data Color Distinctiveness (Normal Vision)", status = status,
       summary = sprintf("%d colors — %d problematic pair(s)",
                         n, length(pairs_fail) + length(pairs_warn)),
       details = details)
}

check_cvd <- function(theme, type) {
  type_labels <- c(
    deutan = "Deuteranopia (red-green, ~6% of males)",
    protan = "Protanopia (red-green, ~2% of males)",
    tritan = "Tritanopia (blue-yellow, ~0.01%)"
  )
  type_links <- c(
    deutan = "https://www.color-blindness.com/deuteranopia-red-green-color-blindness/",
    protan = "https://www.color-blindness.com/protanopia-red-green-color-blindness/",
    tritan = "https://www.color-blindness.com/tritanopia-blue-yellow-color-blindness/"
  )
  colors     <- theme$dataColors
  sim_colors <- simulate_cvd(colors, type)

  if (is.null(sim_colors)) {
    return(list(title = type_labels[[type]], status = "warn",
                summary = "Simulation unavailable",
                details = p("colorspace package error during simulation.", class = "text-muted small")))
  }

  issues <- pairwise_issues(colors, sim_colors)
  status <- if (any(sapply(issues, function(x) x$sim_de < 10))) "fail"
            else if (length(issues) > 0) "warn"
            else "pass"

  issue_rows <- lapply(issues, function(p) {
    sev <- if (p$sim_de < 10) list(icon = "\u274C", cls = "text-danger") else list(icon = "\u26A0", cls = "text-warning")
    p(class = paste(sev$cls, "small mb-1"),
      sprintf("%s Colors %d & %d: ΔE %.0f \u2192 %.0f after simulation",
              sev$icon, p$i, p$j, p$orig_de, p$sim_de))
  })

  details <- tagList(
    div(
      style = "display:flex;gap:20px;align-items:flex-start;flex-wrap:wrap;margin-bottom:10px;",
      div(
        tags$small("Original", class = "text-muted d-block mb-1"),
        color_swatches(colors)
      ),
      div(style = "padding-top:20px;color:#adb5bd;font-size:18px;", "\u2192"),
      div(
        tags$small("Simulated", class = "text-muted d-block mb-1"),
        color_swatches(sim_colors)
      )
    ),
    if (length(issue_rows) == 0)
      p("\u2705 All colors remain distinguishable under this condition.", class = "text-success small mb-0")
    else
      tagList(issue_rows),
    learn_more(type_links[[type]], paste("About", type_labels[[type]]))
  )

  list(title = type_labels[[type]], status = status,
       summary = if (length(issues) == 0) "All color pairs remain distinguishable"
                 else sprintf("%d pair(s) become difficult to distinguish", length(issues)),
       details = details)
}

check_sentiment <- function(theme) {
  good    <- theme$good    %||% "#1EAB40"
  neutral <- theme$neutral %||% "#D9B300"
  bad     <- theme$bad     %||% "#D64550"
  issues  <- character(0)

  good_hue <- hex_hue(good)
  if (!(good_hue >= 80 && good_hue <= 175))
    issues <- c(issues, sprintf("\u26A0 'Good' hue is %.0f\u00B0 — expected green (80–175\u00B0)", good_hue))

  bad_hue <- hex_hue(bad)
  if (!((bad_hue <= 30) || (bad_hue >= 330)))
    issues <- c(issues, sprintf("\u26A0 'Bad' hue is %.0f\u00B0 — expected red (0–30\u00B0 or 330–360\u00B0)", bad_hue))

  gb_de <- delta_e(good, bad)
  if (!is.na(gb_de) && gb_de < 20)
    issues <- c(issues, sprintf("\u26A0 'Good' and 'Bad' are too similar (ΔE = %.1f, need \u2265 20)", gb_de))

  gn_ratio <- tryCatch(wcag_contrast(good, neutral), error = function(e) NA_real_)
  if (!is.na(gn_ratio) && gn_ratio < 2)
    issues <- c(issues, sprintf("\u26A0 'Good' and 'Neutral' have low contrast (%.1f:1)", gn_ratio))

  status <- if (length(issues) == 0) "pass" else "warn"

  details <- tagList(
    div(
      style = "display:flex;gap:16px;margin-bottom:10px;",
      lapply(list(list(good, "Good"), list(neutral, "Neutral"), list(bad, "Bad")), function(x) {
        div(style = "text-align:center;",
            div(style = sprintf("width:36px;height:36px;background:%s;border-radius:6px;border:1px solid rgba(0,0,0,0.1);margin:0 auto 4px;", x[[1]])),
            tags$small(x[[2]], class = "text-muted"),
            div(tags$code(style = "font-size:10px;", x[[1]]))
        )
      })
    ),
    if (length(issues) == 0)
      p("\u2705 Sentiment colors follow expected conventions.", class = "text-success small mb-0")
    else
      tagList(lapply(issues, function(i) p(i, class = "small mb-1"))),
    learn_more("https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-report-themes#set-structural-colors",
               "Power BI docs: Structural theme colors")
  )

  list(title = "Sentiment Colors", status = status,
       summary = if (length(issues) == 0) "Good / Neutral / Bad colors follow conventions"
                 else sprintf("%d issue(s) with sentiment colors", length(issues)),
       details = details)
}

check_palette_size <- function(theme) {
  n      <- length(theme$dataColors)
  status <- if (n >= 8) "pass" else if (n >= 6) "warn" else "fail"

  list(title = "Data Color Palette Size", status = status,
       summary = sprintf("%d data color(s) defined (recommended: \u2265 8)", n),
       details = tagList(
         color_swatches(theme$dataColors),
         p(sprintf("%d color(s) defined. With fewer than 8, charts with many series will cycle and reuse colors.", n),
           class = "text-muted small mt-2 mb-0"),
         learn_more("https://colorbrewer2.org/", "ColorBrewer: Palette size guidance")
       ))
}

check_text_sizes <- function(theme) {
  tc     <- theme$textClasses
  issues <- character(0)
  mins   <- list(label = 8, title = 10, callout = 16, header = 9)

  for (nm in names(mins)) {
    sz <- tc[[nm]]$fontSize
    if (!is.null(sz) && sz < mins[[nm]])
      issues <- c(issues, sprintf("\u26A0 %s font size is %dpt (minimum: %dpt)",
                                  tools::toTitleCase(nm), sz, mins[[nm]]))
  }

  status <- if (length(issues) == 0) "pass" else "warn"

  rows <- lapply(names(tc), function(nm) {
    cls <- tc[[nm]]
    div(
      style = "display:flex;align-items:center;gap:8px;margin-bottom:4px;",
      div(style = sprintf("width:12px;height:12px;background:%s;border-radius:2px;flex-shrink:0;",
                          cls$color %||% "#252423")),
      tags$span(paste0(tools::toTitleCase(nm), ":"),
                style = "min-width:70px;font-size:13px;"),
      tags$span(sprintf("%s, %dpt", cls$fontFace %||% "\u2014", cls$fontSize %||% 0),
                class = "small text-muted")
    )
  })

  details <- tagList(
    div(rows),
    div(style = "margin-top:8px;",
        if (length(issues) == 0)
          p("\u2705 All text sizes meet minimum readability thresholds.", class = "text-success small mb-0")
        else
          tagList(lapply(issues, function(i) p(i, class = "small mb-1")))
    ),
    learn_more("https://www.w3.org/WAI/WCAG21/Understanding/resize-text.html",
               "WCAG 1.4.4: Resize Text")
  )

  list(title = "Text Class Sizes", status = status,
       summary = if (length(issues) == 0) "All text class sizes are within acceptable range"
                 else sprintf("%d text size issue(s) found", length(issues)),
       details = details)
}

# ── Run all checks ────────────────────────────────────────────────────────────

run_all_checks <- function(theme) {
  list(
    check_fg_bg_contrast(theme),
    check_data_bg_contrast(theme),
    check_table_accent_contrast(theme),
    check_data_distinctiveness(theme),
    check_cvd(theme, "deutan"),
    check_cvd(theme, "protan"),
    check_cvd(theme, "tritan"),
    check_sentiment(theme),
    check_palette_size(theme),
    check_text_sizes(theme)
  )
}
