GH_LIST_KB <- function(start_date, end_date, num_days) {
  set.seed(123)
  
  num_rows <- num_days
  
  dates <- seq(as.Date(start_date, format="%Y%m%d"), 
               by = "day", 
               length.out = num_rows)
  
  KB_cols <- paste0("KB", 1:20)
  
  data <- as.data.table(matrix(
    rnorm(num_rows * 20, mean = 100, sd = 20),
    nrow = num_rows,
    ncol = 20
  ))
  setnames(data, KB_cols)
  
  data[, DATES := dates]
  
  data[, POOL := runif(num_rows, 1000, 5000)]
  
  data[, ISSUE := sample(0:1, num_rows, replace = TRUE)]
  
  setcolorder(data, c("DATES", KB_cols, "POOL", "ISSUE"))
  
  return(data)
}
