library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(data.table)
library(DT)

ui <- dashboardPage(
  dashboardHeader(title = "SuperK8 - Prediction System"),
  
  dashboardSidebar(
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
      menuItem("Data Update", tabName = "data_update", icon = icon("refresh")),
      menuItem("Prediction", tabName = "prediction", icon = icon("chart-line")),
      menuItem("History", tabName = "history", icon = icon("history")),
      menuItem("Settings", tabName = "settings", icon = icon("cog"))
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
        fluidRow(
          box(
            title = "Quick Actions",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            fluidRow(
              column(3,
                actionButton("btn_update_data", "Update Data", 
                            icon = icon("refresh"),
                            class = "btn-primary btn-lg")
              ),
              column(3,
                actionButton("btn_prediction", "Run Prediction", 
                            icon = icon("chart-line"),
                            class = "btn-success btn-lg")
              ),
              column(3,
                actionButton("btn_autokb", "AutoKB (All)", 
                            icon = icon("bolt"),
                            class = "btn-warning btn-lg")
              ),
              column(3,
                actionButton("btn_git_push", "Git Push", 
                            icon = icon("upload"),
                            class = "btn-info btn-lg")
              )
            )
          )
        ),
        
        fluidRow(
          box(
            title = "Status",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("status_output")
          )
        ),
        
        fluidRow(
          box(
            title = "Execution Log",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            verbatimTextOutput("log_output", placeholder = TRUE)
          )
        )
      ),
      
      tabItem(tabName = "data_update",
        fluidRow(
          box(
            title = "Data Update",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            actionButton("btn_spider_kb", "Update KB Data", 
                        icon = icon("download"),
                        class = "btn-primary btn-lg"),
            br(), br(),
            verbatimTextOutput("spider_kb_output")
          )
        )
      ),
      
      tabItem(tabName = "prediction",
        fluidRow(
          box(
            title = "Prediction Settings",
            status = "primary",
            solidHeader = TRUE,
            width = 4,
            sliderInput("table_limit", "Number of Issues", 
                       min = 10, max = 200, value = 100),
            sliderInput("table_field", "Number of Fields", 
                       min = 6, max = 21, value = 21),
            actionButton("btn_run_prediction", "Run Prediction", 
                        icon = icon("play"),
                        class = "btn-success btn-lg")
          ),
          box(
            title = "Prediction Results",
            status = "success",
            solidHeader = TRUE,
            width = 8,
            verbatimTextOutput("prediction_output")
          )
        ),
        
        fluidRow(
          box(
            title = "Top 11 Predictions",
            status = "info",
            solidHeader = TRUE,
            width = 12,
            DTOutput("prediction_table")
          )
        )
      ),
      
      tabItem(tabName = "history",
        fluidRow(
          box(
            title = "Prediction History",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            DTOutput("history_table")
          )
        )
      ),
      
      tabItem(tabName = "settings",
        fluidRow(
          box(
            title = "Application Settings",
            status = "primary",
            solidHeader = TRUE,
            width = 12,
            textInput("rscript_path", "Rscript Path", 
                     value = "D:\\Program Files\\R\\R-4.5.2\\bin\\Rscript.exe"),
            textInput("working_dir", "Working Directory", 
                     value = "D:\\GitHub\\SuperK8"),
            actionButton("btn_save_settings", "Save Settings", 
                        icon = icon("save"),
                        class = "btn-primary"),
            br(), br(),
            verbatimTextOutput("settings_output")
          )
        )
      )
    )
  )
)

server <- function(input, output, session) {
  values <- reactiveValues(
    log = "",
    status = "Ready",
    predictions = NULL,
    history = NULL
  )
  
  observeEvent(input$btn_update_data, {
    values$status <- "Updating data..."
    values$log <- paste(values$log, "\n[", Sys.time(), "] Starting data update...", sep = "")
    
    tryCatch({
      source("SPIDER_KB.R", local = TRUE)
      result <- SPIDER_KB_Once()
      
      if (result$success > 0) {
        values$log <- paste(values$log, paste("\n[", Sys.time(), "] Successfully updated", result$success, "issues"), sep = "")
        values$status <- "Data updated successfully"
      } else if (result$skip > 0) {
        values$log <- paste(values$log, paste("\n[", Sys.time(), "] Skipped", result$skip, "issues (already exist)"), sep = "")
        values$status <- "Data is up to date"
      } else {
        values$log <- paste(values$log, paste("\n[", Sys.time(), "] Data is already up to date"), sep = "")
        values$status <- "Data is up to date"
      }
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
      values$status <- "Error updating data"
    })
  })
  
  observeEvent(input$btn_prediction, {
    values$status <- "Running prediction..."
    values$log <- paste(values$log, "\n[", Sys.time(), "] Starting prediction...", sep = "")
    
    tryCatch({
      source("GH_AN_LIST.R", local = TRUE)
      KB_Data <- GH_LIST_KB(4, input$table_limit, input$table_field)
      
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Loaded", nrow(KB_Data), "issues with", ncol(KB_Data), "fields"), sep = "")
      
      df_lagged <- copy(KB_Data)
      lag_cols <- c(paste0("KB", 1:20), "ISSUE")
      
      for (col in lag_cols) {
        df_lagged[, paste0(col, "_lag1") := shift(.SD, n = 1, type = "lag"), .SDcols = col]
      }
      
      df_lagged <- na.omit(df_lagged)
      
      features <- paste0(lag_cols, "_lag1")
      targets <- paste0("KB", 1:20)
      model_data <- df_lagged[, c(features, targets), with = FALSE]
      
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Preparing model with", nrow(model_data), "rows"), sep = "")
      
      library(mlr3verse)
      
      tasks <- list()
      for (target in targets) {
        task <- TaskRegr$new(
          id = paste0("kb_", target),
          backend = model_data,
          target = target
        )
        tasks[[target]] <- task
      }
      
      set.seed(123)
      nrow_data <- nrow(model_data)
      train_rows <- sample(1:nrow_data, size = 0.7 * nrow_data)
      
      learners <- list()
      for (target in targets) {
        learner <- lrn("regr.ranger",
                        num.trees = 500,
                        mtry = 5,
                        importance = "impurity",
                        predict_type = "response"
        )
        learner$train(tasks[[target]], row_ids = train_rows)
        learners[[target]] <- learner
      }
      
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Model training completed"), sep = "")
      
      latest_data <- KB_Data[nrow(KB_Data), ]
      current_issue <- latest_data$ISSUE
      next_issue <- current_issue + 1
      
      prediction_features <- data.table()
      for (col in lag_cols) {
        prediction_features[, paste0(col, "_lag1") := latest_data[[col]]]
      }
      
      for (target in targets) {
        prediction_features[, (target) := NA_real_]
      }
      
      prediction_features <- prediction_features[, c(features, targets), with = FALSE]
      
      predictions <- list()
      for (target in targets) {
        pred <- learners[[target]]$predict_newdata(prediction_features)
        predictions[[target]] <- round(as.numeric(pred$response))
      }
      
      pred_dt <- data.table(
        KB_Position = targets,
        Predicted_Number = unlist(predictions)
      )
      
      kb_performance <- c(
        "KB10" = 0.7806,
        "KB8" = 0.72,
        "KB9" = 0.713,
        "KB15" = 0.7146,
        "KB11" = 0.7544,
        "KB12" = 0.697,
        "KB7" = 0.6296,
        "KB6" = 0.659,
        "KB16" = 0.6164,
        "KB17" = 0.6311,
        "KB13" = 0.6959,
        "KB5" = 0.6028,
        "KB4" = 0.6975,
        "KB14" = 0.5544,
        "KB3" = 0.4404,
        "KB18" = 0.5159,
        "KB2" = 0.3137,
        "KB19" = 0.3342,
        "KB1" = 0.2225,
        "KB20" = 0.0875
      )
      
      pred_dt[, R2_Score := kb_performance[KB_Position]]
      pred_dt_sorted <- pred_dt[order(-R2_Score)]
      top_predictions <- pred_dt_sorted[1:11]
      
      values$predictions <- top_predictions
      values$status <- paste("Prediction completed for issue", next_issue)
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Prediction completed for issue", next_issue), sep = "")
      
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
      values$status <- "Error running prediction"
    })
  })
  
  observeEvent(input$btn_autokb, {
    values$status <- "Running AutoKB..."
    values$log <- paste(values$log, "\n[", Sys.time(), "] Starting AutoKB...", sep = "")
    
    tryCatch({
      source("AutoKB.R", local = TRUE)
      values$status <- "AutoKB completed"
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] AutoKB completed"), sep = "")
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
      values$status <- "Error running AutoKB"
    })
  })
  
  observeEvent(input$btn_git_push, {
    values$status <- "Pushing to Git..."
    values$log <- paste(values$log, "\n[", Sys.time(), "] Starting Git push...", sep = "")
    
    tryCatch({
      system('git add .')
      system('git commit -m "Update from Shiny app"')
      system('git push')
      values$status <- "Git push completed"
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Git push completed"), sep = "")
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
      values$status <- "Error pushing to Git"
    })
  })
  
  observeEvent(input$btn_spider_kb, {
    values$log <- paste(values$log, "\n[", Sys.time(), "] Starting KB data update...", sep = "")
    
    tryCatch({
      source("SPIDER_KB.R", local = TRUE)
      result <- SPIDER_KB_Once()
      
      output$spider_kb_output <- renderPrint({
        cat("Update Result:\n")
        cat(paste("Success:", result$success, "\n"))
        cat(paste("Skip:", result$skip, "\n"))
        cat(paste("Error:", result$error, "\n"))
      })
      
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] KB data update completed"), sep = "")
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
    })
  })
  
  observeEvent(input$btn_run_prediction, {
    values$log <- paste(values$log, "\n[", Sys.time(), "] Running prediction with custom settings...", sep = "")
    
    tryCatch({
      source("GH_AN_LIST.R", local = TRUE)
      KB_Data <- GH_LIST_KB(4, input$table_limit, input$table_field)
      
      output$prediction_output <- renderPrint({
        cat("Prediction Settings:\n")
        cat(paste("Number of Issues:", input$table_limit, "\n"))
        cat(paste("Number of Fields:", input$table_field, "\n"))
        cat(paste("Data Rows:", nrow(KB_Data), "\n"))
        cat(paste("Data Columns:", ncol(KB_Data), "\n"))
      })
      
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Prediction with custom settings completed"), sep = "")
    }, error = function(e) {
      values$log <- paste(values$log, paste("\n[", Sys.time(), "] Error:", e$message), sep = "")
    })
  })
  
  observeEvent(input$btn_save_settings, {
    values$log <- paste(values$log, paste("\n[", Sys.time(), "] Settings saved"), sep = "")
    output$settings_output <- renderPrint({
      cat("Settings Saved:\n")
      cat(paste("Rscript Path:", input$rscript_path, "\n"))
      cat(paste("Working Directory:", input$working_dir, "\n"))
    })
  })
  
  output$status_output <- renderText({
    values$status
  })
  
  output$log_output <- renderText({
    values$log
  })
  
  output$prediction_table <- renderDT({
    if (!is.null(values$predictions)) {
      values$predictions
    } else {
      data.table(
        KB_Position = character(),
        Predicted_Number = integer(),
        R2_Score = numeric()
      )
    }
  }, options = list(
    pageLength = 11,
    order = list(list(3, 'desc'))
  ))
  
  output$history_table <- renderDT({
    if (!is.null(values$history)) {
      values$history
    } else {
      data.table(
        Issue = character(),
        Date = character(),
        Top11 = character()
      )
    }
  }, options = list(
    pageLength = 10,
    order = list(list(1, 'desc'))
  ))
}

shinyApp(ui = ui, server = server)
