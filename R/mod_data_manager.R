# Data manager module - provides sample data for preview visualizations
# CSV upload has been removed for security reasons (to prevent users from
# accidentally uploading sensitive data to the hosted application)

data_manager_ui <- function(id) {
  ns <- NS(id)
  tagList(
    tags$p(
      class = "text-muted small",
      "Using built-in sample dataset for preview."
    )
  )
}

data_manager_server <- function(id) {

  moduleServer(id, function(input, output, session) {

    sample_df <- generate_sample_data()

    current_data <- reactive({
      sample_df
    })

    col_map <- reactive({
      list(
        category = "Product",
        series   = "Region",
        date     = "Date",
        measure1 = "Revenue",
        measure2 = "Profit"
      )
    })

    list(data = current_data, col_map = col_map)
  })
}
