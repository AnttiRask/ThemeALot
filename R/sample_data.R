generate_sample_data <- function() {
  set.seed(42)

  products <- c("Laptop", "Monitor", "Keyboard", "Mouse", "Headset", "Webcam")
  regions  <- c("North", "South", "East", "West")
  months   <- seq.Date(as.Date("2025-01-01"), as.Date("2025-12-01"), by = "month")

  df <- expand.grid(
    Product = products,
    Region  = regions,
    Date    = months,
    stringsAsFactors = FALSE
  )

  n <- nrow(df)
  df$Revenue <- round(runif(n, 5000, 50000), 2)
  df$Units   <- sample(10:500, n, replace = TRUE)
  df$Cost    <- round(df$Revenue * runif(n, 0.4, 0.7), 2)
  df$Profit  <- df$Revenue - df$Cost

  df
}
