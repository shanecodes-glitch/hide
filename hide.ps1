# ============================================================
# SHANECODES REPAIR TOOL - NEON EDITION v11.2
# ============================================================
# Public Repository Edition - No Token Required
# ============================================================

# ============================================================
# CONFIGURATION
# ============================================================
$script:GITHUB_RAW = "https://raw.githubusercontent.com/shanecodes-glitch/ShaneCodes-System-Repair/main/tisting.bat"
$script:VERSION = "11.2"
$script:AUTHOR = "Shane Nichael Obinguar"
$script:CONTACT = "https://www.facebook.com/Shxne.Nichael"
$script:COPYRIGHT = "(c) 2024 ShaneCodes Technologies. All rights reserved."

# ============================================================
# LOAD ASSEMBLIES
# ============================================================
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
} catch {
    try {
        [System.Reflection.Assembly]::Load("System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089") | Out-Null
        [System.Reflection.Assembly]::Load("System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a") | Out-Null
    } catch {
        Write-Host "[ERROR] Failed to load required assemblies." -ForegroundColor Red
    }
}

[System.Windows.Forms.Application]::EnableVisualStyles()

# ============================================================
# CONSOLE HIDING
# ============================================================
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class ConsoleManager {
    [DllImport("kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
}
"@

$script:CONSOLE_HANDLE = [ConsoleManager]::GetConsoleWindow()
[ConsoleManager]::ShowWindow($script:CONSOLE_HANDLE, 0)

# ============================================================
# ADMIN CHECK
# ============================================================
function Test-Admin {
    try {
        return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")
    } catch {
        return $false
    }
}

# ============================================================
# SYSTEM INFO
# ============================================================
function Get-SystemInfo {
    $info = @{}
    try {
        $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
        $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
        $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
        
        $info.OS = $os.Caption
        $info.Build = $os.BuildNumber
        $info.Arch = $cs.SystemType
        $info.RAM = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        $info.CPU = $cpu.Name
        $info.User = $env:USERNAME
        $info.Computer = $env:COMPUTERNAME
    } catch {
        $info.OS = "Windows"
        $info.Build = "Unknown"
        $info.Arch = "64-bit"
        $info.RAM = "Unknown"
        $info.CPU = "Unknown"
        $info.User = $env:USERNAME
        $info.Computer = $env:COMPUTERNAME
    }
    return $info
}

# ============================================================
# DOWNLOAD FUNCTION (No Token)
# ============================================================
function Invoke-Download {
    param([string]$Url, [string]$OutputPath)
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "ShaneCodes-Repair/$($script:VERSION)")
        $webClient.DownloadFile($Url, $OutputPath)
        
        if (Test-Path $OutputPath) {
            Set-ItemProperty -Path $OutputPath -Name Attributes -Value "Hidden" -ErrorAction SilentlyContinue
            return $true
        }
        return $false
    } catch {
        return $false
    }
}

# ============================================================
# DELETE FILE (ZERO TRACE)
# ============================================================
function Remove-BatchFile {
    param([string]$Path)
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
            if (Test-Path $Path) {
                $cmd = "Start-Sleep -Seconds 1; Remove-Item -Path '$Path' -Force -ErrorAction SilentlyContinue"
                Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"$cmd`"" -WindowStyle Hidden
            }
        }
    } catch {}
}

# ============================================================
# SHOW MESSAGE BOX
# ============================================================
function Show-MessageBox {
    param($Message, $Title = "ShaneCodes", $Icon = "Information")
    try {
        $iconMap = @{
            "Information" = [System.Windows.Forms.MessageBoxIcon]::Information
            "Warning"     = [System.Windows.Forms.MessageBoxIcon]::Warning
            "Error"       = [System.Windows.Forms.MessageBoxIcon]::Error
            "Question"    = [System.Windows.Forms.MessageBoxIcon]::Question
        }
        return [System.Windows.Forms.MessageBox]::Show($Message, $Title, "YesNo", $iconMap[$Icon])
    } catch {
        Write-Host "[$Title] $Message" -ForegroundColor Cyan
        return "Yes"
    }
}

# ============================================================
# REPAIR ENGINE (RUNS IN BACKGROUND)
# ============================================================
function Start-RepairBackground {
    param(
        [string]$TempBat,
        [System.Windows.Forms.Form]$Form,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$PercentLabel,
        [System.Windows.Forms.Label]$StatusLabel,
        [System.Windows.Forms.Label]$ProgressLabel,
        [System.Windows.Forms.Button]$BtnStart,
        [System.Windows.Forms.Button]$BtnSupport,
        [System.Windows.Forms.Button]$BtnExit
    )
    
    try {
        Update-UI -Form $Form -ProgressBar $ProgressBar -PercentLabel $PercentLabel -StatusLabel $StatusLabel -ProgressLabel $ProgressLabel -Percent 10 -Status "Downloading repair modules..."
        
        $success = Invoke-Download -Url $script:GITHUB_RAW -OutputPath $TempBat
        
        if (-not $success -or -not (Test-Path $TempBat)) {
            [System.Windows.Forms.MessageBox]::Show("Download failed. Please check your internet connection and try again.", "Download Error", "OK", [System.Windows.Forms.MessageBoxIcon]::Error)
            Enable-Buttons -BtnStart $BtnStart -BtnSupport $BtnSupport -BtnExit $BtnExit
            return
        }
        
        Update-UI -Form $Form -ProgressBar $ProgressBar -PercentLabel $PercentLabel -StatusLabel $StatusLabel -ProgressLabel $ProgressLabel -Percent 30 -Status "Running repair tool..."
        
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$TempBat`"" -WindowStyle Hidden -PassThru
        
        $steps = @(
            @{Percent = 40; Status = "Initializing licensing services..."},
            @{Percent = 55; Status = "Installing repair key..."},
            @{Percent = 70; Status = "Generating repair ticket..."},
            @{Percent = 85; Status = "Applying repair ticket..."},
            @{Percent = 95; Status = "Activating license..."}
        )
        
        $stepIndex = 0
        while (-not $process.HasExited -and $stepIndex -lt $steps.Count) {
            if ($stepIndex -lt $steps.Count) {
                Update-UI -Form $Form -ProgressBar $ProgressBar -PercentLabel $PercentLabel -StatusLabel $StatusLabel -ProgressLabel $ProgressLabel -Percent $steps[$stepIndex].Percent -Status $steps[$stepIndex].Status
                $stepIndex++
            }
            Start-Sleep -Milliseconds 500
        }
        
        $process.WaitForExit()
        
        Update-UI -Form $Form -ProgressBar $ProgressBar -PercentLabel $PercentLabel -StatusLabel $StatusLabel -ProgressLabel $ProgressLabel -Percent 100 -Status "Repair complete!"
        
        if ($process.ExitCode -eq 0) {
            Show-ResultDialog -ExitCode 0
        } else {
            Show-ResultDialog -ExitCode $process.ExitCode
        }
        
    } catch {
        [System.Windows.Forms.MessageBox]::Show("An error occurred: $($_.Exception.Message)", "Error", "OK", [System.Windows.Forms.MessageBoxIcon]::Error)
    } finally {
        Remove-BatchFile -Path $TempBat
        Enable-Buttons -BtnStart $BtnStart -BtnSupport $BtnSupport -BtnExit $BtnExit
    }
}

# ============================================================
# UI UPDATE HELPER
# ============================================================
function Update-UI {
    param(
        [System.Windows.Forms.Form]$Form,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$PercentLabel,
        [System.Windows.Forms.Label]$StatusLabel,
        [System.Windows.Forms.Label]$ProgressLabel,
        [int]$Percent,
        [string]$Status
    )
    
    if ($Form -and -not $Form.IsDisposed) {
        try {
            if ($ProgressBar) { $ProgressBar.Value = $Percent }
            if ($PercentLabel) { $PercentLabel.Text = "$Percent%" }
            if ($StatusLabel) { $StatusLabel.Text = "[*] $Status" }
            if ($ProgressLabel) { $ProgressLabel.Text = $Status }
            [System.Windows.Forms.Application]::DoEvents()
        } catch {}
    }
}

# ============================================================
# ENABLE/DISABLE BUTTONS
# ============================================================
function Enable-Buttons {
    param(
        [System.Windows.Forms.Button]$BtnStart,
        [System.Windows.Forms.Button]$BtnSupport,
        [System.Windows.Forms.Button]$BtnExit
    )
    try {
        if ($BtnStart) { $BtnStart.Enabled = $true }
        if ($BtnSupport) { $BtnSupport.Enabled = $true }
        if ($BtnExit) { $BtnExit.Enabled = $true }
    } catch {}
}

function Disable-Buttons {
    param(
        [System.Windows.Forms.Button]$BtnStart,
        [System.Windows.Forms.Button]$BtnSupport,
        [System.Windows.Forms.Button]$BtnExit
    )
    try {
        if ($BtnStart) { $BtnStart.Enabled = $false }
        if ($BtnSupport) { $BtnSupport.Enabled = $false }
        if ($BtnExit) { $BtnExit.Enabled = $false }
    } catch {}
}

# ============================================================
# RESULT DIALOG
# ============================================================
function Show-ResultDialog {
    param($ExitCode)
    
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes - Repair Complete"
        $form.Size = New-Object System.Drawing.Size(480, 280)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 30)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.TopMost = $true

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 55
        $header.BackColor = if ($ExitCode -eq 0) { [System.Drawing.Color]::FromArgb(0, 150, 80) } else { [System.Drawing.Color]::FromArgb(180, 40, 40) }
        $form.Controls.Add($header)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::White
        $title.Location = New-Object System.Drawing.Point(15, 10)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $subHead = New-Object System.Windows.Forms.Label
        $subHead.Text = if ($ExitCode -eq 0) { "Repair Successful" } else { "Repair Failed" }
        $subHead.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $subHead.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
        $subHead.Location = New-Object System.Drawing.Point(17, 33)
        $subHead.AutoSize = $true
        $header.Controls.Add($subHead)

        $iconLabel = New-Object System.Windows.Forms.Label
        if ($ExitCode -eq 0) {
            $iconLabel.Text = "[OK]"
            $iconLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        } else {
            $iconLabel.Text = "[X]"
            $iconLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
        }
        $iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 36, [System.Drawing.FontStyle]::Bold)
        $iconLabel.Location = New-Object System.Drawing.Point(45, 80)
        $iconLabel.Size = New-Object System.Drawing.Size(80, 70)
        $iconLabel.TextAlign = "MiddleCenter"
        $form.Controls.Add($iconLabel)

        $msg = New-Object System.Windows.Forms.Label
        if ($ExitCode -eq 0) {
            $msg.Text = "REPAIR COMPLETE"
            $msg.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        } else {
            $msg.Text = "REPAIR FAILED"
            $msg.ForeColor = [System.Drawing.Color]::FromArgb(255, 100, 100)
        }
        $msg.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $msg.Location = New-Object System.Drawing.Point(135, 85)
        $msg.AutoSize = $true
        $form.Controls.Add($msg)

        $sub = New-Object System.Windows.Forms.Label
        if ($ExitCode -eq 0) {
            $sub.Text = "Your system has been successfully repaired."
        } else {
            $sub.Text = "Please try running as Administrator or contact support."
        }
        $sub.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $sub.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 220)
        $sub.Location = New-Object System.Drawing.Point(135, 115)
        $sub.AutoSize = $true
        $form.Controls.Add($sub)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "[OK] THANK YOU"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btn.Size = New-Object System.Drawing.Size(160, 42)
        $btn.Location = New-Object System.Drawing.Point(160, 185)
        $btn.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150)
        $btn.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $btn.FlatStyle = "Flat"
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 255, 200) })
        $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150) })
        $btn.Add_Click({ $form.Close() })
        $form.Controls.Add($btn)

        $copyright = New-Object System.Windows.Forms.Label
        $copyright.Text = $script:COPYRIGHT
        $copyright.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
        $copyright.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 120)
        $copyright.Location = New-Object System.Drawing.Point(0, 250)
        $copyright.Size = New-Object System.Drawing.Size(480, 20)
        $copyright.TextAlign = "MiddleCenter"
        $form.Controls.Add($copyright)

        $form.ShowDialog()
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Repair completed (Exit Code: $ExitCode)", "Result", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

# ============================================================
# SUPPORT DIALOG
# ============================================================
function Show-ContactDialog {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes - Support"
        $form.Size = New-Object System.Drawing.Size(520, 300)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 30)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.TopMost = $true

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 55
        $header.BackColor = [System.Drawing.Color]::FromArgb(0, 80, 170)
        $form.Controls.Add($header)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::White
        $title.Location = New-Object System.Drawing.Point(15, 10)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $subHead = New-Object System.Windows.Forms.Label
        $subHead.Text = "Support Center"
        $subHead.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $subHead.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
        $subHead.Location = New-Object System.Drawing.Point(17, 33)
        $subHead.AutoSize = $true
        $header.Controls.Add($subHead)

        $msg = New-Object System.Windows.Forms.Label
        $msg.Text = "Contact ShaneCodes Support`n`n$($script:CONTACT)"
        $msg.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $msg.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $msg.Location = New-Object System.Drawing.Point(40, 80)
        $msg.Size = New-Object System.Drawing.Size(440, 120)
        $msg.TextAlign = "MiddleCenter"
        $form.Controls.Add($msg)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "[OK] THANK YOU"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btn.Size = New-Object System.Drawing.Size(140, 42)
        $btn.Location = New-Object System.Drawing.Point(190, 220)
        $btn.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150)
        $btn.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $btn.FlatStyle = "Flat"
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 255, 200) })
        $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150) })
        $btn.Add_Click({ $form.Close() })
        $form.Controls.Add($btn)

        $form.ShowDialog()
    } catch {
        [System.Windows.Forms.MessageBox]::Show("Contact: $($script:CONTACT)", "Support", "OK", [System.Windows.Forms.MessageBoxIcon]::Information)
    }
}

# ============================================================
# MAIN GUI - NEON STYLE (NON-BLOCKING)
# ============================================================
function Show-NeonGUI {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "SHANECODES REPAIR - NEON EDITION v$($script:VERSION)"
        $form.Size = New-Object System.Drawing.Size(700, 520)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $true
        $form.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 30)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.Opacity = 0.95
        $form.TopMost = $true

        $inner = New-Object System.Windows.Forms.Panel
        $inner.Dock = "Fill"
        $inner.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 30)
        $form.Controls.Add($inner)

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 110
        $header.BackColor = [System.Drawing.Color]::FromArgb(10, 12, 30)
        $inner.Controls.Add($header)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 32, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $title.Location = New-Object System.Drawing.Point(25, 20)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $sub = New-Object System.Windows.Forms.Label
        $sub.Text = "SYSTEM REPAIR - NEON EDITION"
        $sub.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $sub.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 255)
        $sub.Location = New-Object System.Drawing.Point(28, 60)
        $sub.AutoSize = $true
        $header.Controls.Add($sub)

        $versionBadge = New-Object System.Windows.Forms.Label
        $versionBadge.Text = " v$($script:VERSION) "
        $versionBadge.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $versionBadge.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $versionBadge.BackColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $versionBadge.Size = New-Object System.Drawing.Size(80, 30)
        $versionBadge.Location = New-Object System.Drawing.Point(590, 25)
        $versionBadge.TextAlign = "MiddleCenter"
        $header.Controls.Add($versionBadge)

        $glowLine = New-Object System.Windows.Forms.Label
        $glowLine.Text = "============================================================"
        $glowLine.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $glowLine.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200, 50)
        $glowLine.Location = New-Object System.Drawing.Point(0, 100)
        $glowLine.Size = New-Object System.Drawing.Size(700, 15)
        $glowLine.TextAlign = "MiddleCenter"
        $header.Controls.Add($glowLine)

        $statusPanel = New-Object System.Windows.Forms.Panel
        $statusPanel.Location = New-Object System.Drawing.Point(25, 130)
        $statusPanel.Size = New-Object System.Drawing.Size(650, 45)
        $statusPanel.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 45)
        $statusPanel.BorderStyle = "FixedSingle"
        $inner.Controls.Add($statusPanel)

        $statusDot = New-Object System.Windows.Forms.Label
        $statusDot.Text = "[O]"
        $statusDot.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $statusDot.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 100)
        $statusDot.Location = New-Object System.Drawing.Point(15, 10)
        $statusDot.Size = New-Object System.Drawing.Size(40, 30)
        $statusDot.TextAlign = "MiddleCenter"
        $statusPanel.Controls.Add($statusDot)

        $statusLabel = New-Object System.Windows.Forms.Label
        $statusLabel.Text = "SYSTEM READY"
        $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $statusLabel.Location = New-Object System.Drawing.Point(55, 10)
        $statusLabel.AutoSize = $true
        $statusPanel.Controls.Add($statusLabel)

        $sysInfo = New-Object System.Windows.Forms.Label
        $sysInfo.Text = "[Windows] [64-bit] [Online]"
        $sysInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $sysInfo.ForeColor = [System.Drawing.Color]::FromArgb(150, 150, 200)
        $sysInfo.Location = New-Object System.Drawing.Point(450, 12)
        $sysInfo.AutoSize = $true
        $statusPanel.Controls.Add($sysInfo)

        $progressPanel = New-Object System.Windows.Forms.Panel
        $progressPanel.Location = New-Object System.Drawing.Point(25, 195)
        $progressPanel.Size = New-Object System.Drawing.Size(650, 55)
        $progressPanel.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 45)
        $progressPanel.BorderStyle = "FixedSingle"
        $inner.Controls.Add($progressPanel)

        $progressLabel = New-Object System.Windows.Forms.Label
        $progressLabel.Name = "progressLabel"
        $progressLabel.Text = "Initializing..."
        $progressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $progressLabel.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 255)
        $progressLabel.Location = New-Object System.Drawing.Point(15, 8)
        $progressLabel.AutoSize = $true
        $progressPanel.Controls.Add($progressLabel)

        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Name = "progressBar"
        $progressBar.Location = New-Object System.Drawing.Point(15, 32)
        $progressBar.Size = New-Object System.Drawing.Size(620, 18)
        $progressBar.Style = "Continuous"
        $progressBar.Value = 0
        $progressBar.Minimum = 0
        $progressBar.Maximum = 100
        $progressBar.BackColor = [System.Drawing.Color]::FromArgb(20, 25, 55)
        $progressBar.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $progressPanel.Controls.Add($progressBar)

        $percentLabel = New-Object System.Windows.Forms.Label
        $percentLabel.Name = "percentLabel"
        $percentLabel.Text = "0%"
        $percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $percentLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
        $percentLabel.Location = New-Object System.Drawing.Point(595, 30)
        $percentLabel.Size = New-Object System.Drawing.Size(40, 20)
        $percentLabel.TextAlign = "MiddleCenter"
        $progressPanel.Controls.Add($percentLabel)

        $infoPanel = New-Object System.Windows.Forms.Panel
        $infoPanel.Location = New-Object System.Drawing.Point(25, 265)
        $infoPanel.Size = New-Object System.Drawing.Size(650, 90)
        $infoPanel.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 45)
        $infoPanel.BorderStyle = "FixedSingle"
        $inner.Controls.Add($infoPanel)

        $infoTitle = New-Object System.Windows.Forms.Label
        $infoTitle.Text = "[+] SYSTEM DIAGNOSTICS"
        $infoTitle.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $infoTitle.ForeColor = [System.Drawing.Color]::FromArgb(100, 200, 255)
        $infoTitle.Location = New-Object System.Drawing.Point(15, 8)
        $infoTitle.AutoSize = $true
        $infoPanel.Controls.Add($infoTitle)

        $sysData = Get-SystemInfo
        $infoLines = @(
            "OS: $($sysData.OS)  Build: $($sysData.Build)",
            "CPU: $($sysData.CPU)",
            "RAM: $($sysData.RAM) GB  |  User: $($sysData.User)"
        )

        $infoText = New-Object System.Windows.Forms.Label
        $infoText.Text = $infoLines -join "`n"
        $infoText.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $infoText.ForeColor = [System.Drawing.Color]::FromArgb(180, 180, 220)
        $infoText.Location = New-Object System.Drawing.Point(15, 28)
        $infoText.Size = New-Object System.Drawing.Size(620, 50)
        $infoPanel.Controls.Add($infoText)

        $btnStart = New-Object System.Windows.Forms.Button
        $btnStart.Text = "[>] START REPAIR"
        $btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $btnStart.Size = New-Object System.Drawing.Size(200, 50)
        $btnStart.Location = New-Object System.Drawing.Point(25, 375)
        $btnStart.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150)
        $btnStart.ForeColor = [System.Drawing.Color]::FromArgb(0, 0, 0)
        $btnStart.FlatStyle = "Flat"
        $btnStart.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnStart.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 255, 200) })
        $btnStart.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 200, 150) })
        $btnStart.Add_Click({
            Disable-Buttons -BtnStart $btnStart -BtnSupport $btnSupport -BtnExit $btnExit
            $tempBat = [System.IO.Path]::GetTempFileName() + ".bat"
            $tempBat = $tempBat -replace ".tmp", ".bat"
            Start-RepairBackground -TempBat $tempBat -Form $form -ProgressBar $progressBar -PercentLabel $percentLabel -StatusLabel $statusLabel -ProgressLabel $progressLabel -BtnStart $btnStart -BtnSupport $btnSupport -BtnExit $btnExit
        })
        $inner.Controls.Add($btnStart)

        $btnSupport = New-Object System.Windows.Forms.Button
        $btnSupport.Text = "[?] SUPPORT"
        $btnSupport.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btnSupport.Size = New-Object System.Drawing.Size(160, 50)
        $btnSupport.Location = New-Object System.Drawing.Point(240, 375)
        $btnSupport.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 100)
        $btnSupport.ForeColor = [System.Drawing.Color]::FromArgb(200, 200, 255)
        $btnSupport.FlatStyle = "Flat"
        $btnSupport.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnSupport.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(60, 60, 140) })
        $btnSupport.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(40, 40, 100) })
        $btnSupport.Add_Click({ Show-ContactDialog })
        $inner.Controls.Add($btnSupport)

        $btnExit = New-Object System.Windows.Forms.Button
        $btnExit.Text = "[X] EXIT"
        $btnExit.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btnExit.Size = New-Object System.Drawing.Size(120, 50)
        $btnExit.Location = New-Object System.Drawing.Point(415, 375)
        $btnExit.BackColor = [System.Drawing.Color]::FromArgb(80, 30, 30)
        $btnExit.ForeColor = [System.Drawing.Color]::FromArgb(255, 150, 150)
        $btnExit.FlatStyle = "Flat"
        $btnExit.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnExit.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(110, 45, 45) })
        $btnExit.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(80, 30, 30) })
        $btnExit.Add_Click({ $form.Close() })
        $inner.Controls.Add($btnExit)

        $footer = New-Object System.Windows.Forms.Label
        $footer.Text = $script:COPYRIGHT
        $footer.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $footer.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 120)
        $footer.Location = New-Object System.Drawing.Point(0, 490)
        $footer.Size = New-Object System.Drawing.Size(700, 20)
        $footer.TextAlign = "MiddleCenter"
        $inner.Controls.Add($footer)

        $glowTimer = New-Object System.Windows.Forms.Timer
        $glowTimer.Interval = 500
        $glowToggle = $true
        $glowTimer.Add_Tick({
            $glowToggle = -not $glowToggle
            if ($glowToggle) {
                $title.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200)
                $statusDot.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 100)
            } else {
                $title.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 150)
                $statusDot.ForeColor = [System.Drawing.Color]::FromArgb(0, 200, 80)
            }
        })
        $glowTimer.Start()

        $form.ShowDialog()
        $glowTimer.Stop()

    } catch {
        Show-ConsoleFallback
    }
}

# ============================================================
# CONSOLE FALLBACK
# ============================================================
function Show-ConsoleFallback {
    Clear-Host
    Write-Host ""
    Write-Host "  +--------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  |  SHANECODES REPAIR - NEON EDITION v$($script:VERSION)  |" -ForegroundColor Cyan
    Write-Host "  |  $($script:AUTHOR)                                      |" -ForegroundColor Gray
    Write-Host "  +--------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
    
    $sysInfo = Get-SystemInfo
    Write-Host "  [SYSTEM DIAGNOSTICS]" -ForegroundColor Yellow
    Write-Host "  OS    : $($sysInfo.OS) Build $($sysInfo.Build)" -ForegroundColor Gray
    Write-Host "  CPU   : $($sysInfo.CPU)" -ForegroundColor Gray
    Write-Host "  RAM   : $($sysInfo.RAM) GB" -ForegroundColor Gray
    Write-Host "  USER  : $($sysInfo.User) @ $($sysInfo.Computer)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "  [*] Downloading repair modules..." -ForegroundColor Yellow
    $tempBat = [System.IO.Path]::GetTempFileName() + ".bat"
    $tempBat = $tempBat -replace ".tmp", ".bat"
    
    $success = Invoke-Download -Url $script:GITHUB_RAW -OutputPath $tempBat
    
    if (-not $success -or -not (Test-Path $tempBat)) {
        Write-Host "  [X] Download failed. Please check your internet connection." -ForegroundColor Red
        Write-Host "  Contact: $($script:CONTACT)" -ForegroundColor Cyan
        Read-Host "`nPress Enter to exit"
        return
    }
    
    Write-Host "  [*] Running repair tool..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBat`"" -WindowStyle Hidden -PassThru -Wait
    
    Remove-BatchFile -Path $tempBat
    
    if ($process.ExitCode -eq 0) {
        Write-Host "  [OK] Repair completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "  [X] Repair failed. Exit Code: $($process.ExitCode)" -ForegroundColor Red
        Write-Host "  Contact: $($script:CONTACT)" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "  $($script:COPYRIGHT)" -ForegroundColor DarkGray
    Read-Host "`nPress Enter to exit"
}

# ============================================================
# ENTRY POINT
# ============================================================
try {
    if (-not (Test-Admin)) {
        try {
            $result = [System.Windows.Forms.MessageBox]::Show(
                "Administrator privileges are required.`n`nRelaunch as Administrator?",
                "Elevation Required",
                "YesNo",
                [System.Windows.Forms.MessageBoxIcon]::Warning
            )
            if ($result -eq "Yes") {
                $scriptPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $MyInvocation.InvocationName }
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
            }
        } catch {
            Write-Host "[ERROR] Administrator privileges required!" -ForegroundColor Red
            Read-Host "Press Enter to exit"
        }
        exit
    }

    Show-NeonGUI
} catch {
    Show-ConsoleFallback
}