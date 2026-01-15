cat("========================================\n")
cat("查看页面源代码\n")
cat("========================================\n\n")

library(rvest)
library(httr)

cat("尝试访问管理系统...\n")
url <- "https://fac2023.lbbtech.com/?canaryflag=1#/home/index"

tryCatch({
  response <- GET(url)
  content <- content(response, as = "text", encoding = "UTF-8")
  
  cat("\n页面内容（前2000字符）:\n")
  cat(paste(substr(content, 1, 2000), "\n"))
  
  cat("\n页面内容（后2000字符）:\n")
  cat(paste(substr(content, nchar(content) - 1999, nchar(content)), "\n"))
  
  cat("\n查找 JavaScript 文件...\n")
  js_files <- content %>% 
    read_html() %>% 
    html_nodes("script") %>% 
    html_attr("src")
  
  cat(paste("  找到", length(js_files), "个 JavaScript 文件:\n"))
  for (i in seq_along(js_files)) {
    if (!is.na(js_files[i])) {
      cat(paste("    [", i, "]", js_files[i], "\n", sep = ""))
    }
  }
  
  cat("\n查找 CSS 文件...\n")
  css_files <- content %>% 
    read_html() %>% 
    html_nodes("link[rel='stylesheet']") %>% 
    html_attr("href")
  
  cat(paste("  找到", length(css_files), "个 CSS 文件:\n"))
  for (i in seq_along(css_files)) {
    if (!is.na(css_files[i])) {
      cat(paste("    [", i, "]", css_files[i], "\n", sep = ""))
    }
  }
  
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n========================================\n")
cat("查看完成\n")
cat("========================================\n")