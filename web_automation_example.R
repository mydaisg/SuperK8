cat("========================================\n")
cat("Web 自动化示例 - 用户授权和数据提取\n")
cat("========================================\n\n")

library(chromote)
library(DBI)
library(RSQLite)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 连接到 SQLite 数据库...\n")
db <- dbConnect(SQLite(), "web_automation.db")
cat("  ✓ 数据库连接成功\n")

cat("\n3. 创建数据表...\n")
dbExecute(db, "CREATE TABLE IF NOT EXISTS user_authorizations (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT,
  action TEXT,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
  status TEXT
)")
cat("  ✓ 数据表创建成功\n")

cat("\n4. 模拟用户授权流程...\n")
cat("  步骤 1: 导航到登录页面...\n")
s$go_to("https://example.com/login")
cat("  ✓ 导航成功\n")
Sys.sleep(2)

cat("  步骤 2: 填写用户名...\n")
s$Runtime$evaluate("document.getElementById('username').value = 'test_user'")
cat("  ✓ 用户名填写成功\n")

cat("  步骤 3: 填写密码...\n")
s$Runtime$evaluate("document.getElementById('password').value = 'password123'")
cat("  ✓ 密码填写成功\n")

cat("  步骤 4: 点击登录按钮...\n")
s$Runtime$evaluate("document.getElementById('login-btn').click()")
cat("  ✓ 登录按钮点击成功\n")
Sys.sleep(3)

cat("  步骤 5: 记录授权操作...\n")
dbExecute(db, "INSERT INTO user_authorizations (username, action, status) VALUES (?, ?, ?)",
          params = list("test_user", "login", "success"))
cat("  ✓ 授权操作已记录\n")

cat("\n5. 提取业务数据...\n")
cat("  步骤 1: 导航到数据页面...\n")
s$go_to("https://example.com/data")
cat("  ✓ 导航成功\n")
Sys.sleep(2)

cat("  步骤 2: 提取表格数据...\n")
result <- s$Runtime$evaluate("document.querySelectorAll('table tr').length")
row_count <- result$value
cat(paste("  表格行数:", row_count, "\n"))

cat("  步骤 3: 提取数据并保存到数据库...\n")
for (i in 1:min(row_count - 1, 10)) {
  row_data <- s$Runtime$evaluate(paste0("document.querySelectorAll('table tr')[", i, "].textContent"))
  cat(paste("  行", i, ":", substr(row_data$value, 1, 50), "...\n"))
}

cat("\n6. 导出数据到 Excel...\n")
cat("  从数据库查询数据...\n")
data <- dbGetQuery(db, "SELECT * FROM user_authorizations")
cat(paste("  查询到", nrow(data), "条记录\n"))

cat("  保存到 CSV (Excel 可打开)...\n")
write.csv(data, "user_authorizations.csv", row.names = FALSE)
cat("  ✓ 数据已导出到 user_authorizations.csv\n")

cat("\n7. 截图保存...\n")
s$screenshot("web_automation_screenshot.png")
cat("  ✓ 截图已保存\n")

cat("\n8. 关闭连接...\n")
s$close()
dbDisconnect(db)
cat("  ✓ 浏览器和数据库连接已关闭\n")

cat("\n========================================\n")
cat("Web 自动化示例完成！\n")
cat("========================================\n")