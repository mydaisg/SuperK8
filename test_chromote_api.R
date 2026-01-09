cat("========================================\n")
cat("chromote API 探索\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
b <- Chrome$new()
cat("  ✓ Chrome 浏览器启动成功\n")

cat("\n2. 探索浏览器对象的方法...\n")
cat("  可用方法:\n")
methods_list <- names(b)
for (method in methods_list) {
  cat(paste("    -", method, "\n"))
}

cat("\n3. 测试不同的调用方式...\n")

cat("\n  方式 1: 直接调用方法...\n")
tryCatch({
  result <- b$navigate("https://www.baidu.com")
  cat("  ✓ 直接调用成功\n")
}, error = function(e) {
  cat("  ✗ 直接调用失败:", e$message, "\n")
})

Sys.sleep(3)

cat("\n  方式 2: 使用 $ 符号访问...\n")
tryCatch({
  result <- b$Page$navigate("https://www.baidu.com")
  cat("  ✓ $ 符号访问成功\n")
}, error = function(e) {
  cat("  ✗ $ 符号访问失败:", e$message, "\n")
})

Sys.sleep(3)

cat("\n  方式 3: 使用 Runtime.evaluate...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.title")
  cat("  ✓ Runtime.evaluate 成功\n")
  cat(paste("    结果:", result, "\n"))
}, error = function(e) {
  cat("  ✗ Runtime.evaluate 失败:", e$message, "\n")
})

cat("\n4. 关闭浏览器...\n")
b$close()
cat("  ✓ 浏览器已关闭\n")

cat("\n========================================\n")
cat("chromote API 探索完成\n")
cat("========================================\n")