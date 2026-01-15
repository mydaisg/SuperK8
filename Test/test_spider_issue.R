library(rvest)
library(stringr)
library(RSQLite)

source("SPIDER_KB.R")

cat("========================================\n")
cat("测试爬取指定期数数据\n")
cat("========================================\n\n")

test_issue <- 2026005
cat(paste("测试爬取期号:", test_issue, "\n\n"))

kb_data <- SPIDER_KB_Issue(test_issue)

if (!is.null(kb_data)) {
  cat("\n开始插入数据...\n")
  result <- SPIDER_KB_Insert(kb_data)
  
  cat("\n========================================\n")
  cat("测试完成！\n")
  cat("========================================\n")
} else {
  cat("\n========================================\n")
  cat("爬取失败！\n")
  cat("========================================\n")
}
