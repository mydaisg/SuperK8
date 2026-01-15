cat("========================================\n")
cat("测试基本导航\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ Session 创建成功\n")

cat("\n2. 导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 导航成功\n")
Sys.sleep(3)

cat("\n3. 截图百度...\n")
b$screenshot("baidu_test.png")
cat("  ✓ 截图已保存\n")

cat("\n4. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")