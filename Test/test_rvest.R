cat("========================================\n")
cat("rvest 网页抓取测试\n")
cat("========================================\n\n")

library(rvest)
library(stringr)

cat("1. 测试网页抓取...\n")
tryCatch({
  cat("  抓取百度首页...\n")
  page <- read_html("https://www.baidu.com")
  cat("  ✓ 页面抓取成功\n")
  
  cat("\n2. 提取页面信息...\n")
  cat("  获取页面标题...\n")
  title <- page %>% html_node("title") %>% html_text()
  cat(paste("  ✓ 页面标题:", title, "\n"))
  
  cat("  获取所有链接...\n")
  links <- page %>% html_nodes("a") %>% html_attr("href")
  cat(paste("  ✓ 找到", length(links), "个链接\n"))
  
  cat("\n3. 测试表格抓取...\n")
  cat("  抓取维基百科示例表格...\n")
  wiki_page <- read_html("https://zh.wikipedia.org/wiki/HTML")
  tables <- wiki_page %>% html_table(fill = TRUE)
  cat(paste("  ✓ 找到", length(tables), "个表格\n"))
  
  if (length(tables) > 0) {
    cat("  第一个表格的行数:", nrow(tables[[1]]), "\n")
    cat("  第一个表格的列数:", ncol(tables[[1]]), "\n")
  }
  
  cat("\n========================================\n")
  cat("rvest 网页抓取测试成功！\n")
  cat("========================================\n")
  cat("\n说明:\n")
  cat("- rvest 适合静态网页抓取\n")
  cat("- 对于需要交互的页面（点击、填写表单），需要使用浏览器自动化\n")
  cat("- 如果需要浏览器自动化，建议安装 Java 并使用 RSelenium\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("请检查网络连接\n")
})