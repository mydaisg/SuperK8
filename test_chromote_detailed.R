cat("========================================\n")
cat("chromote 详细测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 检查 chromote 版本...\n")
cat(paste("  chromote 版本:", packageVersion("chromote"), "\n\n"))

cat("2. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  
  cat("\n3. 测试导航操作...\n")
  cat("  打开百度首页...\n")
  b$navigate("https://www.baidu.com")
  Sys.sleep(3)
  cat("  ✓ 页面加载成功\n")
  
  cat("\n4. 使用 JavaScript 获取页面信息...\n")
  cat("  获取页面标题...\n")
  title_result <- b$Runtime$evaluate("document.title")
  title <- title_result$result$value
  cat(paste("  ✓ 页面标题:", title, "\n"))
  
  cat("  获取页面 URL...\n")
  url_result <- b$Runtime$evaluate("window.location.href")
  url <- url_result$result$value
  cat(paste("  ✓ 页面 URL:", url, "\n"))
  
  cat("\n5. 测试元素操作...\n")
  cat("  使用 JavaScript 填写搜索框...\n")
  b$Runtime$evaluate("document.getElementById('kw').value = 'chromote R'")
  cat("  ✓ 填写成功\n")
  
  cat("  使用 JavaScript 点击搜索按钮...\n")
  b$Runtime$evaluate("document.getElementById('su').click()")
  Sys.sleep(2)
  cat("  ✓ 点击成功\n")
  
  cat("\n6. 截图测试...\n")
  screenshot_path <- "test_screenshot.png"
  b$screenshot(screenshot_path)
  if (file.exists(screenshot_path)) {
    cat(paste("  ✓ 截图已保存:", screenshot_path, "\n"))
    cat(paste("  文件大小:", file.info(screenshot_path)$size, "字节\n"))
  } else {
    cat("  ✗ 截图保存失败\n")
  }
  
  cat("\n7. 获取页面 HTML...\n")
  html_result <- b$Runtime$evaluate("document.documentElement.outerHTML")
  html_length <- nchar(html_result$result$value)
  cat(paste("  ✓ HTML 长度:", html_length, "字符\n"))
  
  cat("\n8. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 测试成功！\n")
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