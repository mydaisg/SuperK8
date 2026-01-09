cat("========================================\n")
cat("连接到已打开的Chrome浏览器\n")
cat("========================================\n\n")

library(chromote)

cat("1. 尝试连接到已打开的 Chrome 浏览器...\n")
cat("   端口: 9222\n")

b <- NULL
tryCatch({
  b <- Chrome$new(port = 9222)
  cat("   ✓ 连接成功\n")
}, error = function(e) {
  cat("   ✗ 连接失败:", e$message, "\n")
  cat("   说明: Chrome 需要使用 --remote-debugging-port=9222 参数启动\n")
})

if (!is.null(b)) {
  cat("\n2. 连接成功，获取当前页面信息...\n")
  Sys.sleep(2)
  
  result <- b$Runtime$evaluate("window.location.href")
  if (!is.null(result$value) && result$value != "") {
    current_url <- result$value
    cat(paste("   当前 URL:", current_url, "\n"))
  } else {
    cat("   页面未加载\n")
  }
  
  result <- b$Runtime$evaluate("document.title")
  if (!is.null(result$value) && result$value != "") {
    cat(paste("   页面标题:", result$value, "\n"))
  } else {
    cat("   页面标题未获取\n")
  }
  
  cat("\n3. 测试访问 Bing...\n")
  b$go_to("https://cn.bing.com/")
  cat("   ✓ 导航成功\n")
  Sys.sleep(3)
  
  result <- b$Runtime$evaluate("document.title")
  cat(paste("   Bing 标题:", result$value, "\n"))
  
  cat("\n4. 截图...\n")
  b$screenshot("chrome_connected_bing.png")
  cat("   ✓ 截图已保存到 chrome_connected_bing.png\n")
  
  cat("\n5. 返回管理系统...\n")
  b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
  cat("   ✓ 导航成功\n")
  Sys.sleep(5)
  
  result <- b$Runtime$evaluate("document.title")
  cat(paste("   管理系统标题:", result$value, "\n"))
  
  cat("\n6. 截图...\n")
  b$screenshot("chrome_connected_system.png")
  cat("   ✓ 截图已保存到 chrome_connected_system.png\n")
  
  cat("\n7. 查找页面关键词...\n")
  result <- b$Runtime$evaluate("
    var text = document.body ? document.body.textContent : '';
    var keywords = ['系统管理', '用户管理', '角色管理', '销售主管', '首页', '工作台'];
    var found = {};
    for (var i = 0; i < keywords.length; i++) {
      found[keywords[i]] = text.includes(keywords[i]);
    }
    found;
  ")
  found <- result$value
  for (keyword in names(found)) {
    status <- if (found[[keyword]]) "✓" else "✗"
    cat(paste("   ", status, " ", keyword, "\n", sep = ""))
  }
  
  cat("\n8. 关闭连接...\n")
  b$close()
  cat("   ✓ 连接已关闭\n")
  
  cat("\n========================================\n")
  cat("成功连接到已打开的 Chrome 浏览器\n")
  cat("========================================\n")
} else {
  cat("\n无法连接到现有 Chrome 浏览器\n")
  cat("将创建新的 Session 并登录...\n")
  
  cat("\n9. 创建新的 Session...\n")
  b <- ChromoteSession$new()
  cat("   ✓ Session 创建成功\n")
  
  cat("\n10. 导航到管理系统...\n")
  b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
  cat("   ✓ 导航成功\n")
  Sys.sleep(5)
  
  cat("\n11. 截图登录页面...\n")
  b$screenshot("login_page.png")
  cat("   ✓ 截图已保存到 login_page.png\n")
  
  cat("\n12. 查找登录表单元素...\n")
  result <- b$Runtime$evaluate("
    var inputs = document.querySelectorAll('input[type=\"text\"], input[type=\"password\"], input:not([type])');
    var inputInfo = [];
    for (var i = 0; i < Math.min(inputs.length, 10); i++) {
      var rect = inputs[i].getBoundingClientRect();
      inputInfo.push({
        tag: inputs[i].tagName,
        type: inputs[i].type || 'text',
        id: inputs[i].id || '',
        name: inputs[i].name || '',
        placeholder: inputs[i].placeholder || '',
        class: inputs[i].className || '',
        visible: rect.width > 0 && rect.height > 0
      });
    }
    inputInfo;
  ")
  inputs <- result$value
  cat(paste("   找到 ", length(inputs), " 个输入框:\n", sep = ""))
  for (i in 1:min(5, length(inputs))) {
    item <- inputs[[i]]
    cat(paste("   [", i, "] type=", item$type, " id=", item$id, " name=", item$name, 
              " placeholder=", item$placeholder, " 可见=", item$visible, "\n", sep = ""))
  }
  
  cat("\n13. 查找登录按钮...\n")
  result <- b$Runtime$evaluate("
    var buttons = document.querySelectorAll('button, input[type=\"submit\"], input[type=\"button\"]');
    var buttonInfo = [];
    for (var i = 0; i < Math.min(buttons.length, 10); i++) {
      var rect = buttons[i].getBoundingClientRect();
      buttonInfo.push({
        tag: buttons[i].tagName,
        type: buttons[i].type || 'button',
        text: buttons[i].textContent.trim().substring(0, 30),
        id: buttons[i].id || '',
        class: buttons[i].className || '',
        visible: rect.width > 0 && rect.height > 0
      });
    }
    buttonInfo;
  ")
  buttons <- result$value
  cat(paste("   找到 ", length(buttons), " 个按钮:\n", sep = ""))
  for (i in 1:min(5, length(buttons))) {
    item <- buttons[[i]]
    cat(paste("   [", i, "] ", item$tag, " text='", item$text, "' 可见=", item$visible, "\n", sep = ""))
  }
  
  cat("\n14. 关闭 Session...\n")
  b$close()
  cat("   ✓ Session 已关闭\n")
  
  cat("\n========================================\n")
  cat("已完成登录页面分析\n")
  cat("========================================\n")
}