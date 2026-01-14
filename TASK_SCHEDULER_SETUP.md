# Windows Task Scheduler Setup Guide for AutoKB

## Overview
This guide explains how to set up Windows Task Scheduler to automatically run the AutoKB script daily.

## Prerequisites
- Windows 10/11
- Git installed and configured
- R installed (R-4.5.2)
- AutoKB.R and run_autokb.ps1 files in D:\GitHub\SuperK8

## Method 1: Using Windows Task Scheduler (GUI)

### Step 1: Open Task Scheduler
1. Press `Win + R` to open the Run dialog
2. Type `taskschd.msc` and press Enter
3. The Task Scheduler window will open

### Step 2: Create a New Task
1. In the right panel, click "Create Task" (not "Create Basic Task")
2. The "Create Task" dialog will appear

### Step 3: General Tab Settings
1. **Name**: Enter "AutoKB Daily Automation"
2. **Description**: "Run AutoKB.R and git push daily"
3. **Security Options**:
   - Select "Run whether user is logged on or not"
   - Check "Run with highest privileges"
   - Configure for: "Windows 10" or your current OS version
4. Click "OK" to save and proceed

### Step 4: Triggers Tab
1. Click the "Triggers" tab
2. Click "New..." button
3. **Begin the task**: Select "On a schedule"
4. **Settings**:
   - Daily: Select this option
   - Start: Set your preferred time (e.g., 09:00:00 AM)
   - Repeat task every: 1 day
5. **Advanced settings** (optional):
   - Check "Stop task if it runs longer than": 2 hours
   - Check "If the running task does not end when requested, force it to stop"
6. Click "OK"

### Step 5: Actions Tab
1. Click the "Actions" tab
2. Click "New..." button
3. **Action**: Select "Start a program"
4. **Program/script**: Enter the full path to PowerShell
   ```
   C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
   ```
5. **Add arguments**: Enter the following
   ```
   -ExecutionPolicy Bypass -File "D:\GitHub\SuperK8\run_autokb.ps1"
   ```
6. **Start in** (optional): Enter
   ```
   D:\GitHub\SuperK8
   ```
7. Click "OK"

### Step 6: Conditions Tab (Optional)
1. Click the "Conditions" tab
2. **Power**:
   - Uncheck "Start the task only if the computer is on AC power" (if running on desktop)
   - Uncheck "Stop if the computer switches to battery power" (if running on desktop)
3. **Network**:
   - Check "Start only if the following network connection is available"
   - Select "Any connection" (for git push to work)
4. Click "OK"

### Step 7: Settings Tab
1. Click the "Settings" tab
2. **Allow task to be run on demand**: Checked
3. **Run task as soon as possible after a scheduled start is missed**: Checked
4. **If the task fails, restart every**: 1 minute
5. **Attempt to restart up to**: 3 times
6. **Stop the task if it runs longer than**: 2 hours
7. **If the running task does not end when requested, force it to stop**: Checked
8. Click "OK"

### Step 8: Test the Task
1. Right-click on your new task "AutoKB Daily Automation"
2. Select "Run"
3. Check the execution history in the "History" tab
4. Verify the log files in `D:\GitHub\SuperK8\logs\` folder

## Method 2: Using Command Line (Alternative)

### Create Task via PowerShell
Run the following PowerShell command as Administrator:

```powershell
$action = New-ScheduledTaskAction `
    -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -File 'D:\GitHub\SuperK8\run_autokb.ps1'" `
    -WorkingDirectory "D:\GitHub\SuperK8"

$trigger = New-ScheduledTaskTrigger `
    -Daily `
    -At "09:00 AM"

$settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1) `
    -ExecutionTimeLimit (New-TimeSpan -Hours 2)

Register-ScheduledTask `
    -TaskName "AutoKB Daily Automation" `
    -Action $action `
    -Trigger $trigger `
    -Settings $settings `
    -RunLevel Highest `
    -User "SYSTEM" `
    -Force
```

## Troubleshooting

### Issue: Task doesn't run
1. Check Task Scheduler History for error messages
2. Verify the script path is correct
3. Ensure PowerShell execution policy allows script execution
4. Check that the user account has necessary permissions

### Issue: Git push fails
1. Ensure network connection is available
2. Verify Git credentials are stored (use `git credential-manager`)
3. Check that the remote repository URL is correct
4. Run `git push` manually to test connectivity

### Issue: R script fails
1. Check R installation path in run_autokb.ps1
2. Verify AutoKB.R exists in the working directory
3. Review log files in `logs\` folder for detailed error messages

### Issue: Log files not created
1. Ensure the script has write permissions to the logs directory
2. Check if the logs directory exists (script should create it automatically)
3. Verify disk space is available

## Log Files Location
All logs are stored in: `D:\GitHub\SuperK8\logs\`

- `AutoKB_YYYYMMDD_HHMMSS.log` - Main automation log
- `R_output_YYYYMMDD_HHMMSS.log` - R script output
- `R_error_YYYYMMDD_HHMMSS.log` - R script errors

## Manual Testing
To test the automation manually without Task Scheduler:

```powershell
cd D:\GitHub\SuperK8
powershell.exe -ExecutionPolicy Bypass -File run_autokb.ps1
```

Or double-click `run_autokb.bat` file.

## Monitoring and Maintenance
1. Regularly check log files for errors
2. Verify git push is successful by checking remote repository
3. Update R script path if R installation changes
4. Review and adjust schedule as needed

## Security Considerations
1. Store Git credentials securely using Git Credential Manager
2. Ensure the script file permissions are restricted
3. Consider using a dedicated service account for the task
4. Regularly update R and Git to latest versions

## Additional Notes
- The task will run even if the user is not logged in
- If the computer is off at the scheduled time, the task will run when the computer is next started (if "Run task as soon as possible" is checked)
- The script automatically handles git operations only when there are changes
- All operations are logged for troubleshooting purposes
