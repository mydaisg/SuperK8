cat("========================================\n")
cat("chromote 完整功能测试\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 ChromoteSession...\n")
s <- ChromoteSession$new()
cat("  ✓ ChromoteSession 创建成功\n")

cat("\n2. 导航到百度...\n")
s$go_to("https://www.baidu.com")
cat("  ✓ 导航成功\n")
Sys.sleep(3)

cat("\n3. 获取页面信息...\n")
result <- s$Runtime$evaluate("document.title")
title <- result$value
cat(paste("  页面标题:", title, "\n"))

result <- s$Runtime$evaluate("window.location.href")
url <- result$value
cat(paste("  页面 URL:", url, "\n"))

cat("\n4. 测试元素操作...\n")
cat("  填写搜索框...\n")
s$Runtime$evaluate("document.getElementById('kw').value = 'chromote R'")
cat("  ✓ 填写成功\n")

cat("  点击搜索按钮...\n")
s$Runtime$evaluate("document.getElementById('su').click()")
cat("  ✓ 点击成功\n")
Sys.sleep(3)

cat("\n5. 截图...\n")
s$screenshot("test_search.png")
cat("  ✓ 截图成功\n")

cat("\n6. 提取搜索结果...\n")
result <- s$Runtime$evaluate("document.querySelectorAll('.result').length")
result_count <- result$value
cat(paste("  搜索结果数量:", result_count, "\n"))

cat("\n7. 导航到示例网站...\n")
s$go_to("https://example.com")
cat("  ✓ 导航成功\n")
Sys.sleep(2)

cat("\n8. 提取页面内容...\n")
result <- s$Runtime$evaluate("document.querySelector('h1').textContent")
heading <- result$value
cat(paste("  标题:", heading, "\n"))

result <- s$Runtime$evaluate("document.querySelector('p').textContent")
paragraph <- result$value
cat(paste("  段落:", paragraph, "\n"))

cat("\n9. 截图...\n")
s$screenshot("test_example.png")
cat("  ✓ 截图成功\n")

cat("\n10. 关闭 Session...\n")
s$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("chromote 完整功能测试成功！\n")
cat("========================================\n")