library(RSQLite)

cat("========================================\n")
cat("验证GH_DB_LT.db数据库\n")
cat("========================================\n\n")

# 连接到数据库
db_file <- "GH_DB_LT.db"
con <- dbConnect(SQLite(), db_file)

# 列出所有表
cat("数据库中的表:\n")
tables <- dbListTables(con)
print(tables)

# 查询KB表结构
cat("\nKB表结构:\n")
table_info <- dbGetQuery(con, "PRAGMA table_info(KB);")
print(table_info)

# 查询索引
cat("\nKB表的索引:\n")
indexes <- dbGetQuery(con, "PRAGMA index_list(KB);")
print(indexes)

# 查询数据行数
cat("\nKB表当前数据行数:\n")
row_count <- dbGetQuery(con, "SELECT COUNT(*) as count FROM KB;")
print(row_count)

# 关闭数据库连接
dbDisconnect(con)

cat("\n========================================\n")
cat("✓ 数据库验证完成！\n")
cat("========================================\n")
