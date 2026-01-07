library(mlr3verse)   
library(data.table)  
library(RSQLite)
library(ggplot2)

cat("========================================\n")
cat("从数据库读取K8数据进行分析\n")
cat("========================================\n\n")

db_file <- "GH_DB_LT.db"
con <- dbConnect(SQLite(), db_file)

query <- "SELECT * FROM KB ORDER BY ISSUE"
KB_Data <- dbGetQuery(con, query)

dbDisconnect(con)

cat(paste("读取数据成功，共", nrow(KB_Data), "条记录\n"))
cat(paste("期号范围:", min(KB_Data$ISSUE), "至", max(KB_Data$ISSUE), "\n\n"))

KB_Data <- as.data.table(KB_Data)
KB_Data[, DATES := as.Date(DATES)]

str(KB_Data)
head(KB_Data)

sum(is.na(KB_Data))

df_lagged <- copy(KB_Data)
lag_cols <- c(paste0("KB", 1:20), "POOL", "ISSUE")

for (col in lag_cols) {
  df_lagged[, paste0(col, "_lag1") := shift(.SD, n = 1, type = "lag"), .SDcols = col]
}

df_lagged <- na.omit(df_lagged)

features <- paste0(lag_cols, "_lag1")
targets <- paste0("KB", 1:20)

model_data <- df_lagged[, c(features, targets), with = FALSE]

cat(paste("创建滞后特征后，共", nrow(model_data), "条记录\n"))
cat(paste("特征变量数:", length(features), "\n"))
cat(paste("目标变量数:", length(targets), "\n\n"))

tasks <- list()
for (target in targets) {
  task <- TaskRegr$new(
    id = paste0("kb_", target),
    backend = model_data,
    target = target
  )
  tasks[[target]] <- task
}

print(paste("创建了", length(tasks), "个回归任务"))

set.seed(123)

nrow_data <- nrow(model_data)

train_rows <- sample(1:nrow_data, size = 0.7 * nrow_data)
test_rows <- setdiff(1:nrow_data, train_rows)

cat(paste("\n训练集:", length(train_rows), "条\n"))
cat(paste("测试集:", length(test_rows), "条\n\n"))

learners <- list()
for (target in targets) {
  cat(paste("正在训练", target, "模型...\n"))
  learner <- lrn("regr.ranger",
                  num.trees = 500,
                  mtry = 5,
                  importance = "impurity",
                  predict_type = "response"
  )
  learner$train(tasks[[target]], row_ids = train_rows)
  learners[[target]] <- learner
}

cat(paste("✓ 成功训练了", length(learners), "个模型\n"))

measures <- list(
  msr("regr.mse"),
  msr("regr.mae"),
  msr("regr.rsq")
)

predictions <- list()
performance_scores <- list()

for (target in targets) {
  cat(paste("正在预测", target, "...\n"))
  
  pred <- learners[[target]]$predict(tasks[[target]], row_ids = test_rows)
  predictions[[target]] <- pred
  
  perf <- pred$score(measures)
  performance_scores[[target]] <- perf
  
  cat(paste("  MSE:", round(perf["regr.mse"], 4), 
            "MAE:", round(perf["regr.mae"], 4),
            "R²:", round(perf["regr.rsq"], 4), "\n"))
}

avg_mse <- mean(sapply(performance_scores, function(x) x["regr.mse"]))
avg_mae <- mean(sapply(performance_scores, function(x) x["regr.mae"]))
avg_rsq <- mean(sapply(performance_scores, function(x) x["regr.rsq"]))

cat("\n========================================\n")
cat("平均性能指标:\n")
cat(paste("  平均MSE:", round(avg_mse, 4), "\n"))
cat(paste("  平均MAE:", round(avg_mae, 4), "\n"))
cat(paste("  平均R²:", round(avg_rsq, 4), "\n"))
cat("========================================\n")

true_kb1 <- predictions[["KB1"]]$truth
pred_kb1 <- predictions[["KB1"]]$response
plot_data <- data.frame(True = true_kb1, Predicted = pred_kb1)

p <- ggplot(plot_data, aes(x = True, y = Predicted)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "KB1预测值 vs 真实值",
       x = "真实值",
       y = "预测值") +
  theme_minimal()

ggsave("kb1_prediction_plot.png", p, width = 8, height = 6)
cat("\n✓ 预测图已保存到 kb1_prediction_plot.png\n")

cat("\n========================================\n")
cat("特征重要性分析（KB1）\n")
cat("========================================\n")

importance <- learners[["KB1"]]$importance()
importance_df <- data.frame(
  Feature = names(importance),
  Importance = importance
)
importance_df <- importance_df[order(-importance_df$Importance), ]
importance_df$Rank <- 1:nrow(importance_df)

print(head(importance_df, 10))

write.csv(importance_df, "kb1_feature_importance.csv", row.names = FALSE)
cat("\n✓ 特征重要性已保存到 kb1_feature_importance.csv\n")

cat("\n========================================\n")
cat("预测最新一期\n")
cat("========================================\n\n")

latest_data <- tail(df_lagged, 1)
latest_issue <- latest_data$ISSUE
cat(paste("最新期号:", latest_issue, "\n\n"))

latest_features <- latest_data[, ..features]
latest_predictions <- list()

for (target in targets) {
  pred <- learners[[target]]$predict_newdata(latest_features)
  latest_predictions[[target]] <- as.numeric(pred$response)
}

cat("预测下一期号码:\n")
prediction_df <- data.frame(
  KB = 1:20,
  Predicted = unlist(latest_predictions)
)
print(prediction_df)

write.csv(prediction_df, "next_issue_prediction.csv", row.names = FALSE)
cat("\n✓ 预测结果已保存到 next_issue_prediction.csv\n")

cat("\n========================================\n")
cat("分析完成！\n")
cat("========================================\n")
