library(shiny)

setwd("D:\\GitHub\\SuperK8")

cat("========================================\n")
cat("SuperK8 Shiny Application\n")
cat("========================================\n")
cat("Starting Shiny app...\n")
cat("Working directory: ", getwd(), "\n")
cat("========================================\n\n")

runApp("app.R", launch.browser = TRUE)
