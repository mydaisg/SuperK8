cat("========================================\n")
cat("chromote 可用功能测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 查看可用方法...\n")
methods_list <- names(s)
cat("  可用方法:\n")
for (method in methods_list) {
  cat(paste("    -", method, "\n"))
}

cat("\n3. 测试截图功能...\n")
s$screenshot("test_screenshot.png")
cat("  ✓ 截图成功\n")

cat("\n4. 测试不同的 API 调用方式...\n")

cat("  方式 1: s$navigate...\n")
tryCatch({
  s$navigate("https://www.baidu.com")
  cat("  ✓ 成功\n")
}, error = function(e) {
  cat("  ✗ 失败:", e$message, "\n")
})

Sys.sleep(2)

cat("  方式 2: s$Page$navigate...\n")
tryCatch({
  result <- s$Page$navigate("https://www.google.com")
  cat("  ✓ 成功\n")
  cat(paste("  结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ 失败:", e$message, "\n")
})

Sys.sleep(2)

cat("  方式 3: s$Runtime$evaluate...\n")
tryCatch({
  result <- s$Runtime$evaluate("document.title")
  cat("  ✓ 成功\n")
  cat(paste("  结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ 失败:", e$message, "\n")
})

cat("\n5. 再次截图...\n")
s$screenshot("test_screenshot2.png")
cat("  ✓ 截图成功\n")

cat("\n6. 关闭 Session...\n")
s$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")