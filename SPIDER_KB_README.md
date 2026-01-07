# SPIDER_KB.R 使用说明

## 功能概述
SPIDER_KB.R 是一个用于爬取K8开奖数据并存储到SQLite数据库的R脚本。

## 主要函数

### 1. SPIDER_KB_Current()
爬取当前最新一期K8开奖数据

**返回值：** 包含以下字段的列表
- KB_ISSUE: 期号
- KB_DATE: 开奖日期
- KB_Number: 20个开奖号码
- KB_SALES: 本期销量
- KB_POOL: 奖池金额

**示例：**
```r
source("SPIDER_KB.R")
current_data <- SPIDER_KB_Current()
```

### 2. SPIDER_KB_Issue(KB_ISSUE)
爬取指定期数的K8开奖数据

**参数：**
- KB_ISSUE: 期号（如：2026006）

**返回值：** 同 SPIDER_KB_Current()

**示例：**
```r
source("SPIDER_KB.R")
data <- SPIDER_KB_Issue(2026006)
```

### 3. SPIDER_KB_Insert(KB_DATA)
将爬取的数据插入到GH_DB_LT.db数据库的KB表中

**参数：**
- KB_DATA: 由 SPIDER_KB_Current() 或 SPIDER_KB_Issue() 返回的数据列表

**返回值：**
- 1: 插入成功
- 0: 数据已存在，跳过

**示例：**
```r
source("SPIDER_KB.R")
current_data <- SPIDER_KB_Current()
result <- SPIDER_KB_Insert(current_data)
```

### 4. SPIDER_KB_Loop(years = 5)
循环爬取指定年份的历史数据，从当前期开始往前推

**参数：**
- years: 爬取的年数（默认5年）

**返回值：** 包含统计信息的列表
- success: 成功插入的期数
- skip: 跳过的期数（已存在）
- fail: 失败的期数

**示例：**
```r
source("SPIDER_KB.R")
result <- SPIDER_KB_Loop(years = 5)
```

## 使用场景

### 场景1：每日更新最新数据
```r
source("SPIDER_KB.R")
current_data <- SPIDER_KB_Current()
SPIDER_KB_Insert(current_data)
```

### 场景2：补充指定期数数据
```r
source("SPIDER_KB.R")
data <- SPIDER_KB_Issue(2026006)
if (!is.null(data)) {
  SPIDER_KB_Insert(data)
}
```

### 场景3：批量爬取历史数据
```r
source("SPIDER_KB.R")
# 爬取最近5年数据
result <- SPIDER_KB_Loop(years = 5)
```

### 场景4：爬取最近10期数据
```r
source("SPIDER_KB.R")
current_data <- SPIDER_KB_Current()
current_issue <- as.numeric(current_data$KB_ISSUE)

for (issue in current_issue:(current_issue-9)) {
  data <- SPIDER_KB_Issue(issue)
  if (!is.null(data)) {
    SPIDER_KB_Insert(data)
  }
  Sys.sleep(0.5)  # 避免请求过快
}
```

## 数据库结构

### KB表
| 字段 | 类型 | 说明 |
|------|------|------|
| ISSUE | INT | 期号（主键） |
| KB1-KB20 | INT | 20个开奖号码 |
| SALES | INT | 本期销量 |
| POOL | INT | 奖池金额 |
| DATES | TEXT | 开奖日期 |

## 注意事项

1. **网络连接：** 需要能够访问 https://kaijiang.500.com
2. **请求频率：** 建议在循环爬取时添加延迟（Sys.sleep(0.5)），避免请求过快被限制
3. **数据去重：** 使用 INSERT OR IGNORE 语句，已存在的期号会自动跳过
4. **错误处理：** SPIDER_KB_Issue() 函数包含错误处理，爬取失败会返回 NULL
5. **跨年处理：** SPIDER_KB_Loop() 函数自动处理跨年期号

## 依赖包

- rvest: 网页爬取
- stringr: 字符串处理
- RSQLite: 数据库操作

## 测试脚本

- test_spider_insert.R: 测试爬取并插入当前数据
- test_spider_issue.R: 测试爬取指定期数数据
- test_spider_loop.R: 测试循环爬取最近10期数据
- SQL_Verify.R: 验证数据库结构
- SQL_ViewData.R: 查看数据库中的数据
