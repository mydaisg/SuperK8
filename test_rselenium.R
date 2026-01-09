cat("========================================\n")
cat("RSelenium 环境测试\n")
cat("========================================\n\n")

library(RSelenium)
library(wdman)

cat("1. 检查 Chrome 浏览器...\n")
chrome_path <- "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe"
if (file.exists(chrome_path)) {
  cat(paste("  ✓ Chrome 浏览器已安装:", chrome_path, "\n"))
} else {
  cat("  ✗ Chrome 浏览器未找到\n")
  stop("请先安装 Chrome 浏览器")
}

cat("\n2. 启动 ChromeDriver...\n")
tryCatch({
  driver <- rsDriver(
    browser = "chrome",
    chromever = "latest",
    verbose = FALSE
  )
  
  cat("  ✓ ChromeDriver 启动成功\n")
  
  remDr <- driver[["client"]]
  
  cat("\n3. 测试浏览器操作...\n")
  
  cat("  打开百度首页...\n")
  remDr$navigate("https://www.baidu.com")
  Sys.sleep(2)
  cat("  ✓ 页面加载成功\n")
  
  cat("  获取页面标题...\n")
  title <- remDr$getTitle()[[1]]
  cat(paste("  ✓ 页面标题:", title, "\n"))
  
  cat("  搜索测试...\n")
  search_box <- remDr$findElement(using = "id", value = "kw")
  search_box$sendKeysToElement("RSelenium R")
  search_button <- remDr$findElement(using = "id", value = "su")
  search_button$clickElement()
  Sys.sleep(2)
  cat("  ✓ 搜索操作成功\n")
  
  cat("\n4. 关闭浏览器...\n")
  remDr$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("RSelenium 环境测试成功！\n")
  cat("========================================\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("请检查网络连接或 ChromeDriver 版本\n")
  
  cat("\n尝试手动下载 ChromeDriver...\n")
  cat("访问: https://chromedriver.chromium.org/downloads\n")
  cat("或使用: install.packages('chromote')\n")
})