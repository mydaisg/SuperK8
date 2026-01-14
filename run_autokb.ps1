# AutoKB Automation Script
# Automatically run AutoKB.R and git push daily

# Set error handling
$ErrorActionPreference = "Stop"

# Log file path
$LogDir = "logs"
$LogFile = "$LogDir\AutoKB_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"

# Create log directory
if (-not (Test-Path $LogDir)) {
    New-Item -ItemType Directory -Path $LogDir | Out-Null
}

# Log function
function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] $Message"
    Write-Host $LogMessage
    Add-Content -Path $LogFile -Value $LogMessage
}

# Main function
function Main {
    Write-Log "========================================"
    Write-Log "AutoKB Automation Script Started"
    Write-Log "========================================"
    
    # Set working directory
    if ($PSScriptRoot) {
        $ScriptDir = $PSScriptRoot
    } else {
        $ScriptDir = Get-Location
    }
    Set-Location $ScriptDir
    Write-Log "Working directory: $ScriptDir"
    
    try {
        # Step 1: Run AutoKB.R
        Write-Log ""
        Write-Log "Step 1: Running AutoKB.R"
        Write-Log "----------------------------------------"
        
        $RScriptPath = "D:\Program Files\R\R-4.5.2\bin\Rscript.exe"
        
        if (-not (Test-Path $RScriptPath)) {
            Write-Log "Error: Rscript.exe not found, please check the path"
            return
        }
        
        Write-Log "Rscript path: $RScriptPath"
        Write-Log "Starting AutoKB.R execution..."
        
        $RProcess = Start-Process -FilePath $RScriptPath -ArgumentList "AutoKB.R" -Wait -PassThru -NoNewWindow -RedirectStandardOutput "$LogDir\R_output_$(Get-Date -Format 'yyyyMMdd_HHmmss').log" -RedirectStandardError "$LogDir\R_error_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
        
        if ($RProcess.ExitCode -eq 0) {
            Write-Log "AutoKB.R executed successfully"
        } else {
            Write-Log "AutoKB.R execution failed, exit code: $($RProcess.ExitCode)"
            return
        }
        
        # Step 2: Git operations
        Write-Log ""
        Write-Log "Step 2: Git operations"
        Write-Log "----------------------------------------"
        
        # Run git auto commit script
        Write-Log "Running git_auto_commit.ps1..."
        $GitCommitMessage = "AutoKB update - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        $GitProcess = Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"git_auto_commit.ps1`" -CommitMessage `"$GitCommitMessage`"" -Wait -PassThru -NoNewWindow
        
        if ($GitProcess.ExitCode -eq 0) {
            Write-Log "Git operations completed successfully"
        } else {
            Write-Log "Git operations failed, exit code: $($GitProcess.ExitCode)"
        }
        
        Write-Log ""
        Write-Log "========================================"
        Write-Log "AutoKB Automation Script Completed"
        Write-Log "========================================"
        
    } catch {
        Write-Log "Error: $($_.Exception.Message)"
        Write-Log "Stack trace: $($_.ScriptStackTrace)"
    }
}

# Execute main function
Main
