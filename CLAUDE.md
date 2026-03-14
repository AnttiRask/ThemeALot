# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

ThemeALot is an R Shiny app for previewing, creating, and accessibility-checking Power BI theme files (`.json`). Live at https://themealot.youcanbeapirate.com.

## Running the App

```r
# Local (requires R packages listed in Dockerfile)
shiny::runApp(".")

# Docker
docker compose up
# Then open http://localhost:8080
```

## Deployment

```bash
./deploy.sh  # Deploys to Google Cloud Run (requires gcloud CLI)
```

Project: `chrome-duality-445915-b5`, region: `europe-north1`, service: `themalot`.

## Architecture

The app uses a **Shiny module pattern** with three tabs:

1. **Preview Theme** — upload or select a built-in theme, see it applied to sample visuals (KPI cards, charts, table)
2. **Create Theme** — form-based theme builder with live JSON preview and download
3. **Accessibility Check** — WCAG contrast checks, color vision deficiency simulation, palette analysis

### Key Files

- `app.R` — entry point; sources `themes/` first, then all `R/*.R` files alphabetically
- `R/ui.R` — `app_ui()` defines the three-tab layout using bslib's `page_navbar`
- `R/server.R` — `app_server()` wires modules together; `current_theme` reactive flows to all visual modules
- `R/theme_parser.R` — parses theme JSON with input sanitization (`sanitize_color`, `sanitize_font_face`, etc.) to prevent CSS/XSS injection
- `R/theme_applicator.R` — `apply_theme_to_plotly()` styles plotly charts; `generate_canvas_css()` generates dynamic CSS from theme
- `R/mod_theme_selector.R` — theme upload/selection module, drives the `current_theme` reactive
- `R/mod_theme_creator.R` — form-based theme builder
- `R/mod_accessibility_checker.R` — WCAG checks, CVD simulation using colorspace
- `R/sample_data.R` — built-in sample dataset
- `R/mod_data_manager.R` — data upload and column mapping
- `themes/builtin_themes.R` — all 24 built-in Power BI themes as R lists (sourced before R/ modules)

### Data Flow

`theme_selector_server` → returns `current_theme` reactive → consumed by all chart/table modules and `generate_canvas_css()`. Each chart module (`mod_bar_chart.R`, `mod_line_chart.R`, etc.) follows the same pattern: `*_ui(id)` / `*_server(id, data, theme, col_map)`.

## Tech Stack

- UI: bslib (Bootstrap 5), plotly (charts), reactable (tables), colourpicker
- Color utilities: colorspace (CVD simulation), col2hex2col (hex↔name)
- Container: rocker/r-ver:4.4.2 base image with Microsoft fonts

## Conventions

- All modules follow `mod_*.R` naming with `*_ui(id)` / `*_server(id, ...)` functions
- Theme data is a normalized R list (see `parse_theme_json` output structure): `name`, `dataColors`, `background`, `foreground`, `tableAccent`, `good/neutral/bad`, `textClasses` (label/title/callout/header each with fontFace/fontSize/color)
- All user-supplied theme values go through `sanitize_*` functions in `theme_parser.R` before use
- CSS is in `www/custom.css`; dynamic theme CSS is injected via `renderUI` in `server.R`
