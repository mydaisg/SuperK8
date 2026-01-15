cat("========================================\n")
cat("测试 chromote 基本功能\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("   ✓ 完成\n")

cat("\n2. 导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("   ✓ 完成\n")

cat("\n3. 等待 3 秒...\n")
Sys.sleep(3)
cat("   ✓ 完成\n")

cat("\n4. 获取页面信息...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("   标题:", result$value, "\n"))

cat("\n5. 截图...\n")
b$screenshot("baidu_simple.png")
cat("   ✓ 截图已保存\n")

cat("\n6. 关闭 Session...\n")
b$close()
cat("   ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")