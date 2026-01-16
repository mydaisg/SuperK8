########### SuperKB V2 - 改进版 #######
# 改进内容：
# 1. 修复数据泄露问题 - 使用时间序列划分
# 2. 扩展特征工程 - 添加多期滞后特征（lag1-lag5）
# 3. 添加统计特征（和值、跨度、均值等）
# 4. 动态计算R²值
# 5. 增加数据量
# 6. 添加号码去重和范围验证

library(mlr3verse)
library(data.table)
source("GH_AN_LIST.R")

cat("========================================\n")
cat("SuperKB V2 - 改进版\n")
cat("========================================\n\n")

# ---------------------------
# A：数据准备与任务创建（改进版）
# ---------------------------
KB_Data <- GH_LIST_KB(4, 10000, 21)
str(KB_Data)
head(KB_Data)
sum(is.na(KB_Data))

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

# 移除前5行
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
cat(paste("✓ 目标变量数量:", length(targets), "\n\n"))

# -------------------------
# B：创建多个单输出回归任务
# -------------------------
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

# -------------------------------------------------------
# C：选择并配置学习器
# -------------------------------------------------------
learner_rf <- lrn("regr.ranger",
                  num.trees = 500,
                  mtry = to_tune(5, 15),
                  importance = "impurity",
                  predict_type = "response"
)

# -------------------------------------------------------
# D：训练模型（改进版 - 使用时间序列划分）
# -------------------------------------------------------
cat("训练模型（使用时间序列划分）...\n")
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
  cat(paste("正在训练", target, "模型...\n"))
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

cat(paste("✓ 成功训练了", length(learners), "个模型\n"))

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

# -------------------------------------------------------
# E：进行预测并评估模型（改进版）
# -------------------------------------------------------
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
cat("========================================\n\n")

# -------------------------------------------------------
# F：结果可视化与分析
# -------------------------------------------------------
library(ggplot2)

true_kb1 <- predictions[["KB1"]]$truth
pred_kb1 <- predictions[["KB1"]]$response
plot_data <- data.frame(True = true_kb1, Predicted = pred_kb1)

ggplot(plot_data, aes(x = True, y = Predicted)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Predicted vs True for KB1 (V2)",
       x = "True Value (KB1 at t+1)",
       y = "Predicted Value") +
  theme_minimal()

# 变量重要性
if ("importance" %in% learners[["KB1"]]$properties) {
  imp <- learners[["KB1"]]$importance()
  imp_dt <- data.table(Feature = names(imp), Importance = imp)
  imp_dt <- imp_dt[order(-Importance)]
  
  ggplot(imp_dt[1:15], aes(x = reorder(Feature, Importance), y = Importance)) +
    geom_bar(stat = "identity", fill = "steelblue") +
    coord_flip() +
    labs(title = "Feature Importance (Top 15) - V2", x = "Feature", y = "Importance") +
    theme_minimal()
}

# -------------------------------------------------------
# G：预测下一期号码
# -------------------------------------------------------
cat("========================================\n")
cat("预测NextIssue\n")
cat("========================================\n\n")

latest_data <- KB_Data[nrow(KB_Data), ]
current_issue <- latest_data$ISSUE
next_issue <- current_issue + 1

cat(paste("Current Issue:", current_issue, "\n"))
cat(paste("Next Issue:", next_issue, "\n\n"))

# 创建预测特征
prediction_features <- data.table()

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

pred_dt[, R2_Score := kb_performance[KB_Position]]

# 号码范围验证
pred_dt[, Predicted_Number := pmax(pmin(Predicted_Number, 80), 1)]

pred_dt_sorted <- pred_dt[order(-R2_Score)]

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

# 号码去重
predicted_numbers <- as.integer(top_predictions$Predicted_Number)
unique_numbers <- unique(predicted_numbers)

if (length(unique_numbers) < length(predicted_numbers)) {
  cat("检测到重复号码，正在去重...\n")
  duplicates <- predicted_numbers[duplicated(predicted_numbers)]
  cat(paste("重复号码:", paste(duplicates, collapse=", "), "\n"))
  
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

cat("预测统计:\n")
cat("----------------------------------------\n")
cat(sprintf("预测号码范围: %d - %d\n", 
            min(as.integer(top_predictions$Predicted_Number)), 
            max(as.integer(top_predictions$Predicted_Number))))
cat(sprintf("预测号码平均值: %.2f\n", 
            mean(top_predictions$Predicted_Number)))
cat(sprintf("预测号码中位数: %d\n", 
            as.integer(median(top_predictions$Predicted_Number))))
cat(sprintf("预测号码和值: %d\n", 
            sum(top_predictions$Predicted_Number)))
cat(sprintf("预测号码奇偶比: %d:%d\n", 
            sum(top_predictions$Predicted_Number %% 2 == 1),
            sum(top_predictions$Predicted_Number %% 2 == 0)))
cat(sprintf("预测号码大小比: %d:%d\n", 
            sum(top_predictions$Predicted_Number <= 40),
            sum(top_predictions$Predicted_Number > 40)))
cat("----------------------------------------\n")

cat("\n✓ SuperKB V2 执行完成\n")
