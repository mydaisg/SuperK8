cat("========================================\n")
cat("获取页面内容\n")
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

cat("\n3. 获取页面文本内容...\n")
result <- b$Runtime$evaluate("document.body.textContent")
body_text <- result$value
cat(paste("  页面文本长度:", nchar(body_text), "字符\n"))

cat("\n4. 检查是否包含关键词...\n")
keywords <- c("销售主管", "用户管理", "角色管理", "系统管理", "登录", "账号", "验证码")

for (keyword in keywords) {
  if (grepl(keyword, body_text)) {
    cat(paste("  ✓ 找到:", keyword, "\n"))
  } else {
    cat(paste("  ✗ 未找到:", keyword, "\n"))
  }
}

cat("\n5. 保存页面文本到文件...\n")
writeLines(body_text, "page_content.txt")
cat("  ✓ 文本已保存到 page_content.txt\n")

cat("\n6. 截图...\n")
b$screenshot("system_page.png")
cat("  ✓ 截图已保存\n")

cat("\n7. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("完成\n")
cat("========================================\n")