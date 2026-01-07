source("SPIDER_KB.R")

cat("========================================\n")
cat("验证和补充爬取2020年以来数据\n")
cat("========================================\n\n")

current_year <- as.numeric(format(Sys.Date(), "%Y"))
years_to_crawl <- current_year - 2020 + 1

cat(paste("当前年份:", current_year, "\n"))
cat(paste("需要爬取:", years_to_crawl, "年数据 (2020-", current_year, ")\n\n"))

result <- SPIDER_KB_Loop(years = years_to_crawl)

cat("\n========================================\n")
cat("爬取完成！\n")
cat("========================================\n")
cat(paste("成功:", result$success, "期\n"))
cat(paste("跳过:", result$skip, "期\n"))
cat(paste("失败:", result$fail, "期\n"))
cat("========================================\n")
