cat("========================================\n")
cat("使用 rvest 分析管理系统\n")
cat("========================================\n\n")

library(rvest)
library(httr)

cat("尝试访问管理系统...\n")
url <- "https://fac2023.lbbtech.com/?canaryflag=1#/home/index"

tryCatch({
  response <- GET(url)
  cat(paste("  状态码:", status_code(response), "\n"))
  cat(paste("  内容类型:", headers(response)$`content-type`, "\n"))
  
  content <- content(response, as = "text", encoding = "UTF-8")
  cat(paste("  内容长度:", nchar(content), "\n"))
  
  cat("\n分析页面内容...\n")
  
  page <- read_html(content)
  
  cat("\n查找标题...\n")
  title <- page %>% html_nodes("title") %>% html_text()
  cat(paste("  标题:", title, "\n"))
  
  cat("\n查找输入框...\n")
  inputs <- page %>% html_nodes("input")
  cat(paste("  输入框数量:", length(inputs), "\n"))
  
  if (length(inputs) > 0) {
    cat("  输入框信息:\n")
    for (i in seq_along(inputs)) {
      input_type <- inputs[[i]] %>% html_attr("type")
      input_id <- inputs[[i]] %>% html_attr("id")
      input_name <- inputs[[i]] %>% html_attr("name")
      cat(paste("    [", i, "] 类型:", input_type,
                ifelse(input_id != "", paste0(", ID:", input_id), ""),
                ifelse(input_name != "", paste0(", Name:", input_name), ""),
                "\n", sep = ""))
    }
  }
  
  cat("\n查找按钮...\n")
  buttons <- page %>% html_nodes("button")
  cat(paste("  按钮数量:", length(buttons), "\n"))
  
  if (length(buttons) > 0) {
    cat("  按钮文字:\n")
    for (i in seq_along(buttons)) {
      button_text <- buttons[[i]] %>% html_text()
      cat(paste("    [", i, "]", button_text, "\n", sep = ""))
    }
  }
  
  cat("\n查找链接...\n")
  links <- page %>% html_nodes("a")
  cat(paste("  链接数量:", length(links), "\n"))
  
  if (length(links) > 0) {
    cat("  链接文字（前10个）:\n")
    for (i in 1:min(10, length(links))) {
      link_text <- links[[i]] %>% html_text()
      link_href <- links[[i]] %>% html_attr("href")
      cat(paste("    [", i, "]", link_text, 
                ifelse(link_href != "", paste0(" -> ", link_href), ""),
                "\n", sep = ""))
    }
  }
  
  cat("\n查找关键词...\n")
  keywords <- c("系统管理", "用户管理", "角色管理", "销售主管", "登录")
  for (keyword in keywords) {
    elements <- page %>% html_nodes(xpath = paste0("//*[contains(text(), '", keyword, "')]"))
    cat(paste("  '", keyword, "':", length(elements), "个匹配\n", sep = ""))
  }
  
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n========================================\n")
cat("分析完成\n")
cat("========================================\n")