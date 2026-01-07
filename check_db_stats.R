source("SPIDER_KB.R")
result <- SPIDER_KB_Loop(years = 5)library(RSQLite)

db_file <- "GH_DB_LT.db"
con <- dbConnect(SQLite(), db_file)

query <- "SELECT COUNT(*) as total FROM KB"
result <- dbGetQuery(con, query)

cat("========================================\n")
cat("数据库统计\n")
cat("========================================\n")
cat(paste("KB表总记录数:", result$total, "\n"))

query <- "SELECT MIN(ISSUE) as min_issue, MAX(ISSUE) as max_issue FROM KB"
result <- dbGetQuery(con, query)

cat(paste("最小期号:", result$min_issue, "\n"))
cat(paste("最大期号:", result$max_issue, "\n"))

query <- "SELECT ISSUE FROM KB ORDER BY ISSUE DESC LIMIT 10"
result <- dbGetQuery(con, query)

cat("\n最近10期:\n")
print(result)

dbDisconnect(con)
