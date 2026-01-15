cat("========================================\n")
cat("分析管理系统页面内容\n")
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

cat("\n3. 获取页面基本信息...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  页面标题:", result$value, "\n"))

result <- b$Runtime$evaluate("window.location.href")
cat(paste("  当前 URL:", result$value, "\n"))

cat("\n4. 截图...\n")
b$screenshot("system_page.png")
cat("  ✓ 截图已保存\n")

cat("\n5. 获取页面 HTML 结构...\n")
result <- b$Runtime$evaluate("document.body.innerHTML")
html_content <- result$value
cat(paste("  HTML 内容长度:", nchar(html_content), "字符\n"))

cat("\n6. 查找关键文本...\n")
keywords <- c("销售主管", "用户管理", "角色管理", "系统管理", "登录", "账号", "验证码")

for (keyword in keywords) {
  if (grepl(keyword, html_content)) {
    cat(paste("  ✓ 找到:", keyword, "\n"))
  } else {
    cat(paste("  ✗ 未找到:", keyword, "\n"))
  }
}

cat("\n7. 查找所有按钮和链接...\n")
buttons <- b$Runtime$evaluate("document.querySelectorAll('button, a, input[type=\"button\"], input[type=\"submit\"]').length")
cat(paste("  找到", buttons$value, "个按钮和链接\n"))

cat("\n8. 查找所有输入框...\n")
inputs <- b$Runtime$evaluate("document.querySelectorAll('input[type=\"text\"], input[type=\"password\"], input[type=\"email\"]').length")
cat(paste("  找到", inputs$value, "个输入框\n"))

cat("\n9. 查找所有表格...\n")
tables <- b$Runtime$evaluate("document.querySelectorAll('table').length")
cat(paste("  找到", tables$value, "个表格\n"))

if (tables$value > 0) {
  cat("\n10. 分析表格内容...\n")
  for (i in 1:tables$value) {
    table_content <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].textContent"))
    cat(paste("  表格", i, "内容长度:", nchar(table_content$value), "字符\n"))
    
    if (grepl("销售主管", table_content$value)) {
      cat(paste("    ✓ 表格", i, "包含'销售主管'\n"))
      
      result <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].rows.length"))
      row_count <- result$value
      cat(paste("    表格", i, "有", row_count, "行\n"))
      
      for (j in 1:min(row_count, 10)) {
        row_content <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].rows[", j-1, "].textContent"))
        if (grepl("销售主管", row_content$value)) {
          cat(paste("    行", j, ":", substr(row_content$value, 1, 200), "\n"))
        }
      }
    }
  }
}

cat("\n11. 查找所有列表和列表项...\n")
lists <- b$Runtime$evaluate("document.querySelectorAll('ul, ol, li').length")
cat(paste("  找到", lists$value, "个列表项\n"))

cat("\n12. 查找所有 div 元素...\n")
divs <- b$Runtime$evaluate("document.querySelectorAll('div').length")
cat(paste("  找到", divs$value, "个 div 元素\n"))

cat("\n13. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("分析完成\n")
cat("========================================\n")