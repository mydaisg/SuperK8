cat("========================================\n")
cat("分步测试\n")
cat("========================================\n\n")

library(chromote)

cat("步骤 1: 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n步骤 2: 截图（空白页）...\n")
b$screenshot("step1_blank.png")
cat("  ✓ 完成\n")

cat("\n步骤 3: 导航到百度...\n")
b$go_to("https://www.baidu.com")
cat("  ✓ 完成\n")

cat("\n步骤 4: 截图（百度）...\n")
b$screenshot("step2_baidu.png")
cat("  ✓ 完成\n")

cat("\n步骤 5: 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n步骤 6: 截图（管理系统）...\n")
b$screenshot("step3_system.png")
cat("  ✓ 完成\n")

cat("\n步骤 7: 关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")