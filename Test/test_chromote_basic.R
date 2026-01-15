cat("========================================\n")
cat("chromote 基础测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  cat(paste("  浏览器类型:", class(b), "\n"))
  cat(paste("  浏览器属性:", paste(names(b), collapse = ", "), "\n"))
  
  cat("\n2. 等待 3 秒...\n")
  Sys.sleep(3)
  
  cat("\n3. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 基础测试成功！\n")
  cat("========================================\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("错误详情:\n")
  print(e)
  
  cat("\n尝试清理资源...\n")
  tryCatch({
    if (exists("b")) {
      b$close()
      cat("  ✓ 浏览器已关闭\n")
    }
  }, error = function(e2) {
    cat("  清理失败:", e2$message, "\n")
  })
})