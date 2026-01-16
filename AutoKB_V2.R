########### AutoKB V2 - 改进版 #######
# 改进内容：
# 1. 修复数据泄露问题 - 使用时间序列划分
# 2. 扩展特征工程 - 添加多期滞后特征（lag1-lag5）
# 3. 添加统计特征（和值、跨度、均值等）
# 4. 动态计算R²值
# 5. 增加数据量
# 6. 添加号码去重和范围验证

library(mlr3verse)
library(data.table)

cat("========================================\n")
cat("AutoKB V2 - 改进版\n")
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
# 步骤2: 准备Prediction模型（改进版）
# ---------------------------
cat("步骤 2: 准备Prediction模型（改进版）\n")
cat("----------------------------------------\n")
source("GH_AN_LIST.R")

# 获取所有可用数据
KB_Data <- GH_LIST_KB(4, 10000, 21)
cat(paste("✓ 获取到", nrow(KB_Data), "期历史数据\n"))

# 创建扩展的滞后特征
df_lagged <- copy(KB_Data)
kb_cols <- paste0("KB", 1:20)

# 添加多期滞后特征（lag1-lag5）
cat("创建多期滞后特征（lag1-lag5）...\n")
for (lag in 1:5) {
  for (col in c(kb_cols, "ISSUE")) {
    col_name <- paste0(col, "_lag", lag)
    df_lagged[, (col_name) := shift(get(col), n = lag, type = "lag")]
  }
}

# 添加统计特征
cat("创建统计特征...\n")
df_lagged[, KB_Sum := rowSums(.SD), .SDcols = kb_cols]
df_lagged[, KB_Mean := rowMeans(.SD), .SDcols = kb_cols]
df_lagged[, KB_Range := apply(.SD, 1, max) - apply(.SD, 1, min), .SDcols = kb_cols]
df_lagged[, KB_Std := apply(.SD, 1, sd), .SDcols = kb_cols]

# 添加奇偶比和大小比特征
df_lagged[, KB_OddCount := rowSums(.SD %% 2 == 1), .SDcols = kb_cols]
df_lagged[, KB_EvenCount := 20 - KB_OddCount]
df_lagged[, KB_SmallCount := rowSums(.SD <= 40), .SDcols = kb_cols]
df_lagged[, KB_LargeCount := 20 - KB_SmallCount]

# 添加统计特征的滞后
for (lag in 1:3) {
  stat_cols <- c("KB_Sum", "KB_Mean", "KB_Range", "KB_Std", "KB_OddCount", "KB_EvenCount", "KB_SmallCount", "KB_LargeCount")
  for (col in stat_cols) {
    col_name <- paste0(col, "_lag", lag)
    df_lagged[, (col_name) := shift(get(col), n = lag, type = "lag")]
  }
}

# 移除前5行（因为最大滞后是5）
df_lagged <- na.omit(df_lagged)
cat(paste("✓ 特征工程完成，数据量:", nrow(df_lagged), "行\n"))

# 创建特征和目标变量
lag_cols <- c(paste0(kb_cols, "_lag", 1:5), paste0("ISSUE_lag", 1:5))
stat_lag_cols <- c(
  paste0("KB_Sum_lag", 1:3),
  paste0("KB_Mean_lag", 1:3),
  paste0("KB_Range_lag", 1:3),
  paste0("KB_Std_lag", 1:3),
  paste0("KB_OddCount_lag", 1:3),
  paste0("KB_EvenCount_lag", 1:3),
  paste0("KB_SmallCount_lag", 1:3),
  paste0("KB_LargeCount_lag", 1:3)
)

features <- c(lag_cols, stat_lag_cols)
targets <- paste0("KB", 1:20)
model_data <- df_lagged[, c(features, targets), with = FALSE]

cat(paste("✓ 特征数量:", length(features), "\n"))
cat(paste("✓ 目标变量数量:", length(targets), "\n"))

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

# 训练模型 - 使用时间序列划分（修复数据泄露问题）
cat("\n训练模型（使用时间序列划分）...\n")
set.seed(123)
nrow_data <- nrow(model_data)

# 时间序列划分：前80%训练，后20%测试
train_ratio <- 0.8
train_rows <- 1:floor(train_ratio * nrow_data)
test_rows <- (floor(train_ratio * nrow_data) + 1):nrow_data

cat(paste("训练集:", length(train_rows), "行\n"))
cat(paste("测试集:", length(test_rows), "行\n"))

learners <- list()
kb_performance <- c()

for (target in targets) {
  learner <- lrn("regr.ranger",
                  num.trees = 500,
                  mtry = min(5, length(features)),
                  importance = "impurity",
                  predict_type = "response"
  )
  learner$train(tasks[[target]], row_ids = train_rows)
  learners[[target]] <- learner
  
  # 在测试集上评估模型性能
  pred <- learner$predict(tasks[[target]], row_ids = test_rows)
  rsq <- pred$score(msr("regr.rsq"))
  kb_performance[target] <- rsq
}

cat("✓ 模型训练完成\n")

# 显示模型性能
cat("\n模型性能（R²值）:\n")
cat("----------------------------------------\n")
perf_dt <- data.table(
  KB_Position = names(kb_performance),
  R2_Score = as.numeric(kb_performance)
)
setorder(perf_dt, -R2_Score)
for (i in 1:nrow(perf_dt)) {
  cat(sprintf("%2d. %s: %.4f\n", i, perf_dt$KB_Position[i], perf_dt$R2_Score[i]))
}
cat("----------------------------------------\n\n")

# ---------------------------
# 步骤3: Prediction下一期号码
# ---------------------------
cat("步骤 3: Prediction NextIssue Number\n")
cat("----------------------------------------\n")

latest_data <- KB_Data[nrow(KB_Data), ]
current_issue <- latest_data$ISSUE
next_issue <- current_issue + 1

cat(paste("Current Issue:", current_issue, "\n"))
cat(paste("Prediction Issue:", next_issue, "\n\n"))

# 创建预测特征
prediction_features <- data.table()

# 添加滞后特征
for (lag in 1:5) {
  for (col in c(kb_cols, "ISSUE")) {
    col_name <- paste0(col, "_lag", lag)
    if (lag == 1) {
      prediction_features[, (col_name) := latest_data[[col]]]
    } else {
      prediction_features[, (col_name) := KB_Data[nrow(KB_Data) - lag + 1, get(col)]]
    }
  }
}

# 添加统计特征及其滞后
latest_stats <- data.table(
  KB_Sum = sum(latest_data[, ..kb_cols]),
  KB_Mean = mean(unlist(latest_data[, ..kb_cols])),
  KB_Range = max(unlist(latest_data[, ..kb_cols])) - min(unlist(latest_data[, ..kb_cols])),
  KB_Std = sd(unlist(latest_data[, ..kb_cols])),
  KB_OddCount = sum(latest_data[, ..kb_cols] %% 2 == 1),
  KB_EvenCount = 20 - sum(latest_data[, ..kb_cols] %% 2 == 1),
  KB_SmallCount = sum(latest_data[, ..kb_cols] <= 40),
  KB_LargeCount = 20 - sum(latest_data[, ..kb_cols] <= 40)
)

for (lag in 1:3) {
  if (lag == 1) {
    for (col in names(latest_stats)) {
      col_name <- paste0(col, "_lag", lag)
      prediction_features[, (col_name) := latest_stats[[col]]]
    }
  } else {
    prev_data <- KB_Data[nrow(KB_Data) - lag + 1, ]
    prev_stats <- data.table(
      KB_Sum = sum(prev_data[, ..kb_cols]),
      KB_Mean = mean(unlist(prev_data[, ..kb_cols])),
      KB_Range = max(unlist(prev_data[, ..kb_cols])) - min(unlist(prev_data[, ..kb_cols])),
      KB_Std = sd(unlist(prev_data[, ..kb_cols])),
      KB_OddCount = sum(prev_data[, ..kb_cols] %% 2 == 1),
      KB_EvenCount = 20 - sum(prev_data[, ..kb_cols] %% 2 == 1),
      KB_SmallCount = sum(prev_data[, ..kb_cols] <= 40),
      KB_LargeCount = 20 - sum(prev_data[, ..kb_cols] <= 40)
    )
    for (col in names(prev_stats)) {
      col_name <- paste0(col, "_lag", lag)
      prediction_features[, (col_name) := prev_stats[[col]]]
    }
  }
}

# 添加目标变量列
for (target in targets) {
  prediction_features[, (target) := NA_real_]
}

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

# 添加动态计算的R²值
pred_dt[, R2_Score := kb_performance[KB_Position]]

# 号码范围验证和调整
pred_dt[, Predicted_Number := pmax(pmin(Predicted_Number, 80), 1)]

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

# 号码去重
predicted_numbers <- as.integer(top_predictions$Predicted_Number)
unique_numbers <- unique(predicted_numbers)

if (length(unique_numbers) < length(predicted_numbers)) {
  cat("检测到重复号码，正在去重...\n")
  duplicates <- predicted_numbers[duplicated(predicted_numbers)]
  cat(paste("重复号码:", paste(duplicates, collapse=", "), "\n"))
  
  # 从剩余的高R²值预测中补充号码
  remaining_predictions <- pred_dt_sorted[11:nrow(pred_dt_sorted)]
  for (dup in duplicates) {
    for (i in 1:nrow(remaining_predictions)) {
      if (!(remaining_predictions$Predicted_Number[i] %in% unique_numbers)) {
        idx <- which(predicted_numbers == dup)[1]
        predicted_numbers[idx] <- remaining_predictions$Predicted_Number[i]
        top_predictions$Predicted_Number[idx] <- remaining_predictions$Predicted_Number[i]
        top_predictions$KB_Position[idx] <- remaining_predictions$KB_Position[i]
        top_predictions$R2_Score[idx] <- remaining_predictions$R2_Score[i]
        unique_numbers <- unique(predicted_numbers)
        break
      }
    }
  }
  cat("✓ 去重完成\n\n")
}

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
cat(sprintf("Prediction Number和值: %d\n", 
            sum(top_predictions$Predicted_Number)))
cat(sprintf("Prediction Number奇偶比: %d:%d\n", 
            sum(top_predictions$Predicted_Number %% 2 == 1),
            sum(top_predictions$Predicted_Number %% 2 == 0)))
cat(sprintf("Prediction Number大小比: %d:%d\n", 
            sum(top_predictions$Predicted_Number <= 40),
            sum(top_predictions$Predicted_Number > 40)))
cat("----------------------------------------\n")

cat("\n========================================\n")
cat("✓ AutoKB V2 执行完成\n")
cat("========================================\n")

# ---------------------------
# 步骤4: 保存预测结果到文件
# ---------------------------
cat("\n步骤 4: 保存Prediction Number结果到文件\n")
cat("----------------------------------------\n")

if (!dir.exists("NextKB")) {
  dir.create("NextKB")
  cat("✓ 创建NextKB目录\n")
}

base_filename <- paste0("NextKB/", next_issue, ".txt")
filename <- base_filename
counter <- 1

while (file.exists(filename)) {
  filename <- paste0("NextKB/", next_issue, "_", counter, ".txt")
  counter <- counter + 1
}

file_content <- ""
file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "AutoKB V2 Prediction结果（改进版）\n")
file_content <- paste0(file_content, "========================================\n\n")

file_content <- paste0(file_content, "改进内容:\n")
file_content <- paste0(file_content, "1. 修复数据泄露问题 - 使用时间序列划分\n")
file_content <- paste0(file_content, "2. 扩展特征工程 - 添加多期滞后特征（lag1-lag5）\n")
file_content <- paste0(file_content, "3. 添加统计特征（和值、跨度、均值等）\n")
file_content <- paste0(file_content, "4. 动态计算R²值\n")
file_content <- paste0(file_content, "5. 增加数据量\n")
file_content <- paste0(file_content, "6. 添加号码去重和范围验证\n\n")

file_content <- paste0(file_content, "Current Issue: ", current_issue, "\n")
file_content <- paste0(file_content, "Prediction Issue: ", next_issue, "\n")
file_content <- paste0(file_content, "历史数据量: ", nrow(KB_Data), "期\n")
file_content <- paste0(file_content, "特征数量: ", length(features), "\n\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "模型性能（R²值）\n")
file_content <- paste0(file_content, "========================================\n")
for (i in 1:nrow(perf_dt)) {
  file_content <- paste0(file_content, sprintf("%2d. %s: %.4f\n", i, perf_dt$KB_Position[i], perf_dt$R2_Score[i]))
}
file_content <- paste0(file_content, "\n")

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
file_content <- paste0(file_content, "Prediction统计\n")
file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, sprintf("Prediction Number范围: %d - %d\n", 
            min(as.integer(top_predictions$Predicted_Number)), 
            max(as.integer(top_predictions$Predicted_Number))))
file_content <- paste0(file_content, sprintf("Prediction Number平均值: %.2f\n", 
            mean(top_predictions$Predicted_Number)))
file_content <- paste0(file_content, sprintf("Prediction Number中位数: %d\n", 
            as.integer(median(top_predictions$Predicted_Number))))
file_content <- paste0(file_content, sprintf("Prediction Number和值: %d\n", 
            sum(top_predictions$Predicted_Number)))
file_content <- paste0(file_content, sprintf("Prediction Number奇偶比: %d:%d\n", 
            sum(top_predictions$Predicted_Number %% 2 == 1),
            sum(top_predictions$Predicted_Number %% 2 == 0)))
file_content <- paste0(file_content, sprintf("Prediction Number大小比: %d:%d\n", 
            sum(top_predictions$Predicted_Number <= 40),
            sum(top_predictions$Predicted_Number > 40)))
file_content <- paste0(file_content, "\n")

file_content <- paste0(file_content, "========================================\n")
file_content <- paste0(file_content, "生成时间: ", Sys.time(), "\n")
file_content <- paste0(file_content, "========================================\n")

writeLines(file_content, filename)
cat(paste("✓ Prediction Number结果已保存到:", filename, "\n"))

# ---------------------------
# 步骤5: Git自动提交和推送
# ---------------------------
cat("\n步骤 5: Git自动提交和推送\n")
cat("----------------------------------------\n")

commit_msg <- paste0("AutoKB V2 update - ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"))
system(paste0('powershell.exe -ExecutionPolicy Bypass -File "git_auto_commit.ps1" -CommitMessage "', commit_msg, '"'), ignore.stdout = TRUE, ignore.stderr = TRUE)

cat("✓ Git操作完成\n")
