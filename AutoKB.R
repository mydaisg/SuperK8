########### Auto KB Logic #######
# 自动执行KB数据更新和Prediction
# 1. 更新KB数据到最新Issue
# 2. 使用最新数据进行Prediction

library(mlr3verse)
library(data.table)

cat("========================================\n")
cat("AutoKB - 自动KB数据更新和Prediction\n")
cat("========================================\n\n")

# ---------------------------
# 步骤1: 更新KB数据
# ---------------------------
cat("步骤 1: 更新KB数据到最新Issue\n")
cat("----------------------------------------\n")
source("SPIDER_KB.R")
result <- SPIDER_KB_Once()

if (result$success > 0) {
  cat(paste("✓ 成功更新", result$success, "Issue数据\n"))
} else if (result$skip > 0) {
  cat(paste("✓ 跳过", result$skip, "Issue数据（已存在）\n"))
} else {
  cat("✓ 数据已是最新，无需更新\n")
}

cat("\n")

# ---------------------------
# 步骤2: 准备Prediction模型
# ---------------------------
cat("步骤 2: 准备Prediction模型\n")
cat("----------------------------------------\n")
source("GH_AN_LIST.R")

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

cat("✓ 模型训练完成\n\n")

# ---------------------------
# 步骤3: Prediction下一期号码
# ---------------------------
cat("步骤 3: Prediction NextIssue Number\n")
cat("----------------------------------------\n")

# 获取最新一期的数据作为Prediction输入
latest_data <- KB_Data[nrow(KB_Data), ]
current_issue <- latest_data$ISSUE
next_issue <- current_issue + 1

cat(paste("Current Issue:", current_issue, "\n"))
cat(paste("Prediction Issue:", next_issue, "\n\n"))

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

# 对每个KB字段进行Prediction
predictions <- list()
for (target in targets) {
  pred <- learners[[target]]$predict_newdata(prediction_features)
  predictions[[target]] <- round(as.numeric(pred$response))
}

# 创建Prediction结果数据表
pred_dt <- data.table(
  KB_Position = targets,
  Predicted_Number = unlist(predictions)
)

# 根据模型性能排序（基于之前的R²值）
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

# 选择前11个Prediction效果最好的号码
top_predictions <- pred_dt_sorted[1:11]

cat("Prediction Top11 Number（按R²值排序）:\n")
cat("----------------------------------------\n")
for (i in 1:nrow(top_predictions)) {
  cat(sprintf("%2d. %s: %2d  (R²=%.4f)\n", 
              i, 
              top_predictions$KB_Position[i], 
              as.integer(top_predictions$Predicted_Number[i]),
              top_predictions$R2_Score[i]))
}
cat("----------------------------------------\n\n")

# 按Prediction号码大小排序
cat("Prediction Sort Number:\n")
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

# 单独列出Top11，便于复制
cat("========================================\n")
cat("Top11 Prediction Number（便于复制）\n")
cat("========================================\n")
cat("按R²值排序:\n")
for (i in 1:nrow(top_predictions)) {
  cat(sprintf("%s:%d", 
              top_predictions$KB_Position[i], 
              as.integer(top_predictions$Predicted_Number[i])))
  if (i < nrow(top_predictions)) {
    cat(", ")
  }
  if (i %% 5 == 0) {
    cat("\n")
  }
}
cat("\n\n")

cat("Sort Number:\n")
sorted_numbers <- sort(as.integer(top_predictions$Predicted_Number))
for (i in 1:length(sorted_numbers)) {
  cat(sprintf("%d", sorted_numbers[i]))
  if (i < length(sorted_numbers)) {
    cat(", ")
  }
  if (i %% 5 == 0) {
    cat("\n")
  }
}
cat("\n")
cat("========================================\n\n")

# 显示所有20个Prediction结果
cat("所有20个位置的Prediction Number:\n")
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
cat("Prediction统计:\n")
cat("----------------------------------------\n")
cat(sprintf("Prediction Number范围: %d - %d\n", 
            min(as.integer(top_predictions$Predicted_Number)), 
            max(as.integer(top_predictions$Predicted_Number))))
cat(sprintf("Prediction Number平均值: %.2f\n", 
            mean(top_predictions$Predicted_Number)))
cat(sprintf("Prediction Number中位数: %d\n", 
            as.integer(median(top_predictions$Predicted_Number))))
cat("----------------------------------------\n")

cat("\n========================================\n")
cat("✓ AutoKB 执行完成\n")
cat("========================================\n")

# ---------------------------
# 步骤4: 保存预测结果到文件
# ---------------------------
cat("\n步骤 4: 保存预测结果到文件\n")
cat("----------------------------------------\n")

# 确保NextKB目录存在
if (!dir.exists("NextKB")) {
  dir.create("NextKB")
  cat("✓ 创建NextKB目录\n")
}

# 生成文件名
base_filename <- paste0("NextKB/", next_issue, ".txt")
filename <- base_filename
counter <- 1

# 如果文件已存在，添加数字后缀
while (file.exists(filename)) {
  filename <- paste0("NextKB/", next_issue, "_", counter, ".txt")
  counter <- counter + 1
}

# 准备文件内容
file_content <- ""
file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "AutoKB Prediction结果\n")
file_content <- paste0(file_content, "========================================\n\n")

file_content <- paste0(file_content, "Current Issue: ", current_issue, "\n")
file_content <- paste0(file_content, "Prediction Issue: ", next_issue, "\n\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "Top11 Prediction Number（便于复制）\n")
file_content <- paste0(file_content, "========================================\n\n")

file_content <- paste0(file_content, "按R²值排序:\n")
for (i in 1:nrow(top_predictions)) {
  file_content <- paste0(file_content, sprintf("%s:%d", 
              top_predictions$KB_Position[i], 
              as.integer(top_predictions$Predicted_Number[i])))
  if (i < nrow(top_predictions)) {
    file_content <- paste0(file_content, ", ")
  }
  if (i %% 5 == 0) {
    file_content <- paste0(file_content, "\n")
  }
}
file_content <- paste0(file_content, "\n\n")

file_content <- paste0(file_content, "Sort Number:\n")
sorted_numbers <- sort(as.integer(top_predictions$Predicted_Number))
for (i in 1:length(sorted_numbers)) {
  file_content <- paste0(file_content, sprintf("%d", sorted_numbers[i]))
  if (i < length(sorted_numbers)) {
    file_content <- paste0(file_content, ", ")
  }
  if (i %% 5 == 0) {
    file_content <- paste0(file_content, "\n")
  }
}
file_content <- paste0(file_content, "\n\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "Top11 Prediction Number（按R²值排序）\n")
file_content <- paste0(file_content, "========================================\n")
for (i in 1:nrow(top_predictions)) {
  file_content <- paste0(file_content, sprintf("%2d. %s: %2d  (R²=%.4f)\n", 
              i, 
              top_predictions$KB_Position[i], 
              as.integer(top_predictions$Predicted_Number[i]),
              top_predictions$R2_Score[i]))
}
file_content <- paste0(file_content, "\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "Sort Number:\n")
file_content <- paste0(file_content, "========================================\n")
pred_by_number <- top_predictions[order(Predicted_Number)]
for (i in 1:nrow(pred_by_number)) {
  file_content <- paste0(file_content, sprintf("%2d. %s: %2d  (R²=%.4f)\n", 
              i, 
              pred_by_number$KB_Position[i], 
              as.integer(pred_by_number$Predicted_Number[i]),
              pred_by_number$R2_Score[i]))
}
file_content <- paste0(file_content, "\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "所有20个位置的Prediction Number结果\n")
file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, sprintf("%-8s %6s %10s\n", "KB位置", "Prediction Number", "R²值"))
file_content <- paste0(file_content, "----------------------------------------\n")
for (i in 1:nrow(pred_dt_sorted)) {
  file_content <- paste0(file_content, sprintf("%-8s %6d %10.4f\n", 
              pred_dt_sorted$KB_Position[i], 
              as.integer(pred_dt_sorted$Predicted_Number[i]),
              pred_dt_sorted$R2_Score[i]))
}
file_content <- paste0(file_content, "\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "Prediction统计\n")
file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, sprintf("Prediction Number范围: %d - %d\n", 
            min(as.integer(top_predictions$Predicted_Number)), 
            max(as.integer(top_predictions$Predicted_Number))))
file_content <- paste0(file_content, sprintf("Prediction Number平均值: %.2f\n", 
            mean(top_predictions$Predicted_Number)))
file_content <- paste0(file_content, sprintf("Prediction Number中位数: %d\n", 
            as.integer(median(top_predictions$Predicted_Number))))
file_content <- paste0(file_content, "\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "生成时间: ", Sys.time(), "\n")
file_content <- paste0(file_content, "========================================\n")

# 写入文件
writeLines(file_content, filename)
cat(paste("✓ 预测结果已保存到:", filename, "\n"))
