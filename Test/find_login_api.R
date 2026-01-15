cat("========================================\n")
cat("查找登录接口\n")
cat("========================================\n\n")

library(rvest)
library(httr)
library(jsonlite)

cat("1. 获取登录页面内容...\n")
response <- GET("https://fac2023.lbbtech.com/", 
                user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))

content <- content(response, as = "text", encoding = "UTF-8")
cat("  ✓ 完成\n")

cat("\n2. 分析 JavaScript 文件...\n")
js_files <- c(
  "https://fac2023.lbbtech.com/static/js/app.2c8de81c.js",
  "https://fac2023.lbbtech.com/static/js/chunk-elementUI.c6bf896d.js",
  "https://fac2023.lbbtech.com/static/js/chunk-libs.befdbace.js"
)

for (js_file in js_files) {
  cat(paste("\n  下载:", js_file, "\n"))
  tryCatch({
    js_response <- GET(js_file, 
                       user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
    js_content <- content(js_response, as = "text", encoding = "UTF-8")
    cat(paste("    大小:", nchar(js_content), " 字符\n"))
    
    cat("    查找登录相关 API...\n")
    
    if (grepl("login", js_content, ignore.case = TRUE)) {
      cat("    ✓ 找到 'login' 关键字\n")
      
      if (grepl("/api/.*login", js_content, ignore.case = TRUE)) {
        cat("    ✓ 找到登录 API 路径\n")
        
        login_apis <- gregexpr("/api/[^\"]*login[^\"]*", js_content, ignore.case = TRUE)
        matches <- regmatches(js_content, login_apis)
        
        if (length(matches[[1]]) > 0) {
          cat("    登录 API 列表:\n")
          unique_apis <- unique(matches[[1]])
          for (i in 1:min(length(unique_apis), 10)) {
            cat(paste("      [", i, "] ", unique_apis[i], "\n", sep = ""))
          }
        }
      }
    }
    
    if (grepl("auth", js_content, ignore.case = TRUE)) {
      cat("    ✓ 找到 'auth' 关键字\n")
    }
    
    if (grepl("token", js_content, ignore.case = TRUE)) {
      cat("    ✓ 找到 'token' 关键字\n")
    }
    
  }, error = function(e) {
    cat(paste("    错误:", e$message, "\n"))
  })
}

cat("\n3. 尝试直接登录...\n")
login_url <- "https://fac2023.lbbtech.com/api/login"
cat(paste("  尝试登录 URL:", login_url, "\n"))

login_data <- list(
  username = "admin",
  password = "Lvcc@012345"
)

tryCatch({
  login_response <- POST(login_url,
                         body = toJSON(login_data, auto_unbox = TRUE),
                         content_type_json(),
                         user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
  
  cat(paste("  状态码:", status_code(login_response), "\n"))
  cat(paste("  响应头:\n"))
  print(headers(login_response))
  
  response_content <- content(login_response, as = "text", encoding = "UTF-8")
  cat(paste("  响应内容:\n", response_content, "\n"))
  
}, error = function(e) {
  cat(paste("  错误:", e$message, "\n"))
})

cat("\n========================================\n")
cat("查找完成\n")
cat("========================================\n")