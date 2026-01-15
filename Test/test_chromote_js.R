cat("========================================\n")
cat("chromote JavaScript 执行测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 导航到百度...\n")
s$go_to("https://www.baidu.com")
cat("  ✓ 导航成功\n")
Sys.sleep(3)

cat("\n3. 测试 JavaScript 执行...\n")

cat("  方式 1: s$Runtime$evaluate...\n")
tryCatch({
  result <- s$Runtime$evaluate("document.title")
  cat("  ✓ Runtime.evaluate 成功\n")
  cat(paste("  结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ Runtime.evaluate 失败:", e$message, "\n")
})

cat("  方式 2: s$DOM$document...\n")
tryCatch({
  result <- s$DOM$getDocument()
  cat("  ✓ DOM.getDocument 成功\n")
  cat(paste("  结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ DOM.getDocument 失败:", e$message, "\n")
})

cat("\n4. 截图...\n")
s$screenshot("test_js.png")
cat("  ✓ 截图成功\n")

cat("\n5. 关闭 Session...\n")
s$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("JavaScript 执行测试完成\n")
cat("========================================\n")