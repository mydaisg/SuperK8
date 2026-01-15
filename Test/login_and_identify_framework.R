cat("========================================\n")
cat("登录管理系统并识别框架\n")
cat("========================================\n\n")

library(chromote)

username <- "admin"
password <- "Lvcc@012345"

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("   ✓ Session 创建成功\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("   ✓ 导航成功\n")
Sys.sleep(8)

cat("\n3. 截图登录页面...\n")
b$screenshot("login_page_final.png")
cat("   ✓ 截图已保存\n")

cat("\n4. 查找所有输入框...\n")
result <- b$Runtime$evaluate("
  var allInputs = document.querySelectorAll('input');
  var inputInfo = [];
  for (var i = 0; i < allInputs.length; i++) {
    var rect = allInputs[i].getBoundingClientRect();
    inputInfo.push({
      tag: allInputs[i].tagName,
      type: allInputs[i].type || 'text',
      id: allInputs[i].id || '',
      name: allInputs[i].name || '',
      placeholder: allInputs[i].placeholder || '',
      class: allInputs[i].className || '',
      visible: rect.width > 0 && rect.height > 0,
      index: i
    });
  }
  inputInfo;
")
inputs <- result$value
cat(paste("   找到 ", length(inputs), " 个输入框\n", sep = ""))

visible_inputs <- inputs[sapply(inputs, function(x) x$visible)]
cat(paste("   其中 ", length(visible_inputs), " 个可见\n", sep = ""))

if (length(visible_inputs) >= 2) {
  cat("\n5. 输入用户名...\n")
  username_input <- visible_inputs[[1]]
  cat(paste("   使用输入框: type=", username_input$type, 
            " id=", username_input$id, 
            " name=", username_input$name, 
            " placeholder=", username_input$placeholder, "\n", sep = ""))
  
  if (username_input$id != "") {
    b$Runtime$evaluate(paste0("document.getElementById('", username_input$id, "').value = '", username, "'"))
  } else if (username_input$name != "") {
    b$Runtime$evaluate(paste0("document.getElementsByName('", username_input$name, "')[0].value = '", username, "'"))
  } else {
    b$Runtime$evaluate(paste0("document.querySelectorAll('input')[", username_input$index, "].value = '", username, "'"))
  }
  cat("   ✓ 用户名已输入\n")
  Sys.sleep(1)
  
  cat("\n6. 输入密码...\n")
  password_input <- visible_inputs[[2]]
  cat(paste("   使用输入框: type=", password_input$type, 
            " id=", password_input$id, 
            " name=", password_input$name, 
            " placeholder=", password_input$placeholder, "\n", sep = ""))
  
  if (password_input$id != "") {
    b$Runtime$evaluate(paste0("document.getElementById('", password_input$id, "').value = '", password, "'"))
  } else if (password_input$name != "") {
    b$Runtime$evaluate(paste0("document.getElementsByName('", password_input$name, "')[0].value = '", password, "'"))
  } else {
    b$Runtime$evaluate(paste0("document.querySelectorAll('input')[", password_input$index, "].value = '", password, "'"))
  }
  cat("   ✓ 密码已输入\n")
  Sys.sleep(1)
  
  cat("\n7. 查找登录按钮...\n")
  result <- b$Runtime$evaluate("
    var allButtons = document.querySelectorAll('button, input[type=\"submit\"], input[type=\"button\"], a');
    var buttonInfo = [];
    for (var i = 0; i < allButtons.length; i++) {
      var rect = allButtons[i].getBoundingClientRect();
      var text = allButtons[i].textContent || allButtons[i].value || '';
      if (rect.width > 0 && rect.height > 0) {
        buttonInfo.push({
          tag: allButtons[i].tagName,
          type: allButtons[i].type || '',
          text: text.trim().substring(0, 50),
          id: allButtons[i].id || '',
          class: allButtons[i].className || '',
          visible: rect.width > 0 && rect.height > 0,
          index: i
        });
      }
    }
    buttonInfo;
  ")
  buttons <- result$value
  cat(paste("   找到 ", length(buttons), " 个可见按钮/链接\n", sep = ""))
  
  login_button <- NULL
  for (i in 1:length(buttons)) {
    btn <- buttons[[i]]
    if (grepl("登录|login|submit|确定|确认", btn$text, ignore.case = TRUE)) {
      login_button <- btn
      cat(paste("   找到登录按钮: ", btn$tag, " text='", btn$text, "'\n", sep = ""))
      break
    }
  }
  
  if (!is.null(login_button)) {
    cat("\n8. 点击登录按钮...\n")
    if (login_button$id != "") {
      b$Runtime$evaluate(paste0("document.getElementById('", login_button$id, "').click()"))
    } else {
      b$Runtime$evaluate(paste0("document.querySelectorAll('", tolower(login_button$tag), "')[" , login_button$index, "].click()"))
    }
    cat("   ✓ 登录按钮已点击\n")
    
    cat("\n9. 等待登录完成 (15秒)...\n")
    Sys.sleep(15)
    
    cat("\n10. 截图登录后页面...\n")
    b$screenshot("after_login_final.png")
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
      var keywords = ['系统管理', '用户管理', '角色管理', '销售主管', '首页', '工作台', '退出', '登录', '账号', '验证码'];
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
    
    if (found$`系统管理` || found$`用户管理` || found$`角色管理`) {
      cat("\n13. 登录成功！查找导航元素...\n")
      
      cat("\n13.1 查找'系统管理'元素...\n")
      result <- b$Runtime$evaluate("
        var systemManageElements = [];
        var allElements = document.querySelectorAll('*');
        for (var i = 0; i < allElements.length; i++) {
          var text = allElements[i].textContent || '';
          if (text.includes('系统管理')) {
            var rect = allElements[i].getBoundingClientRect();
            systemManageElements.push({
              tag: allElements[i].tagName,
              text: text.trim().substring(0, 50),
              id: allElements[i].id || '',
              class: allElements[i].className || '',
              visible: rect.width > 0 && rect.height > 0
            });
          }
        }
        systemManageElements.slice(0, 10);
      ")
      system_manage_elements <- result$value
      cat(paste("   找到 ", length(system_manage_elements), " 个包含'系统管理'的元素\n", sep = ""))
      for (i in 1:min(5, length(system_manage_elements))) {
        item <- system_manage_elements[[i]]
        cat(paste("   [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, "\n", sep = ""))
      }
      
      cat("\n13.2 查找'用户管理'和'角色管理'元素...\n")
      result <- b$Runtime$evaluate("
        var subMenuItems = [];
        var allElements = document.querySelectorAll('*');
        for (var i = 0; i < allElements.length; i++) {
          var text = allElements[i].textContent || '';
          if (text.includes('用户管理') || text.includes('角色管理')) {
            var rect = allElements[i].getBoundingClientRect();
            subMenuItems.push({
              tag: allElements[i].tagName,
              text: text.trim().substring(0, 50),
              id: allElements[i].id || '',
              class: allElements[i].className || '',
              visible: rect.width > 0 && rect.height > 0
            });
          }
        }
        subMenuItems.slice(0, 10);
      ")
      sub_menu_items <- result$value
      cat(paste("   找到 ", length(sub_menu_items), " 个相关元素\n", sep = ""))
      for (i in 1:min(5, length(sub_menu_items))) {
        item <- sub_menu_items[[i]]
        cat(paste("   [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, "\n", sep = ""))
      }
      
      cat("\n14. 截图完整页面...\n")
      b$screenshot("system_framework_final.png")
      cat("   ✓ 截图已保存到 system_framework_final.png\n")
      
      cat("\n========================================\n")
      cat("✓ 登录成功并识别到系统管理框架\n")
      cat("========================================\n")
    } else if (found$`登录`) {
      cat("\n========================================\n")
      cat("✗ 登录失败，仍在登录页面\n")
      cat("========================================\n")
    } else {
      cat("\n========================================\n")
      cat("? 登录状态不明\n")
      cat("========================================\n")
    }
  } else {
    cat("   ✗ 未找到登录按钮\n")
  }
} else {
  cat("   ✗ 输入框数量不足，无法登录\n")
}

cat("\n15. 关闭 Session...\n")
b$close()
cat("   ✓ Session 已关闭\n")