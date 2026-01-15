cat("========================================\n")
cat("检查 chromote 版本和配置\n")
cat("========================================\n\n")

cat("加载 chromote 包...\n")
library(chromote)
cat("  ✓ 完成\n")

cat("\n检查版本...\n")
cat(paste("  chromote 版本:", packageVersion("chromote"), "\n"))

cat("\n检查依赖包...\n")
cat("  chromote 依赖:\n")
dependencies <- packageDescription("chromote")$Imports
if (!is.null(dependencies)) {
  deps <- strsplit(dependencies, ",\\s*")[[1]]
  for (dep in deps) {
    pkg_name <- trimws(strsplit(dep, "\\s*\\(\\s*")[[1]][1])
    tryCatch({
      pkg_version <- packageVersion(pkg_name)
      cat(paste("    -", pkg_name, ":", pkg_version, "\n"))
    }, error = function(e) {
      cat(paste("    -", pkg_name, ": 未安装\n"))
    })
  }
}

cat("\n尝试创建 Chrome 对象...\n")
tryCatch({
  c <- Chrome$new()
  cat("  ✓ Chrome 对象创建成功\n")
  cat(paste("  Chrome 路径:", c$browser_path, "\n"))
  cat(paste("  Chrome 端口:", c$port, "\n"))
  c$close()
}, error = function(e) {
  cat("  ✗ 创建失败:", e$message, "\n")
})

cat("\n========================================\n")
cat("检查完成\n")
cat("========================================\n")