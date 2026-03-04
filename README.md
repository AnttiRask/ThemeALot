# ThemeALot

**ThemeALot** is an open-source R Shiny app for previewing, creating, and accessibility-checking [Power BI theme files](https://learn.microsoft.com/en-us/power-bi/create-reports/desktop-report-themes) (`.json`) — without opening Power BI.

🌐 **[Try it live →](https://themealot.youcanbeapirate.com)**

---

## Features

### Preview
Upload your own `theme.json` or choose from all 24 built-in Power BI themes. See how the theme looks across the most common visuals:

- KPI cards
- Bar & column charts
- Line chart
- Pie / donut chart
- Scatter plot
- Data table

Use the built-in sample dataset or upload your own CSV with automatic column mapping.

### Create Theme
Build a complete Power BI theme from scratch using a guided form:

- Color pickers for background, foreground, table accent
- Dynamic data color palette (up to 12 colors)
- Sentiment colors (good / neutral / bad)
- Divergent color scale
- Per-class typography (label, title, callout, header)
- Global visual styles
- Live JSON preview
- One-click download as `theme.json`

### Accessibility Check
Upload any theme and get an instant report across 10 checks:

| Check | Standard |
|---|---|
| Foreground / background contrast | WCAG 1.4.3 |
| Data colors vs background | WCAG 1.4.11 |
| Table accent vs white text | WCAG 1.4.11 |
| Color distinctiveness (ΔE) | CIE76 |
| Deuteranopia simulation | ~6% of males |
| Protanopia simulation | ~2% of males |
| Tritanopia simulation | ~0.01% |
| Sentiment color conventions | Power BI docs |
| Palette size | ≥ 8 colors recommended |
| Text class sizes | Minimum readability |

Each check shows a pass / warning / fail badge with a summary, details, and a link to the relevant specification.

---

## Running locally

### With R

```r
# Install dependencies (first run only)
install.packages(c(
  "shiny", "bslib", "bsicons", "plotly", "reactable",
  "jsonlite", "dplyr", "lubridate", "colourpicker",
  "shinyjs", "colorspace"
))

# Run
shiny::runApp(".")
```

### With Docker

```bash
docker compose up
```

Then open [http://localhost:8080](http://localhost:8080).

---

## Tech stack

| Layer | Package |
|---|---|
| UI framework | [bslib](https://rstudio.github.io/bslib/) (Bootstrap 5 / Flatly) |
| Interactive charts | [plotly](https://plotly.com/r/) |
| Data table | [reactable](https://glin.github.io/reactable/) |
| Color pickers | [colourpicker](https://daattali.com/shiny/colourInput/) |
| CVD simulation | [colorspace](https://colorspace.r-forge.r-project.org/) |
| Hosting | [Google Cloud Run](https://cloud.google.com/run) |

---

## License

MIT © [Antti Rask](https://github.com/AnttiRask)
