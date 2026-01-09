cat("========================================\n")
cat("chromote 完整功能测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 测试截图功能...\n")
s$screenshot("test_screenshot.png")
if (file.exists("test_screenshot.png")) {
  cat("  ✓ 截图成功\n")
  cat(paste("  文件大小:", file.info("test_screenshot.png")$size, "字节\n"))
} else {
  cat("  ✗ 截图失败\n")
}

cat("\n3. 测试页面操作...\n")
cat("  使用 $ 调用方法...\n")

cat("  尝试 navigate...\n")
tryCatch({
  s$navigate("https://www.baidu.com")
  cat("  ✓ navigate 成功\n")
  Sys.sleep(3)
}, error = function(e) {
  cat("  ✗ navigate 失败:", e$message, "\n")
})

cat("  尝试 run_script...\n")
tryCatch({
  title <- s$run_script("document.title")
  cat(paste("  ✓ run_script 成功, 标题:", title, "\n"))
}, error = function(e) {
  cat("  ✗ run_script 失败:", e$message, "\n")
})

cat("\n4. 测试底层 API...\n")
cat("  使用 Page.navigate...\n")
tryCatch({
  result <- s$Page$navigate("https://www.google.com")
  cat("  ✓ Page.navigate 成功\n")
  Sys.sleep(3)
}, error = function(e) {
  cat("  ✗ Page.navigate 失败:", e$message, "\n")
})

cat("  使用 Runtime.evaluate...\n")
tryCatch({
  result <- s$Runtime$evaluate("document.title")
  cat("  ✓ Runtime.evaluate 成功\n")
  cat(paste("  结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ Runtime.evaluate 失败:", e$message, "\n")
})

cat("\n5. 再次截图...\n")
s$screenshot("test_screenshot2.png")
if (file.exists("test_screenshot2.png")) {
  cat("  ✓ 截图成功\n")
} else {
  cat("  ✗ 截图失败\n")
}

cat("\n6. 关闭 Session...\n")
s$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")