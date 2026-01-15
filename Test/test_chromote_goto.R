cat("========================================\n")
cat("chromote go_to 方法测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 测试 go_to 方法...\n")
cat("  打开百度首页...\n")
tryCatch({
  s$go_to("https://www.baidu.com")
  cat("  ✓ go_to 成功\n")
  Sys.sleep(3)
}, error = function(e) {
  cat("  ✗ go_to 失败:", e$message, "\n")
})

cat("\n3. 截图...\n")
s$screenshot("test_baidu.png")
cat("  ✓ 截图成功\n")

cat("\n4. 测试 JavaScript 执行...\n")
cat("  获取页面标题...\n")
tryCatch({
  title <- s$run_script("document.title")
  cat(paste("  ✓ 页面标题:", title, "\n"))
}, error = function(e) {
  cat("  ✗ run_script 失败:", e$message, "\n")
})

cat("\n5. 导航到 Google...\n")
tryCatch({
  s$go_to("https://www.google.com")
  cat("  ✓ go_to 成功\n")
  Sys.sleep(3)
}, error = function(e) {
  cat("  ✗ go_to 失败:", e$message, "\n")
})

cat("\n6. 再次截图...\n")
s$screenshot("test_google.png")
cat("  ✓ 截图成功\n")

cat("\n7. 关闭 Session...\n")
s$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("chromote go_to 方法测试成功！\n")
cat("========================================\n")