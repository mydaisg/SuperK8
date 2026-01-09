cat("========================================\n")
cat("百度导航测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 完成\n")

cat("\n等待 2 秒...\n")
Sys.sleep(2)
cat("  ✓ 完成\n")

cat("\n获取标题...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  标题:", result$value, "\n"))

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")