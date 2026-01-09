cat("========================================\n")
cat("诊断测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("   ✓ 完成\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("   ✓ 完成\n")

cat("\n3. 等待 3 秒...\n")
Sys.sleep(3)
cat("   ✓ 完成\n")

cat("\n4. 截图...\n")
b$screenshot("diagnostic1.png")
cat("   ✓ 截图1已保存\n")

cat("\n5. 获取页面 URL...\n")
result <- b$Runtime$evaluate("window.location.href")
cat(paste("   URL:", result$value, "\n"))

cat("\n6. 等待 5 秒...\n")
Sys.sleep(5)
cat("   ✓ 完成\n")

cat("\n7. 截图...\n")
b$screenshot("diagnostic2.png")
cat("   ✓ 截图2已保存\n")

cat("\n8. 关闭 Session...\n")
b$close()
cat("   ✓ 完成\n")

cat("\n========================================\n")
cat("诊断完成\n")
cat("========================================\n")