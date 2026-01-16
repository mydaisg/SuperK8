########### Backtest Framework - 回测框架 #######
# 用于验证历史预测准确率

library(mlr3verse)
library(data.table)

cat("========================================\n")
cat("Backtest Framework - 历史回测\n")
cat("========================================\n\n")

source("GH_AN_LIST.R")

# 获取所有可用数据
KB_Data <- GH_LIST_KB(4, 10000, 21)
total_issues <- nrow(KB_Data)

cat(paste("总数据量:", total_issues, "期\n\n"))

# 回测参数
backtest_periods <- 20  # 回测最近20期
train_ratio <- 0.8      # 训练集比例

cat(paste("回测最近", backtest_periods, "期\n"))
cat(paste("训练集比例:", train_ratio * 100, "%\n\n"))

# 创建扩展的滞后特征
df_lagged <- copy(KB_Data)
kb_cols <- paste0("KB", 1:20)

# 添加多期滞后特征（lag1-lag5）
cat("创建特征...\n")
for (lag in 1:5) {
  for (col in c(kb_cols, "ISSUE")) {
    df_lagged[, paste0(col, "_lag", lag) := shift(get(col), n = lag, type = "lag")]
  }
}

# 添加统计特征
df_lagged[, KB_Sum := rowSums(.SD), .SDcols = kb_cols]
df_lagged[, KB_Mean := rowMeans(.SD), .SDcols = kb_cols]
df_lagged[, KB_Range := apply(.SD, 1, max) - apply(.SD, 1, min), .SDcols = kb_cols]
df_lagged[, KB_Std := apply(.SD, 1, sd), .SDcols = kb_cols]
df_lagged[, KB_OddCount := rowSums(.SD %% 2 == 1), .SDcols = kb_cols]
df_lagged[, KB_EvenCount := 20 - KB_OddCount]
df_lagged[, KB_SmallCount := rowSums(.SD <= 40), .SDcols = kb_cols]
df_lagged[, KB_LargeCount := 20 - KB_SmallCount]

# 添加统计特征的滞后
for (lag in 1:3) {
  stat_cols <- c("KB_Sum", "KB_Mean", "KB_Range", "KB_Std", "KB_OddCount", "KB_EvenCount", "KB_SmallCount", "KB_LargeCount")
  for (col in stat_cols) {
    df_lagged[, paste0(col, "_lag", lag) := shift(get(col), n = lag, type = "lag")]
  }
}

# 移除前5行
df_lagged <- na.omit(df_lagged)

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

cat(paste("特征数量:", length(features), "\n"))
cat(paste("目标变量数量:", length(targets), "\n\n"))

# 回测结果存储
backtest_results <- data.table(
  Issue = integer(),
  Predicted_Numbers = character(),
  Actual_Numbers = character(),
  Hit_Count = integer(),
  Hit_Rate = numeric(),
  Top11_Hit = integer(),
  Top11_Hit_Rate = numeric()
)

cat("开始回测...\n")
cat("----------------------------------------\n")

# 回测循环
for (i in 1:backtest_periods) {
  test_idx <- nrow(df_lagged) - backtest_periods + i
  train_end_idx <- test_idx - 1
  
  cat(sprintf("\n回测期 %d/%d (Issue: %d)\n", i, backtest_periods, df_lagged$ISSUE[test_idx]))
  
  # 准备训练数据
  train_data <- df_lagged[1:train_end_idx, ]
  
  # 创建任务
  tasks <- list()
  for (target in targets) {
    task <- TaskRegr$new(
      id = paste0("kb_", target),
      backend = train_data,
      target = target
    )
    tasks[[target]] <- task
  }
  
  # 训练模型
  learners <- list()
  for (target in targets) {
    learner <- lrn("regr.ranger",
                    num.trees = 500,
                    mtry = min(5, length(features)),
                    importance = "impurity",
                    predict_type = "response"
    )
    learner$train(tasks[[target]], row_ids = 1:nrow(train_data))
    learners[[target]] <- learner
  }
  
  # 准备预测特征
  prediction_features <- data.table()
  
  for (lag in 1:5) {
    for (col in c(kb_cols, "ISSUE")) {
      prediction_features[, paste0(col, "_lag", lag) := df_lagged[test_idx - lag + 1, col]]
    }
  }
  
  for (lag in 1:3) {
    stat_cols <- c("KB_Sum", "KB_Mean", "KB_Range", "KB_Std", "KB_OddCount", "KB_EvenCount", "KB_SmallCount", "KB_LargeCount")
    for (col in stat_cols) {
      prediction_features[, paste0(col, "_lag", lag) := df_lagged[test_idx - lag + 1, col]]
    }
  }
  
  for (target in targets) {
    prediction_features[, (target) := NA_real_]
  }
  
  prediction_features <- prediction_features[, c(features, targets), with = FALSE]
  
  # 预测
  predictions <- list()
  for (target in targets) {
    pred <- learners[[target]]$predict_newdata(prediction_features)
    predictions[[target]] <- round(as.numeric(pred$response))
  }
  
  # 创建预测结果
  pred_dt <- data.table(
    KB_Position = targets,
    Predicted_Number = unlist(predictions)
  )
  
  # 号码范围验证
  pred_dt[, Predicted_Number := pmax(pmin(Predicted_Number, 80), 1)]
  
  # 按R²值排序（使用测试集评估）
  kb_performance <- c()
  for (target in targets) {
    test_pred <- learners[[target]]$predict(tasks[[target]], row_ids = train_end_idx)
    rsq <- test_pred$score(msr("regr.rsq"))
    kb_performance[target] <- rsq
  }
  
  pred_dt[, R2_Score := kb_performance[KB_Position]]
  pred_dt_sorted <- pred_dt[order(-R2_Score)]
  
  # 选择Top11
  top_predictions <- pred_dt_sorted[1:11]
  
  # 号码去重
  predicted_numbers <- as.integer(top_predictions$Predicted_Number)
  unique_numbers <- unique(predicted_numbers)
  
  if (length(unique_numbers) < length(predicted_numbers)) {
    remaining_predictions <- pred_dt_sorted[11:nrow(pred_dt_sorted)]
    for (dup in predicted_numbers[duplicated(predicted_numbers)]) {
      for (j in 1:nrow(remaining_predictions)) {
        if (!(remaining_predictions$Predicted_Number[j] %in% unique_numbers)) {
          idx <- which(predicted_numbers == dup)[1]
          predicted_numbers[idx] <- remaining_predictions$Predicted_Number[j]
          unique_numbers <- unique(predicted_numbers)
          break
        }
      }
    }
  }
  
  # 获取实际号码
  actual_numbers <- as.integer(unlist(df_lagged[test_idx, ..kb_cols]))
  
  # 计算命中情况
  hit_count <- sum(predicted_numbers %in% actual_numbers)
  hit_rate <- hit_count / length(predicted_numbers)
  
  # 计算Top11命中
  top11_hit <- sum(predicted_numbers %in% actual_numbers)
  top11_hit_rate <- top11_hit / 11
  
  # 存储结果
  backtest_results <- rbind(backtest_results, data.table(
    Issue = df_lagged$ISSUE[test_idx],
    Predicted_Numbers = paste(sort(predicted_numbers), collapse=", "),
    Actual_Numbers = paste(sort(actual_numbers), collapse=", "),
    Hit_Count = hit_count,
    Hit_Rate = hit_rate,
    Top11_Hit = top11_hit,
    Top11_Hit_Rate = top11_hit_rate
  ))
  
  cat(sprintf("  命中: %d/%d (%.2f%%)\n", hit_count, length(predicted_numbers), hit_rate * 100))
}

cat("\n========================================\n")
cat("回测完成\n")
cat("========================================\n\n")

# 统计分析
cat("回测统计结果:\n")
cat("----------------------------------------\n")
cat(sprintf("平均命中数: %.2f\n", mean(backtest_results$Hit_Count)))
cat(sprintf("平均命中率: %.2f%%\n", mean(backtest_results$Hit_Rate) * 100))
cat(sprintf("Top11平均命中: %.2f\n", mean(backtest_results$Top11_Hit)))
cat(sprintf("Top11平均命中率: %.2f%%\n", mean(backtest_results$Top11_Hit_Rate) * 100))
cat(sprintf("最高命中数: %d\n", max(backtest_results$Hit_Count)))
cat(sprintf("最低命中数: %d\n", min(backtest_results$Hit_Count)))
cat("----------------------------------------\n\n")

# 详细结果
cat("详细回测结果:\n")
cat("----------------------------------------\n")
cat(sprintf("%-10s %-30s %-30s %-10s %-10s\n", "Issue", "Predicted", "Actual", "Hit", "Hit Rate"))
cat("----------------------------------------\n")
for (i in 1:nrow(backtest_results)) {
  cat(sprintf("%-10d %-30s %-30s %-10d %.2f%%\n", 
              backtest_results$Issue[i],
              backtest_results$Predicted_Numbers[i],
              backtest_results$Actual_Numbers[i],
              backtest_results$Hit_Count[i],
              backtest_results$Hit_Rate[i] * 100))
}
cat("----------------------------------------\n\n")

# 保存回测结果
if (!dir.exists("Backtest")) {
  dir.create("Backtest")
}

backtest_filename <- paste0("Backtest/backtest_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
writeLines(c(
  "========================================",
  "Backtest Results",
  "========================================",
  "",
  paste("回测期数:", backtest_periods),
  paste("训练集比例:", train_ratio * 100, "%"),
  "",
  "========================================",
  "统计结果",
  "========================================",
  paste("平均命中数:", round(mean(backtest_results$Hit_Count), 2)),
  paste("平均命中率:", round(mean(backtest_results$Hit_Rate) * 100, 2), "%"),
  paste("Top11平均命中:", round(mean(backtest_results$Top11_Hit), 2)),
  paste("Top11平均命中率:", round(mean(backtest_results$Top11_Hit_Rate) * 100, 2), "%"),
  paste("最高命中数:", max(backtest_results$Hit_Count)),
  paste("最低命中数:", min(backtest_results$Hit_Count)),
  "",
  "========================================",
  "详细结果",
  "========================================",
  sprintf("%-10s %-30s %-30s %-10s %-10s", "Issue", "Predicted", "Actual", "Hit", "Hit Rate"),
  "----------------------------------------"
), backtest_filename)

for (i in 1:nrow(backtest_results)) {
  write(sprintf("%-10d %-30s %-30s %-10d %.2f%%", 
                backtest_results$Issue[i],
                backtest_results$Predicted_Numbers[i],
                backtest_results$Actual_Numbers[i],
                backtest_results$Hit_Count[i],
                backtest_results$Hit_Rate[i] * 100), backtest_filename, append = TRUE)
}

write("", backtest_filename, append = TRUE)
write("========================================", backtest_filename, append = TRUE)
write(paste("生成时间:", Sys.time()), backtest_filename, append = TRUE)
write("========================================", backtest_filename, append = TRUE)

cat(paste("✓ 回测结果已保存到:", backtest_filename, "\n"))

cat("\n========================================\n")
cat("✓ Backtest Framework 执行完成\n")
cat("========================================\n")
