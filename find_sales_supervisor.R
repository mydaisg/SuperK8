cat("========================================\n")
cat("查找销售主管信息\n")
cat("========================================\n\n")

library(chromote)
library(stringr)

cat("1. 创建新的 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ Session 创建成功\n")

cat("\n2. 导航到指定页面...\n")
tryCatch({
  b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
  cat("  ✓ 导航成功\n")
  cat("  等待页面加载...\n")
  Sys.sleep(10)
}, error = function(e) {
  cat("  ✗ 导航失败:", e$message, "\n")
})

cat("\n3. 获取当前页面信息...\n")
result <- b$Runtime$evaluate("document.title")
title <- result$value
cat(paste("  当前页面标题:", title, "\n"))

result <- b$Runtime$evaluate("window.location.href")
url <- result$value
cat(paste("  当前 URL:", url, "\n"))

cat("\n4. 截图保存（页面加载后）...\n")
b$screenshot("page_loaded.png")
cat("  ✓ 截图已保存\n")

cat("\n5. 查找所有文本内容...\n")
result <- b$Runtime$evaluate("document.body.textContent")
body_text <- result$value
cat(paste("  页面文本长度:", nchar(body_text), "字符\n"))

if (grepl("销售主管", body_text)) {
  cat("  ✓ 页面包含'销售主管'\n")
  
  cat("\n6. 提取包含'销售主管'的文本...\n")
  lines <- strsplit(body_text, "\n")[[1]]
  sales_supervisor_lines <- lines[grepl("销售主管", lines)]
  
  cat(paste("  找到", length(sales_supervisor_lines), "行包含'销售主管'\n"))
  for (i in 1:length(sales_supervisor_lines)) {
    cat(paste("    ", i, ":", sales_supervisor_lines[i], "\n"))
  }
} else {
  cat("  ✗ 页面不包含'销售主管'\n")
}

cat("\n7. 查找用户管理和角色管理...\n")
if (grepl("用户管理", body_text)) {
  cat("  ✓ 页面包含'用户管理'\n")
} else {
  cat("  ✗ 页面不包含'用户管理'\n")
}

if (grepl("角色管理", body_text)) {
  cat("  ✓ 页面包含'角色管理'\n")
} else {
  cat("  ✗ 页面不包含'角色管理'\n")
}

cat("\n8. 查找表格...\n")
result <- b$Runtime$evaluate("document.querySelectorAll('table').length")
table_count <- result$value
cat(paste("  找到", table_count, "个表格\n"))

if (table_count > 0) {
  cat("\n9. 在表格中查找销售主管...\n")
  for (i in 1:table_count) {
    table_content <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].textContent"))
    if (grepl("销售主管", table_content$value)) {
      cat(paste("  表格", i, "包含'销售主管'\n"))
      
      result <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].rows.length"))
      row_count <- result$value
      cat(paste("  表格", i, "有", row_count, "行\n"))
      
      cat("  显示包含'销售主管'的行:\n")
      for (j in 1:min(row_count, 20)) {
        row_content <- b$Runtime$evaluate(paste0("document.querySelectorAll('table')[", i-1, "].rows[", j-1, "].textContent"))
        if (grepl("销售主管", row_content$value)) {
          cat(paste("  行", j, ":", substr(row_content$value, 1, 150), "\n"))
        }
      }
    }
  }
}

cat("\n10. 截图保存...\n")
b$screenshot("sales_supervisor_search.png")
cat("  ✓ 截图已保存\n")

cat("\n11. 关闭连接...\n")
b$close()
cat("  ✓ 连接已关闭\n")

cat("\n========================================\n")
cat("查找完成\n")
cat("========================================\n")