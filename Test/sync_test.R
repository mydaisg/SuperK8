cat("========================================\n")
cat("使用同步调用测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n立即截图...\n")
b$screenshot("sync_test.png")
cat("  ✓ 完成\n")

cat("\n尝试同步获取页面信息...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.title", timeout = 5000)
  cat(paste("  标题:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

tryCatch({
  result <- b$Runtime$evaluate("window.location.href", timeout = 5000)
  cat(paste("  URL:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")