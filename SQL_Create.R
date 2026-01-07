library(RSQLite)

cat("========================================\n")
cat("创建GH_DB_LT.db数据库\n")
cat("========================================\n\n")

# 连接到数据库（如果不存在会自动创建）
db_file <- "GH_DB_LT.db"
cat(paste("正在创建数据库:", db_file, "\n"))
con <- dbConnect(SQLite(), db_file)

# 创建KB表
cat("正在创建KB表...\n")
create_table_sql <- "
CREATE TABLE IF NOT EXISTS KB (
    ISSUE       INT     PRIMARY KEY NOT NULL,
    KB1          INT     NOT NULL,
    KB2          INT     NOT NULL,
    KB3          INT     NOT NULL,
    KB4          INT     NOT NULL,
    KB5          INT     NOT NULL,
    KB6          INT     NOT NULL,
    KB7          INT     NOT NULL,
    KB8          INT     NOT NULL,
    KB9          INT     NOT NULL,
    KB10          INT     NOT NULL,
    KB11          INT     NOT NULL,
    KB12          INT     NOT NULL,
    KB13          INT     NOT NULL,
    KB14          INT     NOT NULL,
    KB15          INT     NOT NULL,
    KB16          INT     NOT NULL,
    KB17          INT     NOT NULL,
    KB18          INT     NOT NULL,
    KB19          INT     NOT NULL,
    KB20          INT     NOT NULL,
    SALES       INT     NOT NULL,
    POOL       INT     NOT NULL,
    DATES       TEXT    NOT NULL
);
"

dbExecute(con, create_table_sql)
cat("✓ KB表创建成功\n\n")

# 创建索引以提高查询性能
cat("正在创建索引...\n")
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_dates ON KB(DATES);")
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_sales ON KB(SALES);")
dbExecute(con, "CREATE INDEX IF NOT EXISTS idx_pool ON KB(POOL);")
cat("✓ 索引创建成功\n\n")

# 验证表结构
cat("验证表结构:\n")
table_info <- dbGetQuery(con, "PRAGMA table_info(KB);")
print(table_info)

# 关闭数据库连接
dbDisconnect(con)

cat("\n========================================\n")
cat("✓ GH_DB_LT.db数据库创建完成！\n")
cat("========================================\n")
