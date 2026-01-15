cat("========================================\n")
cat("最简测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()

cat("导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")

cat("截图...\n")
b$screenshot("simple_test.png")

cat("关闭...\n")
b$close()

cat("完成\n")