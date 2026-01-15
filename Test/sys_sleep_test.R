cat("========================================\n")
cat("使用 Sys.sleep 等待测试\n")
cat("========================================\n\n")

library(chromote)

cat("步骤 1: 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n步骤 2: 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n步骤 3: 等待 5 秒...\n")
Sys.sleep(5)
cat("  ✓ 完成\n")

cat("\n步骤 4: 截图...\n")
b$screenshot("sys_sleep.png")
cat("  ✓ 完成\n")

cat("\n步骤 5: 获取 URL...\n")
result <- b$Runtime$evaluate("window.location.href")
cat(paste("  URL: ", result$value, "\n", sep = ""))

cat("\n步骤 6: 获取标题...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  标题: ", result$value, "\n", sep = ""))

cat("\n步骤 7: 关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")