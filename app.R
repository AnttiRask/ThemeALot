library(shiny)
library(bslib)
library(bsicons)
library(shinyjs)
library(plotly)
library(reactable)
library(jsonlite)
library(dplyr)
library(lubridate)
library(colourpicker)
library(colorspace)

# Source themes first (needed by other modules)
source("themes/builtin_themes.R")

# Source all R modules
for (f in list.files("R", full.names = TRUE, pattern = "\\.R$")) {
  source(f)
}

shinyApp(ui = app_ui(), server = app_server)
