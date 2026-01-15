cat("========================================\n")
cat("登录管理系统\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("   ✓ Session 创建成功\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("   ✓ 导航成功\n")
Sys.sleep(5)

cat("\n3. 截图登录页面...\n")
b$screenshot("before_login.png")
cat("   ✓ 截图已保存\n")

cat("\n4. 查找输入框...\n")
result <- b$Runtime$evaluate("
  var inputs = document.querySelectorAll('input[type=\"text\"], input[type=\"password\"], input:not([type])');
  var inputInfo = [];
  for (var i = 0; i < inputs.length; i++) {
    var rect = inputs[i].getBoundingClientRect();
    if (rect.width > 0 && rect.height > 0) {
      inputInfo.push({
        tag: inputs[i].tagName,
        type: inputs[i].type || 'text',
        id: inputs[i].id || '',
        name: inputs[i].name || '',
        placeholder: inputs[i].placeholder || '',
        class: inputs[i].className || '',
        index: i
      });
    }
  }
  inputInfo;
")
inputs <- result$value
cat(paste("   找到 ", length(inputs), " 个可见输入框:\n", sep = ""))
for (i in 1:min(5, length(inputs))) {
  item <- inputs[[i]]
  cat(paste("   [", i, "] type=", item$type, " id=", item$id, " name=", item$name, 
            " placeholder=", item$placeholder, "\n", sep = ""))
}

if (length(inputs) >= 2) {
  cat("\n5. 输入用户名...\n")
  username_input <- inputs[[1]]
  if (username_input$id != "") {
    b$Runtime$evaluate(paste0("document.getElementById('", username_input$id, "').value = 'admin'"))
  } else if (username_input$name != "") {
    b$Runtime$evaluate(paste0("document.getElementsByName('", username_input$name, "')[0].value = 'admin'"))
  } else {
    b$Runtime$evaluate(paste0("document.querySelectorAll('input')[", username_input$index, "].value = 'admin'"))
  }
  cat("   ✓ 用户名已输入\n")
  
  cat("\n6. 输入密码...\n")
  password_input <- inputs[[2]]
  if (password_input$id != "") {
    b$Runtime$evaluate(paste0("document.getElementById('", password_input$id, "').value = 'Lvcc@012345'"))
  } else if (password_input$name != "") {
    b$Runtime$evaluate(paste0("document.getElementsByName('", password_input$name, "')[0].value = 'Lvcc@012345'"))
  } else {
    b$Runtime$evaluate(paste0("document.querySelectorAll('input')[", password_input$index, "].value = 'Lvcc@012345'"))
  }
  cat("   ✓ 密码已输入\n")
  
  cat("\n7. 查找登录按钮...\n")
  result <- b$Runtime$evaluate("
    var buttons = document.querySelectorAll('button, input[type=\"submit\"], input[type=\"button\"]');
    var buttonInfo = [];
    for (var i = 0; i < buttons.length; i++) {
      var rect = buttons[i].getBoundingClientRect();
      if (rect.width > 0 && rect.height > 0) {
        buttonInfo.push({
          tag: buttons[i].tagName,
          type: buttons[i].type || 'button',
          text: buttons[i].textContent.trim(),
          id: buttons[i].id || '',
          class: buttons[i].className || '',
          index: i
        });
      }
    }
    buttonInfo;
  ")
  buttons <- result$value
  cat(paste("   找到 ", length(buttons), " 个可见按钮:\n", sep = ""))
  for (i in 1:min(5, length(buttons))) {
    item <- buttons[[i]]
    cat(paste("   [", i, "] ", item$tag, " text='", item$text, "'\n", sep = ""))
  }
  
  if (length(buttons) > 0) {
    cat("\n8. 点击登录按钮...\n")
    login_button <- buttons[[1]]
    if (login_button$id != "") {
      b$Runtime$evaluate(paste0("document.getElementById('", login_button$id, "').click()"))
    } else {
      b$Runtime$evaluate(paste0("document.querySelectorAll('button')[", login_button$index, "].click()"))
    }
    cat("   ✓ 登录按钮已点击\n")
    
    cat("\n9. 等待登录完成...\n")
    Sys.sleep(10)
    
    cat("\n10. 截图登录后页面...\n")
    b$screenshot("after_login.png")
    cat("   ✓ 截图已保存\n")
    
    cat("\n11. 检查登录状态...\n")
    result <- b$Runtime$evaluate("window.location.href")
    current_url <- result$value
    cat(paste("   当前 URL:", current_url, "\n"))
    
    result <- b$Runtime$evaluate("document.title")
    cat(paste("   页面标题:", result$value, "\n"))
    
    cat("\n12. 查找页面关键词...\n")
    result <- b$Runtime$evaluate("
      var text = document.body ? document.body.textContent : '';
      var keywords = ['系统管理', '用户管理', '角色管理', '销售主管', '首页', '工作台', '退出'];
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
  } else {
    cat("   ✗ 未找到登录按钮\n")
  }
} else {
  cat("   ✗ 输入框数量不足\n")
}

cat("\n13. 关闭 Session...\n")
b$close()
cat("   ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("登录流程完成\n")
cat("========================================\n")