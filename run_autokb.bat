@echo off
REM AutoKB 自动化批处理文件
REM 用于Windows任务计划程序

echo ========================================
echo AutoKB 自动化脚本
echo ========================================
echo.

REM 设置工作目录
cd /d "%~dp0"

REM 运行PowerShell脚本
powershell.exe -ExecutionPolicy Bypass -File "run_autokb.ps1"

REM 检查执行结果
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo AutoKB 执行成功
    echo ========================================
) else (
    echo.
    echo ========================================
    echo AutoKB 执行失败，错误代码: %errorlevel%
    echo ========================================
)

pause
