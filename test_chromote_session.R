cat("========================================\n")
cat("chromote Session 测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
b <- Chrome$new()
cat("  ✓ Chrome 浏览器启动成功\n")

cat("\n2. 创建 Session...\n")
tryCatch({
  s <- b$create_session()
  cat("  ✓ Session 创建成功\n")
  cat(paste("  Session 类型:", class(s), "\n"))
  
  cat("\n3. 测试 Session 的方法...\n")
  cat("  可用方法:\n")
  methods_list <- names(s)
  for (method in methods_list) {
    cat(paste("    -", method, "\n"))
  }
  
  cat("\n4. 测试导航...\n")
  tryCatch({
    s$navigate("https://www.baidu.com")
    cat("  ✓ 导航成功\n")
    Sys.sleep(3)
  }, error = function(e) {
    cat("  ✗ 导航失败:", e$message, "\n")
  })
  
  cat("\n5. 测试 JavaScript 执行...\n")
  tryCatch({
    title <- s$run_script("document.title")
    cat(paste("  ✓ 页面标题:", title, "\n"))
  }, error = function(e) {
    cat("  ✗ 执行 JavaScript 失败:", e$message, "\n")
  })
  
  cat("\n6. 截图测试...\n")
  tryCatch({
    s$screenshot("test_screenshot.png")
    if (file.exists("test_screenshot.png")) {
      cat("  ✓ 截图成功\n")
    }
  }, error = function(e) {
    cat("  ✗ 截图失败:", e$message, "\n")
  })
  
  cat("\n7. 关闭 Session...\n")
  s$close()
  cat("  ✓ Session 已关闭\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("错误详情:\n")
  print(e)
})

cat("\n8. 关闭浏览器...\n")
b$close()
cat("  ✓ 浏览器已关闭\n")

cat("\n========================================\n")
cat("chromote Session 测试完成\n")
cat("========================================\n")