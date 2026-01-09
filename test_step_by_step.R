cat("========================================\n")
cat("逐步测试管理系统访问\n")
cat("========================================\n\n")

library(chromote)

cat("步骤 1: 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n步骤 2: 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n步骤 3: 等待 10 秒...\n")
Sys.sleep(10)
cat("  ✓ 完成\n")

cat("\n步骤 4: 获取 URL...\n")
result <- b$Runtime$evaluate("window.location.href")
cat(paste("  URL:", result$value, "\n"))

cat("\n步骤 5: 获取页面标题...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  标题:", result$value, "\n"))

cat("\n步骤 6: 截图...\n")
b$screenshot("step6_page.png")
cat("  ✓ 截图已保存\n")

cat("\n步骤 7: 查找关键词...\n")
result <- b$Runtime$evaluate("
  var text = document.body ? document.body.textContent : '';
  var keywords = ['系统管理', '用户管理', '角色管理', '登录', '账号', '验证码'];
  var found = {};
  for (var i = 0; i < keywords.length; i++) {
    found[keywords[i]] = text.includes(keywords[i]);
  }
  found;
")
found <- result$value
for (keyword in names(found)) {
  status <- if (found[[keyword]]) "✓" else "✗"
  cat(paste("  ", status, " ", keyword, "\n", sep = ""))
}

cat("\n步骤 8: 关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")