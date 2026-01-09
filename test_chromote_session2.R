cat("========================================\n")
cat("chromote ChromoteSession 测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
tryCatch({
  s <- ChromoteSession$new()
  cat("  ✓ ChromoteSession 创建成功\n")
  cat(paste("  类型:", class(s), "\n"))
  
  cat("\n2. 测试导航...\n")
  cat("  打开百度首页...\n")
  tryCatch({
    s$navigate("https://www.baidu.com")
    cat("  ✓ 导航成功\n")
    Sys.sleep(3)
  }, error = function(e) {
    cat("  ✗ 导航失败:", e$message, "\n")
  })
  
  cat("\n3. 测试 JavaScript 执行...\n")
  cat("  获取页面标题...\n")
  tryCatch({
    title <- s$run_script("document.title")
    cat(paste("  ✓ 页面标题:", title, "\n"))
  }, error = function(e) {
    cat("  ✗ 执行 JavaScript 失败:", e$message, "\n")
  })
  
  cat("\n4. 截图测试...\n")
  tryCatch({
    s$screenshot("test_screenshot.png")
    if (file.exists("test_screenshot.png")) {
      cat("  ✓ 截图成功\n")
      file.remove("test_screenshot.png")
    }
  }, error = function(e) {
    cat("  ✗ 截图失败:", e$message, "\n")
  })
  
  cat("\n5. 关闭 Session...\n")
  s$close()
  cat("  ✓ Session 已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote ChromoteSession 测试成功！\n")
  cat("========================================\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("错误详情:\n")
  print(e)
})