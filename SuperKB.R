library(mlr3verse)   # mlr3核心及常用扩展包
library(data.table)  # 高效数据处理
source("GH_AN_LIST.R") # 数据获取函数

# ---------------------------
# A：数据准备与任务创建
# ---------------------------
# 获取数据：数据 KB_Data。
KB_Data <- GH_LIST_KB(4,30,6)
str(KB_Data) # 数据集的基本信息
head(KB_Data)  # 前几行数据
sum(is.na(KB_Data)) # 检查缺失值

# 创建滞后特征，数据已按 DATES排序
# 创建滞后变量：将KB1-KB20、POOL、ISSUE的值向后移动一期，作为t时刻的特征
df_lagged <- copy(KB_Data)
lag_cols <- c(paste0("KB", 1:20), "POOL", "ISSUE") # 需要创建滞后值的列

# 对指定的列，每一列都创建一个滞后一期的列
for (col in lag_cols) {
  df_lagged[, paste0(col, "_lag1") := shift(.SD, n = 1, type = "lag"), .SDcols = col]
}

# 移除第一行（因为滞后产生了NA）
df_lagged <- na.omit(df_lagged)

# 此时，特征变量是所有 *_lag1 变量（排除DATES，因为ranger不支持Date类型）
# 目标变量是原始的 KB1 到 KB20
features <- paste0(lag_cols, "_lag1")
targets <- paste0("KB", 1:20)

# 为后续任务创建新的数据表
model_data <- df_lagged[, c(features, targets), with = FALSE]

# -------------------------
# B：创建多个单输出回归任务
# -------------------------
# mlr3的TaskRegr只支持单目标变量，需要为每个KB变量创建单独的任务

# 为每个目标变量创建任务
tasks <- list()
for (target in targets) {
  task <- TaskRegr$new(
    id = paste0("kb_", target),
    backend = model_data,
    target = target
  )
  tasks[[target]] <- task
}

# 打印任务基本信息进行检查
print(paste("创建了", length(tasks), "个回归任务"))

# -------------------------------------------------------
# C：选择并配置学习器
# -------------------------------------------------------
# 使用 ranger实现的多输出随机森林回归学习器 regr.ranger。
# 创建随机森林学习器，并设置一些关键参数
learner_rf <- lrn("regr.ranger",
                  num.trees = 500,     # 树的数量，可根据需要调整
                  mtry = to_tune(5, 15), # 每棵树分裂时随机抽取的特征数，可调优
                  importance = "impurity", # 计算变量重要性
                  predict_type = "response"
)

# -------------------------------------------------------
# D：训练模型
# -------------------------------------------------------
# 划分训练集和测试集，并在训练集上训练模型。
# 设置随机种子保证可重复性
set.seed(123)

# 获取数据行数
nrow_data <- nrow(model_data)

# 按比例（例如70%训练，30%测试）划分数据行索引
train_rows <- sample(1:nrow_data, size = 0.7 * nrow_data)
test_rows <- setdiff(1:nrow_data, train_rows)

# 为每个任务训练模型
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

# -------------------------------------------------------
# E：进行预测并评估模型
# -------------------------------------------------------
# 定义要评估的指标列表
measures <- list(
  msr("regr.mse"),  # 均方误差
  msr("regr.mae"),  # 平均绝对误差
  msr("regr.rsq")   # 决定系数R²
)

# 为每个目标变量进行预测和评估
predictions <- list()
performance_scores <- list()

for (target in targets) {
  cat(paste("正在预测", target, "...\n"))
  
  # 在测试集上进行预测
  pred <- learners[[target]]$predict(tasks[[target]], row_ids = test_rows)
  predictions[[target]] <- pred
  
  # 计算预测结果在测试集上的各项指标
  perf <- pred$score(measures)
  performance_scores[[target]] <- perf
  
  cat(paste("  MSE:", round(perf$regr.mse, 4), 
            "MAE:", round(perf$regr.mae, 4),
            "R²:", round(perf$regr.rsq, 4), "\n"))
}

# 计算所有目标变量的平均性能指标
avg_mse <- mean(sapply(performance_scores, function(x) x$regr.mse))
avg_mae <- mean(sapply(performance_scores, function(x) x$regr.mae))
avg_rsq <- mean(sapply(performance_scores, function(x) x$regr.rsq))

cat("\n========================================\n")
cat("平均性能指标:\n")
cat(paste("  平均MSE:", round(avg_mse, 4), "\n"))
cat(paste("  平均MAE:", round(avg_mae, 4), "\n"))
cat(paste("  平均R²:", round(avg_rsq, 4), "\n"))
cat("========================================\n")


# -------------------------------------------------------
# F：结果可视化与分析
# -------------------------------------------------------
# 绘制预测值与真实值对比散点图（以其中一个目标变量KB1为例）
library(ggplot2)

# 提取KB1的真实值和预测值
true_kb1 <- predictions[["KB1"]]$truth
pred_kb1 <- predictions[["KB1"]]$response
plot_data <- data.frame(True = true_kb1, Predicted = pred_kb1)

ggplot(plot_data, aes(x = True, y = Predicted)) +
  geom_point(alpha = 0.6) +
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") +
  labs(title = "Predicted vs True for KB1",
       x = "True Value (KB1 at t+1)",
       y = "Predicted Value") +
  theme_minimal()


# 检查变量重要性
# 随机森林可以提供特征重要性度量。
# 提取并绘制变量重要性 (需要学习器设置了importance = "impurity")
if ("importance" %in% learners[["KB1"]]$properties) {
  imp <- learners[["KB1"]]$importance()
  # 将重要性排序并绘图
  imp_dt <- data.table(Feature = names(imp), Importance = imp)
  imp_dt <- imp_dt[order(-Importance)]
  
  ggplot(imp_dt[1:10], aes(x = reorder(Feature, Importance), y = Importance)) + # 显示前10个重要特征
    geom_bar(stat = "identity", fill = "steelblue") +
    coord_flip() +
    labs(title = "Feature Importance (Top 10)", x = "Feature", y = "Importance") +
    theme_minimal()
}




# -------------------------------------------------------
# 附注释
# -------------------------------------------------------
# 8. 注意事项与进阶提示
# 1.超参数调优：上述 mtry参数使用了 to_tune()，
# 可以使用 mlr3tuning包进行更系统的超参数优化，
# 例如通过随机搜索或贝叶斯优化来寻找最佳参数组合，以提升模型性能。
# library(mlr3tuning)
# # ... 创建调优实例、选择调优器、运行调优的代码
# 2. 时间序列交叉验证：对于时间序列数据，标准的随机划分或K折交叉验证可能会造成数据泄露
# （用未来数据预测过去）。更合适的做法是使用时序交叉验证方法，
# 如 rsmp("rolling_origin")或 rsmp("forecasting_cv")，这些在 mlr3temporal包中提供。
# 3. 特征工程：除了滞后一期，您可以尝试创建更多的滞后特征（如 t-2, t-3）、
# 移动平均、时序趋势等其他特征，以便为模型提供更丰富的历史信息。
# 4. 评估策略：多输出回归的评估可以更复杂。除了对每个目标单独评估，
# 也可考察预测向量与真实向量之间的整体误差，尽管mlr3内置度量主要针对单目标。
# 自定义度量或使用多输出专用包可能是进阶选择。
# 5. 模型选择：随机森林是常用且强大的起点。也可以尝试其他支持多输出回归的算法，
# 例如在 mlr3中查找相应的学习器，或者通过集成多个单输出模型（效率可能较低）来实现。
# 通过以上步骤，您应该能够在mlr3框架下构建一个用于多输出自回归预测的随机森林模型。
# 可根据具体数据情况和业务需求调整参数和细节。



