cat("========================================\n")
cat("检查页面类型\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()

cat("导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")

cat("等待 3 秒...\n")
Sys.sleep(3)

cat("\n检查页面元素...\n")

cat("1. 查找输入框...\n")
inputs <- b$Runtime$evaluate("document.querySelectorAll('input').length")
cat(paste("   输入框数量:", inputs$value, "\n"))

if (inputs$value > 0) {
  cat("\n2. 获取输入框类型...\n")
  input_types <- b$Runtime$evaluate("Array.from(document.querySelectorAll('input')).map(i => i.type).join(', ')")
  cat(paste("   类型:", input_types$value, "\n"))
  
  cat("\n3. 查找密码输入框...\n")
  password_count <- b$Runtime$evaluate("document.querySelectorAll('input[type=\"password\"]').length")
  cat(paste("   密码框数量:", password_count$value, "\n"))
  
  cat("\n4. 查找登录按钮...\n")
  buttons <- b$Runtime$evaluate("document.querySelectorAll('button').length")
  cat(paste("   按钮数量:", buttons$value, "\n"))
  
  if (buttons$value > 0) {
    button_texts <- b$Runtime$evaluate("Array.from(document.querySelectorAll('button')).map(b => b.textContent.trim()).filter(t => t).join(' | ')")
    cat(paste("   按钮文字:", button_texts$value, "\n"))
  }
}

cat("\n5. 获取页面标题...\n")
title <- b$Runtime$evaluate("document.title")
cat(paste("   标题:", title$value, "\n"))

cat("\n6. 获取 URL...\n")
url <- b$Runtime$evaluate("window.location.href")
cat(paste("   URL:", url$value, "\n"))

cat("\n7. 截图...\n")
b$screenshot("page_check.png")

cat("关闭...\n")
b$close()

cat("\n========================================\n")
cat("检查完成\n")
cat("========================================\n")