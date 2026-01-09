cat("========================================\n")
cat("重新测试登录\n")
cat("========================================\n\n")

library(httr)
library(jsonlite)

login_url <- "https://fac2023.lbbtech.com/api/login"

cat("测试 1: 使用 account 和 pwd (form)...\n")
tryCatch({
  response <- POST(login_url,
                   body = list(
                     account = "admin",
                     pwd = "Lvcc@012345"
                   ),
                   encode = "form",
                   user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
  
  cat(paste("  状态码:", status_code(response), "\n"))
  response_content <- content(response, as = "text", encoding = "UTF-8")
  cat(paste("  响应:", substr(response_content, 1, 1000), "...\n"))
}, error = function(e) {
  cat(paste("  错误:", e$message, "\n"))
})

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")