cat("========================================\n")
cat("导航但不等待\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 完成\n")

cat("\n立即截图...\n")
b$screenshot("no_wait_baidu.png")
cat("  ✓ 完成\n")

cat("\n立即关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")