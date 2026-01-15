download_sqlite <- function() {
  cat("正在下载SQLite工具...\n")
  
  download.file(
    url = "https://sqlite.org/2024/sqlite-tools-win-x64-3450300.zip",
    destfile = "sqlite-tools.zip",
    mode = "wb",
    quiet = FALSE
  )
  
  cat("正在解压...\n")
  unzip("sqlite-tools.zip", exdir = "sqlite-tools", overwrite = TRUE)
  
  cat("正在复制sqlite3.exe到R目录...\n")
  file.copy(
    from = "sqlite-tools/sqlite-tools-win-x64-3450300/sqlite3.exe",
    to = "D:/Program Files/R/R-4.5.2/bin/sqlite3.exe",
    overwrite = TRUE
  )
  
  cat("✓ SQLite3安装完成！\n")
}

download_sqlite()
