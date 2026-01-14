@echo off
REM AutoKB Task Scheduler Setup Script
REM Run this as Administrator to create the scheduled task

echo ========================================
echo AutoKB Task Scheduler Setup
echo ========================================
echo.

REM Check if running as Administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo Error: This script must be run as Administrator
    echo Right-click the file and select "Run as administrator"
    pause
    exit /b 1
)

echo Creating scheduled task...
echo.

REM Create the scheduled task using PowerShell
powershell.exe -Command "& {
    $action = New-ScheduledTaskAction `
        -Execute 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe' `
        -Argument '-ExecutionPolicy Bypass -File \"D:\GitHub\SuperK8\run_autokb.ps1\"' `
        -WorkingDirectory 'D:\GitHub\SuperK8';

    $trigger = New-ScheduledTaskTrigger `
        -Daily `
        -At '09:00 AM';

    $settings = New-ScheduledTaskSettingsSet `
        -AllowStartIfOnBatteries `
        -DontStopIfGoingOnBatteries `
        -StartWhenAvailable `
        -RestartCount 3 `
        -RestartInterval (New-TimeSpan -Minutes 1) `
        -ExecutionTimeLimit (New-TimeSpan -Hours 2);

    Register-ScheduledTask `
        -TaskName 'AutoKB Daily Automation' `
        -Action $action `
        -Trigger $trigger `
        -Settings $settings `
        -RunLevel Highest `
        -User 'SYSTEM' `
        -Force;

    Write-Host 'Scheduled task created successfully!' -ForegroundColor Green;
    Write-Host 'Task Name: AutoKB Daily Automation' -ForegroundColor Cyan;
    Write-Host 'Schedule: Daily at 09:00 AM' -ForegroundColor Cyan;
    Write-Host '';
    Write-Host 'To modify the schedule, open Task Scheduler (taskschd.msc)';
    Write-Host 'and edit the task settings.';
}"

if %errorLevel% equ 0 (
    echo.
    echo ========================================
    echo Setup completed successfully!
    echo ========================================
    echo.
    echo The task will run daily at 09:00 AM
    echo.
    echo To test the task immediately:
    echo 1. Open Task Scheduler (taskschd.msc)
    echo 2. Find "AutoKB Daily Automation"
    echo 3. Right-click and select "Run"
    echo.
    echo To view logs, check: D:\GitHub\SuperK8\logs\
    echo.
) else (
    echo.
    echo ========================================
    echo Setup failed!
    echo ========================================
    echo.
    echo Please check the error messages above.
    echo.
)

pause
