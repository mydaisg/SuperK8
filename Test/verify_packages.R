# 验证所有核心包是否能正常加载

cat("========================================\n")
cat("验证核心包加载\n")
cat("========================================\n\n")

packages <- c("data.table", "ggplot2", "mlr3", "mlr3measures", "mlr3learners", "mlr3tuning", "mlr3viz", "mlr3verse")

success_count <- 0
for (pkg in packages) {
  tryCatch({
    library(pkg, character.only = TRUE)
    cat(paste0("✓ ", pkg, " - 加载成功\n"))
    success_count <- success_count + 1
  }, error = function(e) {
    cat(paste0("✗ ", pkg, " - 加载失败: ", e$message, "\n"))
  })
}

cat("\n========================================\n")
cat(paste0("成功加载: ", success_count, "/", length(packages), " 个包\n"))
cat("========================================\n")

cat("\n注意: GH.AN.LIST 包未找到，可能需要从其他来源安装或检查包名是否正确。\n")
