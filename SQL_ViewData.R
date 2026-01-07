library(RSQLite)

cat("========================================\n")
cat("查看KB表中的数据\n")
cat("========================================\n\n")

db_file <- "GH_DB_LT.db"
con <- dbConnect(SQLite(), db_file)

query <- "SELECT * FROM KB ORDER BY ISSUE DESC LIMIT 10"
data <- dbGetQuery(con, query)

print(data)

cat("\n========================================\n")
cat(paste("共", nrow(data), "条记录\n"))
cat("========================================\n")

dbDisconnect(con)
