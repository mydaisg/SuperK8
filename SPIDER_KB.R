library(rvest)
library(stringr)
library(RSQLite)

REQUEST_DELAY <- 2
MAX_CONSECUTIVE_FAILURES <- 10
MAX_RETRY_ATTEMPTS <- 3

SPIDER_KB_GetMaxIssueForYear <- function(year){
  if (year >= 2023) {
    return(351)
  } else if (year == 2022) {
    return(350)
  } else if (year == 2021) {
    return(351)
  } else if (year == 2020) {
    return(65)
  } else {
    return(351)
  }
}

SPIDER_KB_Current <- function(){
  cat("========================================\n")
  cat("爬取当前最新K8数据\n")
  cat("========================================\n\n")
  
  K8_Current_URL <- "https://kaijiang.500.com/kl8.shtml"
  cat(paste("正在访问:", K8_Current_URL, "\n"))
  
  K8_HisContent <- read_html(K8_Current_URL) %>% html_text()
  
  K8_Pattern <-"(?s)第(.*?)(?=提示|$)"
  K8_Matched <- str_match(K8_HisContent, K8_Pattern)[1,1]
  
  K8_T <- K8_Matched %>% 
    str_replace_all("\\\\n", "") %>%
    str_replace_all("(?s)\\.ball.*?\\}", "") %>%
    str_replace_all("\\\\t", " ") %>%
    str_squish()
  
  K8_I <- str_match_all(K8_T, "第\\s*(\\d+)\\s*期")
  K8_D <- str_match_all(K8_T, "开奖日期：(\\d{4}年\\d{1,2}月\\d{1,2}日)")
  K8_N <- str_match_all(K8_T, "开奖号码：\\s*((?:\\d{2}\\s+){19}\\d{2})")
  K8_S <- str_match_all(K8_T, "本期销量：(\\d{1,3}(?:,\\d{3})*元)")
  K8_P <- str_match_all(K8_T, "奖池金额：(\\d{1,3}(?:,\\d{3})*元)")
  
  K8_Matched <- list(
    KB_ISSUE = K8_I[[1]][,2],
    KB_DATE = as.Date(gsub("年|月|日", "-", K8_D[[1]][,2]), format="%Y-%m-%d"),
    KB_Number = str_split(K8_N[[1]][,2], "\\s+"),
    KB_SALES = as.numeric(gsub("[,元]", "", K8_S[[1]][,2])),
    KB_POOL = as.numeric(gsub("[,元]", "", K8_P[[1]][,2]))
  )
  
  cat(paste("期号:", K8_Matched$KB_ISSUE, "\n"))
  cat(paste("日期:", K8_Matched$KB_DATE, "\n"))
  cat(paste("销量:", K8_Matched$KB_SALES, "\n"))
  cat(paste("奖池:", K8_Matched$KB_POOL, "\n"))
  
  return(K8_Matched)
}

SPIDER_KB_Issue <- function(KB_ISSUE){
  cat(paste("正在爬取期号:", KB_ISSUE, "\n"))
  
  KB_His_URL <- paste0("https://kaijiang.500.com/shtml/kl8/", KB_ISSUE, ".shtml")
  
  tryCatch({
    KB_HisContent <- read_html(KB_His_URL, encoding = "GB18030") %>% html_text()
    
    KB_Pattern <-"(?s)第(.*?)(?=提示|$)"
    KB_Matched <- str_match(KB_HisContent, KB_Pattern)[1,1]
    
    if (is.na(KB_Matched)) {
      cat(paste("期号", KB_ISSUE, "未找到数据\n"))
      return(NULL)
    }
    
    KB_T <- KB_Matched %>% 
      str_replace_all("\\\\n", "") %>%
      str_replace_all("(?s)\\.ball.*?\\}", "") %>%
      str_replace_all("\\\\t", " ") %>%
      str_squish()
    
    KB_I <- str_match_all(KB_T, "第\\s*(\\d+)\\s*期")
    KB_D <- str_match_all(KB_T, "开奖日期：(\\d{4}年\\d{1,2}月\\d{1,2}日)")
    KB_N <- str_match_all(KB_T, "开奖号码：\\s*((?:\\d{2}\\s+){19}\\d{2})")
    KB_S <- str_match_all(KB_T, "本期销量：(\\d{1,3}(?:,\\d{3})*元)")
    KB_P <- str_match_all(KB_T, "奖池金额：(\\d{1,3}(?:,\\d{3})*元)")
    
    if (length(KB_I[[1]]) == 0 || length(KB_D[[1]]) == 0 || length(KB_N[[1]]) == 0 || 
        is.na(KB_I[[1]][,2]) || is.na(KB_D[[1]][,2]) || is.na(KB_N[[1]][,2])) {
      cat(paste("期号", KB_ISSUE, "数据不完整\n"))
      return(NULL)
    }
    
    KB_Matched <- list(
      KB_ISSUE = KB_I[[1]][,2],
      KB_DATE = as.Date(gsub("年|月|日", "-", KB_D[[1]][,2]), format="%Y-%m-%d"),
      KB_Number = str_split(KB_N[[1]][,2], "\\s+"),
      KB_SALES = as.numeric(gsub("[,元]", "", KB_S[[1]][,2])),
      KB_POOL = as.numeric(gsub("[,元]", "", KB_P[[1]][,2]))
    )
    
    return(KB_Matched)
    
  }, error = function(e) {
    cat(paste("爬取期号", KB_ISSUE, "失败:", e$message, "\n"))
    return(NULL)
  })
}

SPIDER_KB_Insert <- function(KB_DATA){
  db_file <- "GH_DB_LT.db"
  con <- dbConnect(SQLite(), db_file)
  
  KB_Number <- KB_DATA$KB_Number[[1]]
  KB_DATE <- paste0('"', KB_DATA$KB_DATE, '"')
  
  KB_VALUES <- paste(KB_DATA$KB_ISSUE, 
                     paste(KB_Number, collapse = ","),
                     KB_DATA$KB_SALES,
                     KB_DATA$KB_POOL, 
                     KB_DATE, 
                     sep = ",")
  
  insert_sql <- paste0("INSERT OR IGNORE INTO KB (ISSUE,KB1,KB2,KB3,KB4,KB5,KB6,KB7,KB8,KB9,KB10,KB11,KB12,KB13,KB14,KB15,KB16,KB17,KB18,KB19,KB20,SALES,POOL,DATES) VALUES (", KB_VALUES, ")")
  
  result <- dbExecute(con, insert_sql)
  
  if (result > 0) {
    cat(paste("✓ 期号", KB_DATA$KB_ISSUE, "插入成功\n"))
  } else {
    cat(paste("- 期号", KB_DATA$KB_ISSUE, "已存在，跳过\n"))
  }
  
  dbDisconnect(con)
  
  return(result)
}

SPIDER_KB_GetExistingIssues <- function(){
  db_file <- "GH_DB_LT.db"
  con <- dbConnect(SQLite(), db_file)
  
  query <- "SELECT ISSUE FROM KB ORDER BY ISSUE"
  existing_issues <- dbGetQuery(con, query)$ISSUE
  
  dbDisconnect(con)
  
  return(existing_issues)
}

SPIDER_KB_Loop <- function(years = 5){
  cat("========================================\n")
  cat(paste("开始循环爬取", years, "年数据\n"))
  cat("========================================\n\n")
  
  current_data <- SPIDER_KB_Current()
  current_issue <- as.numeric(current_data$KB_ISSUE)
  current_year <- as.numeric(substr(current_issue, 1, 4))
  current_issue_in_year <- as.numeric(substr(current_issue, 5, 7))
  
  cat(paste("当前期号:", current_issue, "\n"))
  cat(paste("当前年份:", current_year, "\n"))
  cat(paste("当年期号:", current_issue_in_year, "\n\n"))
  
  existing_issues <- SPIDER_KB_GetExistingIssues()
  cat(paste("数据库中已有期号:", length(existing_issues), "期\n\n"))
  
  success_count <- 0
  skip_count <- 0
  fail_count <- 0
  
  failed_issues <- list()
  consecutive_failures <- 0
  retry_mode <- FALSE
  
  log_file <- paste0("spider_failed_log_", format(Sys.time(), "%Y%m%d_%H%M%S"), ".txt")
  
  for (year_offset in 0:(years-1)) {
    target_year <- current_year - year_offset
    
    cat(paste("========================================\n"))
    cat(paste("正在处理", target_year, "年数据\n"))
    cat(paste("========================================\n\n"))
    
    max_issue_for_year <- SPIDER_KB_GetMaxIssueForYear(target_year)
    
    if (year_offset == 0) {
      start_issue_num <- current_issue_in_year
    } else {
      start_issue_num <- max_issue_for_year
    }
    
    end_issue_num <- 1
    
    cat(paste("期号范围:", target_year, sprintf("%03d", start_issue_num), "至", target_year, sprintf("%03d", end_issue_num), "\n"))
    
    for (issue_num in start_issue_num:end_issue_num) {
      issue <- target_year * 1000 + issue_num
      
      if (issue %in% existing_issues) {
        skip_count <- skip_count + 1
        cat(paste("期号:", issue, "已存在，跳过\n"))
        next
      }
      
      cat(paste("正在处理期号:", issue, "\n"))
      
      kb_data <- SPIDER_KB_Issue(issue)
      
      if (!is.null(kb_data)) {
        result <- SPIDER_KB_Insert(kb_data)
        if (result > 0) {
          success_count <- success_count + 1
          consecutive_failures <- 0
          existing_issues <- c(existing_issues, issue)
        } else {
          skip_count <- skip_count + 1
        }
      } else {
        fail_count <- fail_count + 1
        consecutive_failures <- consecutive_failures + 1
        
        if (!is.null(failed_issues[[as.character(issue)]])) {
          failed_issues[[as.character(issue)]] <- failed_issues[[as.character(issue)]] + 1
        } else {
          failed_issues[[as.character(issue)]] <- 1
        }
        
        cat(paste("  连续失败:", consecutive_failures, "次\n"))
        
        if (consecutive_failures >= MAX_CONSECUTIVE_FAILURES && !retry_mode) {
          cat(paste("\n!!! 连续失败", MAX_CONSECUTIVE_FAILURES, "次，切换到重试模式\n\n"))
          retry_mode <- TRUE
          break
        }
      }
      
      Sys.sleep(REQUEST_DELAY)
    }
    
    if (retry_mode) {
      break
    }
    
    cat(paste("\n✓", target_year, "年处理完成\n\n"))
  }
  
  if (length(failed_issues) > 0) {
    cat("\n========================================\n")
    cat("开始重试失败的期号\n")
    cat("========================================\n\n")
    
    retry_issues <- names(failed_issues)
    
    for (issue_str in retry_issues) {
      issue <- as.numeric(issue_str)
      attempts <- failed_issues[[issue_str]]
      
      if (attempts >= MAX_RETRY_ATTEMPTS) {
        cat(paste("期号", issue, "已失败", attempts, "次，跳过重试\n"))
        next
      }
      
      cat(paste("重试期号:", issue, "(第", attempts + 1, "次)\n"))
      
      kb_data <- SPIDER_KB_Issue(issue)
      
      if (!is.null(kb_data)) {
        result <- SPIDER_KB_Insert(kb_data)
        if (result > 0) {
          success_count <- success_count + 1
          fail_count <- fail_count - 1
          failed_issues[[issue_str]] <- NULL
          cat(paste("✓ 期号", issue, "重试成功\n"))
        } else {
          skip_count <- skip_count + 1
        }
      } else {
        failed_issues[[issue_str]] <- failed_issues[[issue_str]] + 1
        cat(paste("✗ 期号", issue, "重试失败，累计失败", failed_issues[[issue_str]], "次\n"))
      }
      
      Sys.sleep(REQUEST_DELAY)
    }
  }
  
  if (length(failed_issues) > 0) {
    cat("\n========================================\n")
    cat("记录失败日志\n")
    cat("========================================\n\n")
    
    log_content <- paste0("爬虫失败日志 - ", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "\n")
    log_content <- paste0(log_content, paste(rep("=", 50), collapse = ""), "\n\n")
    
    for (issue_str in names(failed_issues)) {
      issue <- as.numeric(issue_str)
      attempts <- failed_issues[[issue_str]]
      log_content <- paste0(log_content, "期号: ", issue, " | 失败次数: ", attempts, "\n")
    }
    
    writeLines(log_content, log_file)
    cat(paste("失败日志已保存到:", log_file, "\n"))
  }
  
  cat("\n========================================\n")
  cat("爬取完成统计:\n")
  cat(paste("  成功插入:", success_count, "期\n"))
  cat(paste("  跳过已存在:", skip_count, "期\n"))
  cat(paste("  失败:", fail_count, "期\n"))
  if (length(failed_issues) > 0) {
    cat(paste("  未成功重试:", length(failed_issues), "期\n"))
  }
  cat("========================================\n")
  
  return(list(
    success = success_count,
    skip = skip_count,
    fail = fail_count,
    failed_issues = failed_issues
  ))
}
