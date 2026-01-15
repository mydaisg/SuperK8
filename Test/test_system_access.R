cat("========================================\n")
cat("测试页面访问\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ Session 创建成功\n")

cat("\n2. 导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 导航成功\n")
Sys.sleep(3)

cat("\n3. 获取百度页面信息...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  标题:", result$value, "\n"))

result <- b$Runtime$evaluate("window.location.href")
cat(paste("  URL:", result$value, "\n"))

cat("\n4. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 导航成功\n")
Sys.sleep(5)

cat("\n5. 获取管理系统页面信息...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  标题:", result$value, "\n"))

result <- b$Runtime$evaluate("window.location.href")
cat(paste("  URL:", result$value, "\n"))

cat("\n6. 截图...\n")
b$screenshot("test_system_access.png")
cat("  ✓ 截图已保存\n")

cat("\n7. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")