cat("========================================\n")
cat("chromote 简单测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  
  cat("\n2. 测试导航操作...\n")
  cat("  打开百度首页...\n")
  b$navigate("https://www.baidu.com")
  Sys.sleep(3)
  cat("  ✓ 页面加载成功\n")
  
  cat("\n3. 获取页面信息...\n")
  cat("  获取页面标题...\n")
  result <- b$Runtime$evaluate("document.title")
  title <- result$result$value
  cat(paste("  ✓ 页面标题:", title, "\n"))
  
  cat("\n4. 截图测试...\n")
  screenshot_path <- "test_screenshot.png"
  b$screenshot(screenshot_path)
  cat(paste("  ✓ 截图已保存:", screenshot_path, "\n"))
  
  cat("\n5. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 测试成功！\n")
  cat("========================================\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("错误详情:\n")
  print(e)
})