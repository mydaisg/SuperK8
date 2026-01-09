cat("========================================\n")
cat("详细调试测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Chrome 对象...\n")
c <- Chrome$new()
cat("  ✓ 完成\n")

cat("\n创建 Session...\n")
b <- ChromoteSession$new(c)
cat("  ✓ 完成\n")

cat("\n导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 完成\n")

cat("\n等待 5 秒...\n")
Sys.sleep(5)
cat("  ✓ 完成\n")

cat("\n获取浏览器信息...\n")
tryCatch({
  version <- b$Browser$getVersion()
  cat(paste("  用户代理:", version$userAgent, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n获取页面信息...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.title")
  cat(paste("  标题:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

tryCatch({
  result <- b$Runtime$evaluate("window.location.href")
  cat(paste("  URL:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

tryCatch({
  result <- b$Runtime$evaluate("document.readyState")
  cat(paste("  就绪状态:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n截图...\n")
tryCatch({
  b$screenshot("debug_test.png")
  cat("  ✓ 完成\n")
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n关闭 Chrome...\n")
c$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")