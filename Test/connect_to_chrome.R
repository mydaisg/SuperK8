cat("========================================\n")
cat("连接到已打开的Chrome浏览器\n")
cat("========================================\n\n")

library(chromote)

cat("1. 尝试连接到已打开的 Chrome 浏览器...\n")
cat("  提示: 请确保Chrome使用 --remote-debugging-port=9222 参数启动\n")
cat("  启动命令示例: chrome.exe --remote-debugging-port=9222\n\n")

b <- NULL
tryCatch({
  b <- Chrome$new(port = 9222)
  cat("  ✓ 连接成功\n")
}, error = function(e) {
  cat("  ✗ 连接失败:", e$message, "\n")
  cat("  请检查:\n")
  cat("    1. Chrome是否已启动\n")
  cat("    2. Chrome是否使用了 --remote-debugging-port=9222 参数\n")
  cat("    3. 端口9222是否被占用\n")
})

if (is.null(b)) {
  cat("\n无法连接到现有Chrome，创建新Session...\n")
  b <- ChromoteSession$new()
  cat("  ✓ 新 Session 创建成功\n")
}

cat("\n2. 获取当前页面信息...\n")
Sys.sleep(2)
result <- b$Runtime$evaluate("window.location.href")
if (!is.null(result$value) && result$value != "") {
  current_url <- result$value
  cat(paste("  当前 URL:", current_url, "\n"))
} else {
  cat("  页面未加载\n")
}

result <- b$Runtime$evaluate("document.title")
if (!is.null(result$value) && result$value != "") {
  cat(paste("  页面标题:", result$value, "\n"))
} else {
  cat("  页面标题未获取\n")
}

cat("\n3. 截图...\n")
b$screenshot("current_page.png")
cat("  ✓ 截图已保存到 current_page.png\n")

cat("\n4. 查找页面中的关键元素...\n")
result <- b$Runtime$evaluate("
  var keywords = ['系统管理', '用户管理', '角色管理', '销售主管', '登录'];
  var found = {};
  for (var i = 0; i < keywords.length; i++) {
    var elements = document.querySelectorAll('*');
    var count = 0;
    for (var j = 0; j < elements.length; j++) {
      if (elements[j].textContent && elements[j].textContent.includes(keywords[i])) {
        count++;
      }
    }
    found[keywords[i]] = count;
  }
  found;
")
found_keywords <- result$value

cat("  页面中找到的关键词:\n")
for (keyword in names(found_keywords)) {
  cat(paste("    '", keyword, "': ", found_keywords[[keyword]], " 次\n", sep = ""))
}

cat("\n5. 关闭连接...\n")
b$close()
cat("  ✓ 连接已关闭\n")

cat("\n========================================\n")
cat("完成\n")
cat("========================================\n")