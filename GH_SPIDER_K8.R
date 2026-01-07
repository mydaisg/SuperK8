# @author: my@daisg.com
# @date: 2025-11-09
# @version: 2.1
# Copyright (c) 2025 DaiSG
# SPDX-License-Identifier: GPL-3
# @brief/ Description
# 库函数，爬取K8的开奖数据，并更新至LIST_K8文件和数据库（包括手工更新）

SPIDER_K8 <- function(){
  library(rvest)
  library(stringr)
  
  # Begin URL by SPIDER and Read Html
  K8_Current_URL <- "https://kaijiang.500.com/kl8.shtml"
  K8_HisContent <- read_html(K8_Current_URL) %>% html_text()
  
  # print(K8_HisContent)
  # K8_Pattern <- "(?s)\\\\n25(.*?)\\\\n25"
  # K8_Pattern <-"(?s)(?:^|\\n)25(.*?)\\n25"
  # K8_Pattern <-"(?s)\n25(.*?)\n25"
  K8_Pattern <-"(?s)第(.*?)(?=提示|$)"
  K8_Matched <- str_match(K8_HisContent,K8_Pattern)[1,1]
  # print(K8_Matched)
  K8_T <- K8_Matched %>% 
    str_replace_all("\\\\n", "") %>%  # 移除 \n
    str_replace_all("(?s)\\.ball.*?\\}", "") %>%
    str_replace_all("\\\\t", " ") %>%  # 替换 \t 为空格
    str_squish()    # 自动合并连续空格 + 清除首尾空格
  
  # cat(K8_Current)
  # 正则表达式提取关键字段
  K8_I <- str_match_all(K8_T, "第\\s*(\\d+)\\s*期")
  K8_D <- str_match_all(K8_T,"开奖日期：(\\d{4}年\\d{1,2}月\\d{1,2}日)")
  K8_N <- str_match_all(K8_T,"开奖号码：\\s*((?:\\d{2}\\s+){19}\\d{2})")
  K8_S <- str_match_all(K8_T,"本期销量：(\\d{1,3}(?:,\\d{3})*元)")
  K8_P <- str_match_all(K8_T,"奖池金额：(\\d{1,3}(?:,\\d{3})*元)")
  
  # str(K8_N[[1]][,2])
  # K8_Number <- str_split(K8_N[[1]][,2], "\\s+")
  # K8_Number[[1]][5]
  # 构建结构化列表
  K8_Matched <- list(
    K8_ISSUE = K8_I[[1]][,2],
    K8_DATE = K8_D[[1]][,2],
    K8_Number = str_split(K8_N[[1]][,2], "\\s+"),
    K8_SALES = as.numeric(gsub("[,元]", "", K8_S[[1]][,2])),
    K8_POOL = as.numeric(gsub("[,元]", "", K8_P[[1]][,2]))
  )
  
  # 更新LIST_K8文本的数据
  # K8_Matched$K8_Number[[1]][5]
  Weekday_Chinese <- c( "一", "二", "三", "四", "五", "六","日")
  K8_DATE <- as.Date(gsub("年|月|日", "-", K8_D[[1]][,2]), format="%Y-%m-%d")
  # K8_DATE <- as.Date("2025-08-06")
  Weekday_Num <- as.numeric(format(K8_DATE, "%u"))
  K8_DATEs <- paste0(K8_DATE, "（", Weekday_Chinese[Weekday_Num], "）")
  K8_Number <- paste(unlist(K8_Matched$K8_Number), collapse = "")
  K8_Current <- paste(K8_Matched$K8_ISSUE,K8_DATEs,
                      K8_Number,K8_Matched$K8_SALES,sep = "\t")
  # 格式 2025239	2025-09-06（六）	0203101215212227343537384951556566707176	112096602
  # 来源：https://www.zhcw.com/kjxx/kl8/
  # K8_Test <- "2025240	2025-09-07（日）	0809111215273536434549505161646568727879	111294528"
  # cat(K8_Test)
  # cat(K8_Current)
  # 写入/opt/MyR/K8/LIST_K8
  file_path <- "/opt/MyR/K8/LIST_K8"
    existing_content <- readLines(file_path)
    all_content <- c(K8_Current,existing_content)
    writeLines(all_content, file_path)
    
  # insert K8 提取期号，并采用期号索引去爬取页面，并把结果插入数据库
    SPIDER_KB_Manual(K8_Matched$K8_ISSUE)
  # List news data
}


SPIDER_KB_Insert <- function(KB_DATA){
  library(RSQLite)
  DataBaseDirectory <- "/opt/MyR/SQLite/GH_DB_LT.db"
  UI_TABLE_NAME <- "KB"
  CONN<-dbConnect(SQLite(),DataBaseDirectory)
  
  UI_ACTION_INSERT <- "INSERT INTO"
  UI_INSERT_FIELD <- "(ISSUE,KB1,KB2,KB3,KB4,KB5,KB6,KB7,KB8,KB9,KB10,KB11,KB12,KB13,KB14,KB15,KB16,KB17,KB18,KB19,KB20,SALES,POOL,DATES) VALUES"
                       
  UI_INSERT_DATA <- paste0('(',KB_DATA, ')')
  # UI_INSERT_DATA <- "(2025239,02,03,10,12,15,21,22,27,34,35,37,38,49,51,55,65,66,70,71,76,112096602,63859636,"2025-09-06")"
  ISSUE_INSERT_SQL <- paste(UI_ACTION_INSERT,UI_TABLE_NAME
                            ,UI_INSERT_FIELD,UI_INSERT_DATA,sep = " ")
  cat(KB_DATA)
  dbExecute(CONN,ISSUE_INSERT_SQL)
  color_text <- function(text) {
    paste0("\033[32m", text, "\033[0m")
  }
  # cat("\n",color_text("Insert new K8 Sucessful!"),"\n\n")
  cat("\n",UI_TABLE_NAME,KB_DATA,color_text("Insert new K8 Sucessful!"),"\n\n")
  dbDisconnect(CONN)
}

SPIDER_KB_Manual <- function(KB_ISSUE){
  library(rvest)
  library(stringr)
  KB_His_Issue <- KB_ISSUE
  KB_His_URL <- paste0("https://kaijiang.500.com/shtml/kl8/"
                      , KB_His_Issue, ".shtml")
  # KB_Test_URL <- "https://kaijiang.500.com/shtml/kl8/2025239.shtml"
  # cat(KB_Test_URL)
  # cat(KB_His_URL)
  # KB_His_URL <-"https://kaijiang.500.com/shtml/kl8/2025239.shtml"
  # Guess_result <- guess_encoding(KB_His_URL)
  # KB_His_URL <-  "https://kaijiang.500.com/kl8.shtml"
  # KB_His_URL <- "https://www.cjcp.cn/kaijiang/fckl8/index.php?qh=2025239"
  KB_HisContent <- read_html(KB_His_URL, encoding = "GB18030") %>% html_text()
  
  KB_Pattern <-"(?s)第(.*?)(?=提示|$)"
  KB_Matched <- str_match(KB_HisContent,KB_Pattern)[1,1]
  # print(K8_Matched)
  KB_T <- KB_Matched %>% 
    str_replace_all("\\\\n", "") %>%  # 移除 \n
    str_replace_all("(?s)\\.ball.*?\\}", "") %>%
    str_replace_all("\\\\t", " ") %>%  # 替换 \t 为空格
    str_squish()    # 自动合并连续空格 + 清除首尾空格
  
  # cat(KB_Current)
  # 正则表达式提取关键字段
  KB_I <- str_match_all(KB_T, "第\\s*(\\d+)\\s*期")
  KB_D <- str_match_all(KB_T,"开奖日期：(\\d{4}年\\d{1,2}月\\d{1,2}日)")
  KB_N <- str_match_all(KB_T,"开奖号码：\\s*((?:\\d{2}\\s+){19}\\d{2})")
  KB_S <- str_match_all(KB_T,"本期销量：(\\d{1,3}(?:,\\d{3})*元)")
  KB_P <- str_match_all(KB_T,"奖池金额：(\\d{1,3}(?:,\\d{3})*元)")
  
  # str(KB_N[[1]][,2])
  # KB_Number <- str_split(KB_N[[1]][,2], "\\s+")
  # KB_Number[[1]][5]
  # 构建结构化列表
  KB_Matched <- list(
    KB_ISSUE = KB_I[[1]][,2],
    KB_DATE = as.Date(gsub("年|月|日", "-", KB_D[[1]][,2]), format="%Y-%m-%d"),
    KB_Number = str_split(KB_N[[1]][,2], "\\s+"),
    KB_SALES = as.numeric(gsub("[,元]", "", KB_S[[1]][,2])),
    KB_POOL = as.numeric(gsub("[,元]", "", KB_P[[1]][,2]))
  )
  # str(KB_Matched$KB_Number)
  KB_Number <- paste(KB_Matched$KB_Number[[1]], collapse = ",")
  KB_DATE <- paste0('"', KB_Matched$KB_DATE, '"')
  KB_DATA <- paste(KB_Matched$KB_ISSUE,KB_Number,KB_Matched$KB_SALES,
                   KB_Matched$KB_POOL,KB_DATE,sep = ",")
  cat(KB_Matched$KB_ISSUE," Start:")
  SPIDER_KB_Insert(KB_DATA)
  # return(KB_DATA)
  # return(KB_Matched)
}

# 遗漏单独更新，另要手工更新LIST_K8,用
# /opt/MyR/SPIDER/GH_SPIDER_K8.R
# SPIDER_KB_Manual(2025296)

# https://www.zhcw.com/kjxx/kl8/kjxq/
# SPIDER_K8() # 每日更新
# SPIDER_K8_SPIDER() # 按当前期逐期-1爬取全部