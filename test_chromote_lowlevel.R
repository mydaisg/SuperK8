cat("========================================\n")
cat("chromote 底层 API 测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  
  cat("\n2. 使用 Page.navigate 导航...\n")
  cat("  打开百度首页...\n")
  result <- b$Page$navigate("https://www.baidu.com")
  cat("  ✓ 导航调用成功\n")
  cat(paste("  返回结果:", result, "\n"))
  
  Sys.sleep(3)
  
  cat("\n3. 使用 Runtime.evaluate 获取页面信息...\n")
  cat("  获取页面标题...\n")
  title_result <- b$Runtime$evaluate("document.title")
  cat("  ✓ 执行 JavaScript 成功\n")
  cat(paste("  结果类型:", class(title_result), "\n"))
  cat(paste("  结果内容:", paste(names(title_result), collapse = ", "), "\n"))
  
  if (!is.null(title_result$result) && !is.null(title_result$result$value)) {
    title <- title_result$result$value
    cat(paste("  ✓ 页面标题:", title, "\n"))
  } else {
    cat("  ✗ 无法获取标题\n")
  }
  
  cat("\n4. 截图测试...\n")
  screenshot_path <- "test_screenshot.png"
  b$Page$screenshot(screenshot_path)
  if (file.exists(screenshot_path)) {
    cat(paste("  ✓ 截图已保存:", screenshot_path, "\n"))
  } else {
    cat("  ✗ 截图保存失败\n")
  }
  
  cat("\n5. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 底层 API 测试成功！\n")
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