cat("========================================\n")
cat("分析管理系统页面结构\n")
cat("========================================\n\n")

library(rvest)
library(httr)
library(stringr)

cat("获取页面内容...\n")
response <- GET("https://fac2023.lbbtech.com/?canaryflag=1#/home/index", 
                user_agent("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"))

content <- content(response, as = "text", encoding = "UTF-8")
cat("  ✓ 完成\n")

cat("\n页面基本信息:\n")
cat(paste("  状态码:", status_code(response), "\n"))
cat(paste("  内容长度:", nchar(content), "\n"))

cat("\n页面标题:\n")
title <- str_extract(content, "<title>.*?</title>")
if (!is.na(title)) {
  cat(paste("  ", title, "\n"))
}

cat("\n查找表单元素:\n")
forms <- str_extract_all(content, "<form[^>]*>.*?</form>")
cat(paste("  表单数量:", length(forms[[1]]), "\n"))

if (length(forms[[1]]) > 0) {
  cat("\n表单内容:\n")
  for (i in 1:min(length(forms[[1]]), 3)) {
    cat(paste("  表单", i, ":\n"))
    cat(paste("    ", substr(forms[[1]][i], 1, 200), "...\n"))
  }
}

cat("\n查找输入框:\n")
inputs <- str_extract_all(content, '<input[^>]*>')
cat(paste("  输入框数量:", length(inputs[[1]]), "\n"))

if (length(inputs[[1]]) > 0) {
  cat("\n输入框详情:\n")
  for (i in 1:min(length(inputs[[1]]), 10)) {
    input <- inputs[[1]][i]
    type <- str_extract(input, 'type="[^"]*"')
    id <- str_extract(input, 'id="[^"]*"')
    name <- str_extract(input, 'name="[^"]*"')
    placeholder <- str_extract(input, 'placeholder="[^"]*"')
    cat(paste("  [", i, "] ", 
              ifelse(!is.na(type), paste0("类型:", type, " "), ""),
              ifelse(!is.na(id), paste0("ID:", id, " "), ""),
              ifelse(!is.na(name), paste0("Name:", name, " "), ""),
              ifelse(!is.na(placeholder), paste0("Placeholder:", placeholder), ""),
              "\n", sep = ""))
  }
}

cat("\n查找按钮:\n")
buttons <- str_extract_all(content, '<button[^>]*>.*?</button>')
cat(paste("  按钮数量:", length(buttons[[1]]), "\n"))

if (length(buttons[[1]]) > 0) {
  cat("\n按钮详情:\n")
  for (i in 1:min(length(buttons[[1]]), 5)) {
    button <- buttons[[1]][i]
    cat(paste("  [", i, "] ", substr(button, 1, 100), "...\n", sep = ""))
  }
}

cat("\n查找 JavaScript 文件:\n")
scripts <- str_extract_all(content, '<script[^>]*src="[^"]*"')
cat(paste("  JavaScript 文件数量:", length(scripts[[1]]), "\n"))

if (length(scripts[[1]]) > 0) {
  cat("\nJavaScript 文件列表:\n")
  for (i in 1:min(length(scripts[[1]]), 10)) {
    script <- scripts[[1]][i]
    src <- str_extract(script, 'src="[^"]*"')
    cat(paste("  [", i, "] ", src, "\n", sep = ""))
  }
}

cat("\n查找 CSS 文件:\n")
links <- str_extract_all(content, '<link[^>]*rel="stylesheet"[^>]*>')
cat(paste("  CSS 文件数量:", length(links[[1]]), "\n"))

cat("\n查找 Vue 应用:\n")
vue_app <- str_extract(content, '<div[^>]*id="app"[^>]*>')
if (!is.na(vue_app)) {
  cat("  ✓ 找到 Vue 应用容器\n")
  cat(paste("  ", vue_app, "\n"))
} else {
  cat("  ✗ 未找到 Vue 应用容器\n")
}

cat("\n查找路由信息:\n")
hash_routes <- str_extract_all(content, '#/[a-zA-Z0-9/_-]+')
cat(paste("  路由数量:", length(hash_routes[[1]]), "\n"))

if (length(hash_routes[[1]]) > 0) {
  cat("\n路由列表:\n")
  unique_routes <- unique(hash_routes[[1]])
  for (i in 1:min(length(unique_routes), 10)) {
    cat(paste("  [", i, "] ", unique_routes[i], "\n", sep = ""))
  }
}

cat("\n========================================\n")
cat("分析完成\n")
cat("========================================\n")