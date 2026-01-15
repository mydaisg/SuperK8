library(rvest)
library(stringr)
library(RSQLite)

source("SPIDER_KB.R")

cat("========================================\n")
cat("测试爬取并插入当前数据\n")
cat("========================================\n\n")

current_data <- SPIDER_KB_Current()
cat("\n开始插入数据...\n")
result <- SPIDER_KB_Insert(current_data)

cat("\n========================================\n")
cat("测试完成！\n")
cat("========================================\n")
