cat("========================================\n")
cat("使用 rvest 直接测试\n")
cat("========================================\n\n")

library(rvest)
library(httr)

cat("尝试使用 rvest 获取页面...\n")
tryCatch({
  response <- GET("https://fac2023.lbbtech.com/?canaryflag=1#/home/index", 
                  user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
  
  cat(paste("  状态码:", status_code(response), "\n"))
  cat(paste("  内容类型:", headers(response)$`content-type`, "\n"))
  
  content <- content(response, as = "text", encoding = "UTF-8")
  cat(paste("  内容长度:", nchar(content), "\n"))
  
  cat("\n内容（前1000字符）:\n")
  cat(substr(content, 1, 1000))
  cat("\n...\n")
  
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")