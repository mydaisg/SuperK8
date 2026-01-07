# 快速验证和安装包

options(repos = c(CRAN = "https://cloud.r-project.org/"))

# 核心包列表
core_packages <- c("data.table", "ggplot2", "mlr3", "mlr3measures", "mlr3learners", "mlr3tuning", "mlr3viz", "mlr3verse", "GH.AN.LIST")

cat("检查已安装的包...\n")
installed <- rownames(installed.packages())
cat(paste0("已安装包数量: ", length(installed), "\n\n"))

for (pkg in core_packages) {
  if (pkg %in% installed) {
    cat(paste0("✓ ", pkg, " - 已安装\n"))
  } else {
    cat(paste0("✗ ", pkg, " - 未安装\n"))
  }
}
