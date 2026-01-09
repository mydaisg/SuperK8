cat("========================================\n")
cat("识别管理系统框架\n")
cat("========================================\n\n")

library(chromote)

cat("1. 连接到已打开的 Chrome 浏览器...\n")
b <- NULL
tryCatch({
  b <- Chrome$new(port = 9222)
  cat("  ✓ 连接成功\n")
}, error = function(e) {
  cat("  ✗ 连接失败，尝试创建新的 Session\n")
})

if (is.null(b)) {
  b <- ChromoteSession$new()
  cat("  ✓ 新 Session 创建成功\n")
}

cat("\n2. 确认当前页面...\n")
Sys.sleep(3)
result <- b$Runtime$evaluate("window.location.href")
if (is.null(result$value) || length(result$value) == 0 || result$value == "") {
  cat("  页面未加载，正在导航到管理系统...\n")
  b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
  cat("  ✓ 导航成功\n")
  cat("  等待页面加载...\n")
  Sys.sleep(10)
  result <- b$Runtime$evaluate("window.location.href")
}
current_url <- result$value
cat(paste("  当前 URL:", current_url, "\n"))

if (!is.null(current_url) && !grepl("fac2023.lbbtech.com", current_url)) {
  cat("  当前页面不是管理系统，正在导航...\n")
  b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
  cat("  ✓ 导航成功\n")
  cat("  等待页面加载...\n")
  Sys.sleep(10)
}

cat("\n3. 识别页面整体框架...\n")
result <- b$Runtime$evaluate("document.title")
cat(paste("  页面标题:", result$value, "\n"))

cat("\n4. 查找导航栏元素...\n")
result <- b$Runtime$evaluate("
  var navItems = [];
  var allElements = document.querySelectorAll('*');
  for (var i = 0; i < allElements.length; i++) {
    var text = allElements[i].textContent || '';
    if (text.includes('系统管理') || text.includes('用户管理') || text.includes('角色管理')) {
      navItems.push({
        tag: allElements[i].tagName,
        text: text.trim().substring(0, 50),
        id: allElements[i].id,
        class: allElements[i].className
      });
    }
  }
  navItems.slice(0, 20);
")
nav_items <- result$value
cat(paste("  找到", length(nav_items), "个相关元素\n"))

for (i in 1:min(10, length(nav_items))) {
  item <- nav_items[[i]]
  cat(paste("  [", i, "] ", item$tag, " - ", item$text, "\n", sep = ""))
}

cat("\n5. 查找包含'系统管理'的可点击元素...\n")
result <- b$Runtime$evaluate("
  var systemManageElements = [];
  var allElements = document.querySelectorAll('*');
  for (var i = 0; i < allElements.length; i++) {
    var text = allElements[i].textContent || '';
    if (text.trim() === '系统管理' || text.includes('系统管理')) {
      var rect = allElements[i].getBoundingClientRect();
      systemManageElements.push({
        tag: allElements[i].tagName,
        text: text.trim(),
        id: allElements[i].id,
        class: allElements[i].className,
        visible: rect.width > 0 && rect.height > 0,
        clickable: allElements[i].tagName === 'A' || 
                   allElements[i].tagName === 'BUTTON' || 
                   allElements[i].onclick !== null ||
                   window.getComputedStyle(allElements[i]).cursor === 'pointer'
      });
    }
  }
  systemManageElements;
")
system_manage_elements <- result$value
cat(paste("  找到", length(system_manage_elements), "个包含'系统管理'的元素\n"))

for (i in 1:min(5, length(system_manage_elements))) {
  item <- system_manage_elements[[i]]
  cat(paste("  [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, " - 可点击:", item$clickable, "\n", sep = ""))
}

cat("\n6. 尝试点击'系统管理'...\n")
if (length(system_manage_elements) > 0) {
  for (i in 1:length(system_manage_elements)) {
    item <- system_manage_elements[[i]]
    if (item$visible && item$clickable) {
      cat(paste("  尝试点击第", i, "个元素...\n"))
      
      result <- b$Runtime$evaluate(paste0("
        var elements = document.querySelectorAll('*');
        for (var j = 0; j < elements.length; j++) {
          if (elements[j].textContent.trim() === '", item$text, "' || elements[j].textContent.includes('系统管理')) {
            elements[j].click();
            return 'clicked';
          }
        }
        return 'not found';
      "))
      
      cat(paste("  ", result$value, "\n"))
      Sys.sleep(3)
      break
    }
  }
} else {
  cat("  ✗ 未找到可点击的'系统管理'元素\n")
}

cat("\n7. 等待页面更新...\n")
Sys.sleep(5)

cat("\n8. 查找'用户管理'和'角色管理'...\n")
result <- b$Runtime$evaluate("
  var subMenuItems = [];
  var allElements = document.querySelectorAll('*');
  for (var i = 0; i < allElements.length; i++) {
    var text = allElements[i].textContent || '';
    if (text.includes('用户管理') || text.includes('角色管理')) {
      var rect = allElements[i].getBoundingClientRect();
      subMenuItems.push({
        tag: allElements[i].tagName,
        text: text.trim(),
        id: allElements[i].id,
        class: allElements[i].className,
        visible: rect.width > 0 && rect.height > 0
      });
    }
  }
  subMenuItems;
")
sub_menu_items <- result$value
cat(paste("  找到", length(sub_menu_items), "个相关元素\n"))

for (i in 1:min(10, length(sub_menu_items))) {
  item <- sub_menu_items[[i]]
  cat(paste("  [", i, "] ", item$tag, " - '", item$text, "' - 可见:", item$visible, "\n", sep = ""))
}

cat("\n9. 截图保存...\n")
b$screenshot("system_framework.png")
cat("  ✓ 截图已保存到 system_framework.png\n")

cat("\n10. 关闭连接...\n")
b$close()
cat("  ✓ 连接已关闭\n")

cat("\n========================================\n")
cat("识别完成\n")
cat("========================================\n")