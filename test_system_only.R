cat("========================================\n")
cat("测试管理系统访问\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ Session 创建成功\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 导航成功\n")
cat("  等待页面加载...\n")
Sys.sleep(10)

cat("\n3. 截图...\n")
b$screenshot("system_access_test.png")
cat("  ✓ 截图已保存\n")

cat("\n4. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")