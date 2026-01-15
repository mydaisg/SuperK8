cat("========================================\n")
cat("无等待登录测试\n")
cat("========================================\n\n")

library(chromote)

cat("创建 Session...\n")
b <- ChromoteSession$new()
cat("  ✓ 完成\n")

cat("\n导航到管理系统...\n")
b$go_to("https://fac2023.lbbtech.com/?canaryflag=1#/home/index")
cat("  ✓ 完成\n")

cat("\n立即查找输入框...\n")
inputs <- b$Runtime$evaluate("document.querySelectorAll('input').length")
if (!is.null(inputs$value) && inputs$value != "") {
  cat(paste("  输入框数量:", inputs$value, "\n"))

  if (inputs$value > 0) {
    cat("\n获取输入框信息...\n")
    input_info <- b$Runtime$evaluate("
      Array.from(document.querySelectorAll('input')).map((input, index) => ({
        index: index,
        type: input.type || 'text',
        id: input.id || '',
        name: input.name || '',
        placeholder: input.placeholder || '',
        className: input.className || ''
      }))
    ")
    
    cat("  输入框列表:\n")
    for (input in input_info$value) {
      cat(paste("    [", input$index, "] 类型:", input$type, 
                ifelse(input$id != "", paste0(", ID:", input$id), ""),
                ifelse(input$name != "", paste0(", Name:", input$name), ""),
                "\n", sep = ""))
    }
  }
} else {
  cat("  无法获取输入框信息（页面未加载）\n")
}

cat("\n立即截图...\n")
b$screenshot("no_wait_login.png")
cat("  ✓ 完成\n")

cat("\n关闭 Session...\n")
b$close()
cat("  ✓ 完成\n")

cat("\n========================================\n")
cat("测试完成\n")
cat("========================================\n")