library(RSQLite)
library(data.table)

GH_LIST <- function(TABLE_NAME=0, TABLE_LIMIT=0, TABLE_FIELD=0){
  # 连接数据库
  db_file <- "GH_DB_LT.db"
  con <- dbConnect(SQLite(), db_file)
  
  # 根据TABLE_NAME确定表名
  table_name <- ""
  if (TABLE_NAME == 4) {
    table_name <- "KB"
  } else {
    dbDisconnect(con)
    cat("错误: 未知的TABLE_NAME:", TABLE_NAME, "\n")
    return(NULL)
  }
  
  # 查询最近TABLE_LIMIT期数据
  query <- paste0("SELECT * FROM ", table_name, " 
                  ORDER BY ISSUE DESC 
                  LIMIT ", TABLE_LIMIT)
  
  data <- dbGetQuery(con, query)
  dbDisconnect(con)
  
  if (nrow(data) == 0) {
    cat("警告: 表", table_name, "中没有数据\n")
    return(NULL)
  }
  
  # 转换为data.table并按ISSUE升序排列
  data <- as.data.table(data)
  setorder(data, ISSUE)
  
  # 确保日期格式正确
  if ("DATES" %in% names(data)) {
    data[, DATES := as.Date(DATES)]
  }
  
  # 如果TABLE_FIELD > 0，ISSUE是必备字段（第1个），然后是KB1~KB(TABLE_FIELD-1)
  if (TABLE_FIELD > 0) {
    if (table_name == "KB") {
      # ISSUE是必备字段
      selected_cols <- c("ISSUE")
      
      # 添加KB字段（TABLE_FIELD-1个）
      num_kb_fields <- TABLE_FIELD - 1
      if (num_kb_fields > 0) {
        kb_cols <- paste0("KB", 1:min(num_kb_fields, 20))
        selected_cols <- c(selected_cols, kb_cols)
      }
      
      # 检查字段是否存在
      available_cols <- intersect(selected_cols, names(data))
      data <- data[, ..available_cols]
    }
  }
  
  return(data)
}

GH_LIST_KB <- function(TABLE_NAME=0, TABLE_LIMIT=0, TABLE_FIELD=0){
  return(GH_LIST(TABLE_NAME, TABLE_LIMIT, TABLE_FIELD))
}
