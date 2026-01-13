########### Auto Spider Logic #######
# 自动执行各赛道的最新更新及辨别逻辑
## 常量（各赛道周几、时间/
## 变量（当前周几时间
## 判断（最后数据至今是否发生Open活动
SK_CurrentTime <- Sys.time()
SK_CurrentDay <- Sys.Date()
SK_CurrentWeek <- 
SK_OpenTime <- "22:00"
SK_TrackNumber <- 4
SK_WeekNumber <- 7

SK_SpiderAuto <- function(){
  # 矩阵：赛道1～4，星期1～7，
  
  open_venues <- c(1,3,4)
  return(open_venues)
}


source("SPIDER_KB.R")
result <- SPIDER_KB_Once()