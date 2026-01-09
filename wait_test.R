cat("========================================\n")
cat("等待特定元素测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n等待页面加载（最多30秒）...\n")
max_wait <- 30
wait_time <- 0
page_loaded <- FALSE

while (wait_time < max_wait && !page_loaded) {
  tryCatch({
    result <- b$Runtime$evaluate("document.readyState", timeout = 2000)
    if (!is.null(result$value) && result$value == "complete") {
      cat(paste("  页面就绪状态:", result$value, "\n"))
      page_loaded <- TRUE
    } else {
      cat(paste("  等待中... (", wait_time, "秒)\n", sep = ""))
      Sys.sleep(2)
      wait_time <- wait_time + 2
    }
  }, error = function(e) {
    cat(paste("  错误:", e$message, "\n"))
    Sys.sleep(2)
    wait_time <- wait_time + 2
  })
}

if (page_loaded) {
  cat("  ✓ 页面加载完成\n")
} else {
  cat("  ⚠ 超时，继续执行\n")
}

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

cat("\n截图...\n")
b$screenshot("wait_test.png")
cat("  ✓ 完成\n")

cat("\n尝试查找 Vue 应用...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.getElementById('app') !== null", timeout = 5000)
  cat(paste("  Vue 应用存在:", result$value, "\n"))
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n尝试获取 app 容器的内容...\n")
tryCatch({
  result <- b$Runtime$evaluate("document.getElementById('app').innerHTML", timeout = 5000)
  if (!is.null(result$value) && result$value != "") {
    cat(paste("  内容长度:", nchar(result$value), "\n"))
    cat(paste("  内容（前500字符）:", substr(result$value, 1, 500), "\n"))
  } else {
    cat("  内容为空\n")
  }
}, error = function(e) {
  cat("  错误:", e$message, "\n")
})

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")