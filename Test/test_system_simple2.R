cat("========================================\n")
cat("测试管理系统访问\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("   ✓ 完成\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("   ✓ 完成\n")

cat("\n3. 等待 5 秒...\n")
Sys.sleep(5)
cat("   ✓ 完成\n")

cat("\n4. 获取页面信息...\n")
result <- b$Runtime$evaluate("window.location.href")
cat(paste("   URL:", result$value, "\n"))

result <- b$Runtime$evaluate("document.title")
cat(paste("   标题:", result$value, "\n"))

cat("\n5. 截图...\n")
b$screenshot("system_simple.png")
cat("   ✓ 截图已保存\n")

cat("\n6. 关闭 Session...\n")
b$close()
cat("   ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")