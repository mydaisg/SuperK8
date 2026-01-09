cat("========================================\n")
cat("识别管理系统框架\n")
cat("========================================\n\n")

library(chromote)

cat("1. 创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ Session 创建成功\n")

cat("\n2. 导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 导航成功\n")
cat("  等待页面加载...\n")
Sys.sleep(3)

cat("\n3. 获取页面信息...\n")
result <- b$Runtime$evaluate("window.location.href")
if (!is.null(result$value) && result$value != "") {
  current_url <- result$value
  cat(paste("  当前 URL:", current_url, "\n"))
}

result <- b$Runtime$evaluate("document.title")
if (!is.null(result$value) && result$value != "") {
  cat(paste("  页面标题:", result$value, "\n"))
}

cat("\n4. 截图...\n")
b$screenshot("system_page.png")
cat("  ✓ 截图已保存到 system_page.png\n")

cat("\n5. 查找页面中的关键元素...\n")
result <- b$Runtime$evaluate("
  var keywords = ['系统管理', '用户管理', '角色管理', '销售主管', '登录', '账号', '验证码'];
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
  count <- found_keywords[[keyword]]
  if (count > 0) {
    cat(paste("    ✓ '", keyword, "': ", count, " 次\n", sep = ""))
  } else {
    cat(paste("    ✗ '", keyword, "': 未找到\n", sep = ""))
  }
}

cat("\n6. 查找包含'系统管理'的元素详情...\n")
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

cat(paste("  找到 ", length(system_manage_elements), " 个包含'系统管理'的元素:\n", sep = ""))
for (i in 1:min(5, length(system_manage_elements))) {
  item <- system_manage_elements[[i]]
  cat(paste("    [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, "\n", sep = ""))
}

cat("\n7. 查找包含'用户管理'和'角色管理'的元素...\n")
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

cat(paste("  找到 ", length(sub_menu_items), " 个相关元素:\n", sep = ""))
for (i in 1:min(5, length(sub_menu_items))) {
  item <- sub_menu_items[[i]]
  cat(paste("    [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, "\n", sep = ""))
}

cat("\n8. 关闭 Session...\n")
b$close()
cat("  ✓ Session 已关闭\n")

cat("\n========================================\n")
cat("识别完成\n")
cat("========================================\n")