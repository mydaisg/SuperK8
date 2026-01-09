GH_Create_WorkingDir_perYear <- function(year = NULL){
  if (is.null(year)) {
    year <- as.numeric(format(Sys.Date(), "%Y"))
  }
  
  cat("========================================\n")
  cat(paste("创建", year, "年工作目录\n"))
  cat("========================================\n\n")
  
  base_path <- "D:\\"
  
  dir1 <- paste0(base_path, "Tai_LVCC_", year)
  dir2 <- paste0(base_path, "Tai_LVCC_Soft_", year)
  
  cat(paste("创建目录:", dir1, "\n"))
  if (!dir.exists(dir1)) {
    dir.create(dir1, recursive = TRUE)
    cat(paste("✓", dir1, "创建成功\n"))
  } else {
    cat(paste("-", dir1, "已存在\n"))
  }
  
  cat(paste("创建目录:", dir2, "\n"))
  if (!dir.exists(dir2)) {
    dir.create(dir2, recursive = TRUE)
    cat(paste("✓", dir2, "创建成功\n"))
  } else {
    cat(paste("-", dir2, "已存在\n"))
  }
  
  subdirs <- c(
    "Tai_10_OrganizationMangement",
    "Tai_11_PlanningAndDesigning",
    "Tai_20_ProcessMangement",
    "Tai_30_Audit",
    "Tai_50_DemandManagement",
    "Tai_60_ProjectManagement",
    "Tai_71_AssetManagement",
    "Tai_72_ConfigurationManagement",
    "Tai_73_IssueManagement",
    "Tai_74_EventManagement",
    "Tai_75_ITInfra",
    "Tai_77_ITServices",
    "Tai_78_ITSecurity",
    "Tai_80_Reporting",
    paste0("Tai_99_Archives_LVCC_", year)
  )
  
  cat("\n创建二级目录:\n")
  
  for (subdir in subdirs) {
    full_path <- file.path(dir1, subdir)
    cat(paste("  创建:", full_path, "\n"))
    if (!dir.exists(full_path)) {
      dir.create(full_path, recursive = TRUE)
      cat(paste("  ✓", full_path, "创建成功\n"))
    } else {
      cat(paste("  -", full_path, "已存在\n"))
    }
  }
  
  cat("\n========================================\n")
  cat(paste(year, "年工作目录创建完成\n"))
  cat("========================================\n")
  
  return(list(
    year = year,
    dir1 = dir1,
    dir2 = dir2,
    subdirs = file.path(dir1, subdirs)
  ))
}

result <- GH_Create_WorkingDir_perYear()
