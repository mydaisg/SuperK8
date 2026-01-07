# 完整安装SuperK8项目所需的所有R包

# 设置镜像源
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# 需要安装的包列表（按依赖顺序）
packages <- c(
  "data.table",     # 高效数据处理
  "ggplot2",        # 数据可视化
  "mlr3",           # mlr3核心
  "mlr3measures",   # 评估指标
  "mlr3learners",   # 学习器
  "mlr3tuning",     # 超参数调优
  "mlr3viz",        # 可视化
  "mlr3verse",      # mlr3完整套件
  "GH.AN.LIST"      # 最新数据获取
)

# 安装函数
install_if_missing <- function(packages) {
  for (pkg in packages) {
    cat(paste0("\n检查包: ", pkg, "\n"))
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste0("正在安装包: ", pkg, "\n"))
      tryCatch({
        install.packages(pkg, dependencies = TRUE, quiet = TRUE)
        if (require(pkg, character.only = TRUE, quietly = TRUE)) {
          cat(paste0("✓ ", pkg, " 安装成功\n"))
        } else {
          cat(paste0("✗ ", pkg, " 安装失败\n"))
        }
      }, error = function(e) {
        cat(paste0("✗ ", pkg, " 安装出错: ", e$message, "\n"))
      })
    } else {
      cat(paste0("✓ ", pkg, " 已安装\n"))
    }
  }
}

# 执行安装
cat("========================================\n")
cat("开始安装SuperK8项目所需的R包\n")
cat("========================================\n")
install_if_missing(packages)

cat("\n========================================\n")
cat("安装完成！正在验证...\n")
cat("========================================\n")

# 验证安装
cat("\n验证包加载:\n")
for (pkg in packages) {
  if (require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste0("✓ ", pkg, " 加载成功\n"))
  } else {
    cat(paste0("✗ ", pkg, " 加载失败\n"))
  }
}

cat("\n========================================\n")
cat("所有操作完成！\n")
cat("========================================\n")
