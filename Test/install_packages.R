# 安装SuperK8项目所需的所有R包

# 设置镜像源为国内镜像（如果可用）
options(repos = c(CRAN = "https://cloud.r-project.org/"))

# 需要安装的包列表
packages <- c(
  "mlr3verse",      # mlr3核心及常用扩展包
  "data.table",     # 高效数据处理
  "GH.AN.LIST",     # 最新数据获取
  "ggplot2"         # 数据可视化（mlr3verse已包含，但显式安装）
)

# 安装函数
install_if_missing <- function(packages) {
  for (pkg in packages) {
    if (!require(pkg, character.only = TRUE, quietly = TRUE)) {
      cat(paste0("正在安装包: ", pkg, "\n"))
      install.packages(pkg, dependencies = TRUE)
      if (require(pkg, character.only = TRUE, quietly = TRUE)) {
        cat(paste0("✓ ", pkg, " 安装成功\n"))
      } else {
        cat(paste0("✗ ", pkg, " 安装失败\n"))
      }
    } else {
      cat(paste0("✓ ", pkg, " 已安装\n"))
    }
  }
}

# 执行安装
cat("开始安装SuperK8项目所需的R包...\n")
install_if_missing(packages)

cat("\n所有包安装完成！\n")
