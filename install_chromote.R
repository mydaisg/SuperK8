cat("========================================\n")
cat("安装 chromote 包（不需要 Java）\n")
cat("========================================\n\n")

if (!require("chromote", quietly = TRUE)) {
  cat("安装 chromote...\n")
  install.packages("chromote", repos = "https://cloud.r-project.org/")
  library(chromote)
  cat("✓ chromote 安装成功\n")
} else {
  cat("chromote 已安装\n")
  library(chromote)
}

cat("\n========================================\n")
cat("chromote 安装完成\n")
cat("========================================\n")