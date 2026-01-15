cat("========================================\n")
cat("登录并访问 API\n")
cat("========================================\n\n")

library(httr)
library(jsonlite)

login_url <- "https://fac2023.lbbtech.com/api/login"

cat("1. 登录系统...\n")
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
  response_json <- fromJSON(response_content)
  
  if (response_json$success) {
    cat("  ✓ 登录成功\n")
    
    token <- response_json$data$token
    user_info <- response_json$data$user
    
    cat(paste("  用户名:", user_info$username, "\n"))
    cat(paste("  真实姓名:", user_info$raleName, "\n"))
    cat(paste("  Token:", substr(token, 1, 50), "...\n"))
    cat(paste("  权限数量:", length(response_json$data$permissions), "\n"))
    
    cat("\n2. 尝试访问用户管理 API...\n")
    
    user_api_urls <- c(
      "https://fac2023.lbbtech.com/api/user/list",
      "https://fac2023.lbbtech.com/api/user/page",
      "https://fac2023.lbbtech.com/api/user/query",
      "https://fac2023.lbbtech.com/api/system/user/list"
    )
    
    for (api_url in user_api_urls) {
      cat(paste("\n  尝试:", api_url, "\n"))
      
      tryCatch({
        api_response <- GET(api_url,
                            add_headers(
                              "Authorization" = paste("Bearer", token),
                              "token" = token
                            ),
                            user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
        
        cat(paste("    状态码:", status_code(api_response), "\n"))
        
        if (status_code(api_response) == 200) {
          api_content <- content(api_response, as = "text", encoding = "UTF-8")
          api_json <- fromJSON(api_content)
          
          if (api_json$success) {
            cat("    ✓ 成功\n")
            cat(paste("    响应:", substr(api_content, 1, 500), "...\n"))
          } else {
            cat(paste("    失败:", api_json$message, "\n"))
          }
        } else {
          cat("    失败\n")
        }
      }, error = function(e) {
        cat(paste("    错误:", e$message, "\n"))
      })
    }
    
    cat("\n3. 尝试访问角色管理 API...\n")
    
    role_api_urls <- c(
      "https://fac2023.lbbtech.com/api/role/list",
      "https://fac2023.lbbtech.com/api/role/page",
      "https://fac2023.lbbtech.com/api/system/role/list"
    )
    
    for (api_url in role_api_urls) {
      cat(paste("\n  尝试:", api_url, "\n"))
      
      tryCatch({
        api_response <- GET(api_url,
                            add_headers(
                              "Authorization" = paste("Bearer", token),
                              "token" = token
                            ),
                            user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))
        
        cat(paste("    状态码:", status_code(api_response), "\n"))
        
        if (status_code(api_response) == 200) {
          api_content <- content(api_response, as = "text", encoding = "UTF-8")
          api_json <- fromJSON(api_content)
          
          if (api_json$success) {
            cat("    ✓ 成功\n")
            cat(paste("    响应:", substr(api_content, 1, 500), "...\n"))
          } else {
            cat(paste("    失败:", api_json$message, "\n"))
          }
        } else {
          cat("    失败\n")
        }
      }, error = function(e) {
        cat(paste("    错误:", e$message, "\n"))
      })
    }
    
  } else {
    cat(paste("  ✗ 登录失败:", response_json$message, "\n"))
  }
  
}, error = function(e) {
  cat(paste("  错误:", e$message, "\n"))
})

cat("\n========================================\n")
cat("完成\n")
cat("========================================\n")