cat("========================================\n")
cat("测试不同的登录方式\n")
cat("========================================\n\n")

library(httr)
library(jsonlite)

login_url <- "https://fac2023.lbbtech.com/api/login"

cat("测试 1: 使用 content_type_json()...\n")
tryCatch({
  response <- POST(login_url,
                   body = toJSON(list(
                     account = "admin",
                     pwd = "Lvcc@012345"
                   ), auto_unbox = TRUE),
                   content_type_json(),
                   user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
  
  cat(paste("  状态码:", status_code(response), "\n"))
  response_content <- content(response, as = "text", encoding = "UTF-8")
  cat(paste("  响应:", substr(response_content, 1, 1000), "...\n"))
}, error = function(e) {
  cat(paste("  错误:", e$message, "\n"))
})

cat("\n测试 2: 使用 encode = \"json\"...\n")
tryCatch({
  response <- POST(login_url,
                   body = list(
                     account = "admin",
                     pwd = "Lvcc@012345"
                   ),
                   encode = "json",
                   user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
  
  cat(paste("  状态码:", status_code(response), "\n"))
  response_content <- content(response, as = "text", encoding = "UTF-8")
  cat(paste("  响应:", substr(response_content, 1, 1000), "...\n"))
}, error = function(e) {
  cat(paste("  错误:", e$message, "\n"))
})

cat("\n测试 3: 手动构建 JSON 字符串...\n")
tryCatch({
  json_body <- '{"account":"admin","pwd":"Lvcc@012345"}'
  response <- POST(login_url,
                   body = json_body,
                   content_type_json(),
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