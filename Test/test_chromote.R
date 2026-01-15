cat("========================================\n")
cat("chromote 环境测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 启动 Chrome 浏览器...\n")
tryCatch({
  b <- Chrome$new()
  cat("  ✓ Chrome 浏览器启动成功\n")
  
  cat("\n2. 测试导航操作...\n")
  cat("  打开百度首页...\n")
  b$navigate("https://www.baidu.com")
  Sys.sleep(2)
  cat("  ✓ 页面加载成功\n")
  
  cat("  获取页面标题...\n")
  title <- b$get_title()
  cat(paste("  ✓ 页面标题:", title, "\n"))
  
  cat("\n3. 测试元素操作...\n")
  cat("  查找搜索框...\n")
  search_box <- b$find_element("css selector", "#kw")
  cat("  ✓ 找到搜索框\n")
  
  cat("  输入搜索内容...\n")
  search_box$send_keys("chromote R")
  cat("  ✓ 输入成功\n")
  
  cat("  点击搜索按钮...\n")
  search_button <- b$find_element("css selector", "#su")
  search_button$click()
  Sys.sleep(2)
  cat("  ✓ 搜索操作成功\n")
  
  cat("\n4. 测试数据抓取...\n")
  cat("  获取搜索结果...\n")
  results <- b$find_elements("css selector", ".result")
  cat(paste("  ✓ 找到", length(results), "条搜索结果\n"))
  
  cat("\n5. 截图测试...\n")
  screenshot_path <- "test_screenshot.png"
  b$screenshot(screenshot_path)
  cat(paste("  ✓ 截图已保存:", screenshot_path, "\n"))
  
  cat("\n6. 关闭浏览器...\n")
  b$close()
  cat("  ✓ 浏览器已关闭\n")
  
  cat("\n========================================\n")
  cat("chromote 环境测试成功！\n")
  cat("========================================\n")
  
}, error = function(e) {
  cat(paste("\n✗ 错误:", e$message, "\n"))
  cat("请检查 Chrome 浏览器是否正确安装\n")
})