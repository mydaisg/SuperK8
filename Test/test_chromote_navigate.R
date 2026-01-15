cat("========================================\n")
cat("chromote 导航测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  
  cat("\n2. 测试导航功能...\n")
  cat("  打开百度首页...\n")
  
  cat("  方法 1: 使用 navigate 方法...\n")
  tryCatch({
    b$navigate("https://www.baidu.com")
    cat("  ✓ navigate 方法成功\n")
  }, error = function(e) {
    cat("  ✗ navigate 方法失败:", e$message, "\n")
    cat("  尝试其他方法...\n")
  })
  
  Sys.sleep(3)
  
  cat("\n3. 测试页面操作...\n")
  cat("  使用 JavaScript 获取页面标题...\n")
  tryCatch({
    title <- b$run_script("document.title")
    cat(paste("  ✓ 页面标题:", title, "\n"))
  }, error = function(e) {
    cat("  ✗ run_script 失败:", e$message, "\n")
  })
  
  cat("\n4. 截图测试...\n")
  screenshot_path <- "test_screenshot.png"
  tryCatch({
    b$screenshot(screenshot_path)
    if (file.exists(screenshot_path)) {
      cat(paste("  ✓ 截图已保存:", screenshot_path, "\n"))
    } else {
      cat("  ✗ 截图文件不存在\n")
    }
  }, error = function(e) {
    cat("  ✗ 截图失败:", e$message, "\n")
  })
  
  cat("\n5. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 导航测试完成！\n")
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