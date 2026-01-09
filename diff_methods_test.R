cat("========================================\n")
cat("使用不同方法测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 完成\n")

cat("\n等待 3 秒...\n")
Sys.sleep(3)
cat("  ✓ 完成\n")

cat("\n方法 1: Runtime.evaluate 获取标题...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  结果:", result$value, "\n"))

cat("\n方法 2: Page.getNavigationHistory 获取导航信息...\n")
tryCatch({
  nav_history <- b$Page$getNavigationHistory()
  cat(paste("  当前索引:", nav_history$currentIndex, "\n"))
  if (length(nav_history$entries) > 0) {
    cat(paste("  URL:", nav_history$entries[[1]]$url, "\n"))
    cat(paste("  标题:", nav_history$entries[[1]]$title, "\n"))
  }
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n方法 3: DOM.getDocument 获取文档...\n")
tryCatch({
  doc <- b$DOM$getDocument()
  cat(paste("  文档节点 ID:", doc$root$nodeId, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")