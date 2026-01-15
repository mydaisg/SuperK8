library(rvest)
library(stringr)
library(RSQLite)

source("SPIDER_KB.R")

cat("========================================\n")
cat("测试循环爬取最近10期数据\n")
cat("========================================\n\n")

current_data <- SPIDER_KB_Current()
current_issue <- as.numeric(current_data$KB_ISSUE)
start_issue <- current_issue
end_issue <- current_issue - 9

cat(paste("爬取范围:", start_issue, "至", end_issue, "\n\n"))

success_count <- 0
skip_count <- 0
fail_count <- 0

for (issue in start_issue:end_issue) {
  cat(paste("\n正在处理期号:", issue, "\n"))
  
  kb_data <- SPIDER_KB_Issue(issue)
  
  if (!is.null(kb_data)) {
    result <- SPIDER_KB_Insert(kb_data)
    if (result > 0) {
      success_count <- success_count + 1
    } else {
      skip_count <- skip_count + 1
    }
  } else {
    fail_count <- fail_count + 1
  }
  
  Sys.sleep(0.5)
}

cat("\n========================================\n")
cat("爬取完成统计:\n")
cat(paste("  成功插入:", success_count, "期\n"))
cat(paste("  跳过已存在:", skip_count, "期\n"))
cat(paste("  失败:", fail_count, "期\n"))
cat("========================================\n")

cat("\n========================================\n")
cat("测试完成！\n")
cat("========================================\n")
