cat("========================================\n")
cat("安装 RSelenium 相关包\n")
cat("========================================\n\n")

packages <- c("RSelenium", "rvest", "stringr", "binman", "wdman")

for (pkg in packages) {
  cat(paste("检查包:", pkg, "\n"))
  if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
    cat(paste("  安装", pkg, "...\n"))
    install.packages(pkg, repos = "https://cloud.r-project.org/")
    library(pkg, character.only = TRUE)
    cat(paste("  ✓", pkg, "安装成功\n"))
  } else {
    cat(paste("  -", pkg, "已安装\n"))
  }
}

cat("\n========================================\n")
cat("RSelenium 相关包安装完成\n")
cat("========================================\n")