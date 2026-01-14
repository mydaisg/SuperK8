library(mlr3verse)
library(data.table)
source("GH_AN_LIST.R")

# ---------------------------
# 加载训练好的模型
# ---------------------------
# 重新训练模型（在实际应用中，可以保存和加载训练好的模型）
cat("正在准备预测模型...\n")

# 获取数据
KB_Data <- GH_LIST_KB(4, 100, 21)

# 创建滞后特征
df_lagged <- copy(KB_Data)
lag_cols <- c(paste0("KB", 1:20), "ISSUE")

for (col in lag_cols) {
  df_lagged[, paste0(col, "_lag1") := shift(.SD, n = 1, type = "lag"), .SDcols = col]
}

# 移除第一行
df_lagged <- na.omit(df_lagged)

# 创建特征和目标变量
features <- paste0(lag_cols, "_lag1")
targets <- paste0("KB", 1:20)
model_data <- df_lagged[, c(features, targets), with = FALSE]

# 创建任务
tasks <- list()
for (target in targets) {
  task <- TaskRegr$new(
    id = paste0("kb_", target),
    backend = model_data,
    target = target
  )
  tasks[[target]] <- task
}

# 训练模型
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

cat("✓ 模型准备完成\n\n")

# ---------------------------
# 预测下一期号码
# ---------------------------
cat("========================================\n")
cat("预测NextIssue\n")
cat("========================================\n\n")

# 获取最新一期的数据作为预测输入
latest_data <- KB_Data[nrow(KB_Data), ]  # 最后一行是最新的数据
current_issue <- latest_data$ISSUE
next_issue <- current_issue + 1

cat(paste("Current Issue:", current_issue, "\n"))
cat(paste("Next Issue:", next_issue, "\n\n"))

# 创建预测特征（使用最新一期的滞后值）
prediction_features <- data.table()
for (col in lag_cols) {
  prediction_features[, paste0(col, "_lag1") := latest_data[[col]]]
}

# 添加目标变量列（设置为NA，预测时会被忽略）
for (target in targets) {
  prediction_features[, (target) := NA_real_]
}

# 确保特征列的顺序与训练时一致
prediction_features <- prediction_features[, c(features, targets), with = FALSE]

# 对每个KB字段进行预测
predictions <- list()
for (target in targets) {
  pred <- learners[[target]]$predict_newdata(prediction_features)
  predictions[[target]] <- round(as.numeric(pred$response))
}

# 创建预测结果数据表
pred_dt <- data.table(
  KB_Position = targets,
  Predicted_Number = unlist(predictions)
)

# 根据模型性能排序（基于之前的R²值）
# R²值从高到低排序的KB字段
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

# 添加R²值到预测结果
pred_dt[, R2_Score := kb_performance[KB_Position]]

# 按R²值降序排序
pred_dt_sorted <- pred_dt[order(-R2_Score)]

# 选择前11个预测效果最好的号码
top_predictions <- pred_dt_sorted[1:11]

cat("预测效果Top11（按R²值排序）:\n")
cat("----------------------------------------\n")
for (i in 1:nrow(top_predictions)) {
  cat(sprintf("%2d. %s: %2d  (R²=%.4f)\n", 
              i, 
              top_predictions$KB_Position[i], 
              as.integer(top_predictions$Predicted_Number[i]),
              top_predictions$R2_Score[i]))
}
cat("----------------------------------------\n\n")

# 按预测号码大小排序
cat("按预测Sort Number:\n")
cat("----------------------------------------\n")
pred_by_number <- top_predictions[order(Predicted_Number)]
for (i in 1:nrow(pred_by_number)) {
  cat(sprintf("%2d. %s: %2d  (R²=%.4f)\n", 
              i, 
              pred_by_number$KB_Position[i], 
              as.integer(pred_by_number$Predicted_Number[i]),
              pred_by_number$R2_Score[i]))
}
cat("----------------------------------------\n\n")

# 显示所有20个预测结果
cat("所有20个位置的预测结果:\n")
cat("----------------------------------------\n")
cat(sprintf("%-8s %6s %10s\n", "KB_Position", "NextNumber", "R²值"))
cat("----------------------------------------\n")
for (i in 1:nrow(pred_dt_sorted)) {
  cat(sprintf("%-8s %6d %10.4f\n", 
              pred_dt_sorted$KB_Position[i], 
              as.integer(pred_dt_sorted$Predicted_Number[i]),
              pred_dt_sorted$R2_Score[i]))
}
cat("----------------------------------------\n\n")

# 统计信息
cat("预测统计:\n")
cat("----------------------------------------\n")
cat(sprintf("预测号码范围: %d - %d\n", 
            min(as.integer(top_predictions$Predicted_Number)), 
            max(as.integer(top_predictions$Predicted_Number))))
cat(sprintf("预测号码平均值: %.2f\n", 
            mean(top_predictions$Predicted_Number)))
cat(sprintf("预测号码中位数: %d\n", 
            as.integer(median(top_predictions$Predicted_Number))))
cat("----------------------------------------\n")

cat("\n✓ 预测完成\n")
