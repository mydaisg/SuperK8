cat("========================================\n")
cat("使用不同浏览器配置测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Chrome 实例（带参数）...\n")
c <- Chrome$new(
  browser_path = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe",
  args = c(
    "--disable-gpu",
    "--no-sandbox",
    "--disable-dev-shm-usage",
    "--disable-software-rasterizer",
    "--disable-extensions",
    "--disable-background-networking",
    "--disable-default-apps",
    "--disable-sync",
    "--metrics-recording-only",
    "--mute-audio",
    "--no-first-run",
    "--safebrowsing-disable-auto-update",
    "--disable-infobars",
    "--disable-notifications"
  )
)
cat("  ✓ 完成\n")

cat("\n创建 Session...\n")
b <- ChromoteSession$new(c)
cat("  ✓ 完成\n")

cat("\n导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n等待 5 秒...\n")
Sys.sleep(5)
cat("  ✓ 完成\n")

cat("\n截图...\n")
b$screenshot("custom_config_test.png")
cat("  ✓ 完成\n")

cat("\n尝试获取页面信息...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.title", timeout = 5000)
  cat(paste("  标题:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

tryCatch({
  result <- b$Runtime$evaluate("window.location.href", timeout = 5000)
  cat(paste("  URL:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n关闭 Chrome...\n")
c$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")