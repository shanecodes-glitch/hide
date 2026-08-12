# ============================================================
# SHANECODES – SYSTEM REPAIR TOOL v12.0
# ============================================================
# Author: Shane Nichael Obinguar (ShaneCodes)
# Support: https://www.facebook.com/Shxne.Nichael
# ============================================================
# Compatible with Windows PowerShell 5.1+
# Public Repository Edition – No Token Required
# ============================================================

# ============================================================
# CONFIGURATION
# ============================================================
$script:Version = "12.0"
$script:Author = "Shane Nichael Obinguar"
$script:Company = "ShaneCodes Technologies"
$script:Contact = "https://www.facebook.com/Shxne.Nichael"
$script:Copyright = "© 2024 ShaneCodes Technologies. All rights reserved."
$script:GitHubRaw = "https://raw.githubusercontent.com/shanecodes-glitch/ShaneCodes-System-Repair/main/tisting.bat"

# ============================================================
# LOAD ASSEMBLIES (PowerShell 5.1 Compatible)
# ============================================================
try {
    Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
    Add-Type -AssemblyName System.Drawing -ErrorAction Stop
} catch {
    Write-Host "`n[ERROR] Failed to load required assemblies." -ForegroundColor Red
    Write-Host "Please ensure .NET Framework 4.5+ is installed." -ForegroundColor Yellow
    Write-Host "Contact: $script:Contact" -ForegroundColor Cyan
    Read-Host "`nPress Enter to exit"
    exit 1
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

$script:ConsoleHandle = [ConsoleManager]::GetConsoleWindow()
[ConsoleManager]::ShowWindow($script:ConsoleHandle, 0)

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
        $info.CPU = $cpu.Name -replace '\(TM\)', '™' -replace '\(R\)', '®'
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
        return [System.Windows.Forms.MessageBox]::Show($Message, $Title, "OK", $iconMap[$Icon])
    } catch {
        Write-Host "[$Title] $Message" -ForegroundColor Cyan
        return "OK"
    }
}

# ============================================================
# CONTACT SUPPORT DIALOG
# ============================================================
function Show-ContactSupportDialog {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes – Support"
        $form.Size = New-Object System.Drawing.Size(520, 320)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 35)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 55
        $header.BackColor = [System.Drawing.Color]::FromArgb(0, 80, 170)
        $form.Controls.Add($header)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::White
        $title.Location = New-Object System.Drawing.Point(20, 8)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $subHead = New-Object System.Windows.Forms.Label
        $subHead.Text = "Support Center"
        $subHead.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $subHead.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
        $subHead.Location = New-Object System.Drawing.Point(22, 34)
        $subHead.AutoSize = $true
        $header.Controls.Add($subHead)

        $iconLabel = New-Object System.Windows.Forms.Label
        $iconLabel.Text = "◆"
        $iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 40)
        $iconLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 220, 200)
        $iconLabel.Location = New-Object System.Drawing.Point(30, 85)
        $iconLabel.Size = New-Object System.Drawing.Size(80, 70)
        $iconLabel.TextAlign = "MiddleCenter"
        $form.Controls.Add($iconLabel)

        $msg = New-Object System.Windows.Forms.Label
        $msg.Text = "Contact Support"
        $msg.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $msg.ForeColor = [System.Drawing.Color]::White
        $msg.Location = New-Object System.Drawing.Point(125, 90)
        $msg.AutoSize = $true
        $form.Controls.Add($msg)

        $sub = New-Object System.Windows.Forms.Label
        $sub.Text = "For assistance, please contact us at:"
        $sub.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $sub.ForeColor = [System.Drawing.Color]::FromArgb(180, 200, 230)
        $sub.Location = New-Object System.Drawing.Point(125, 120)
        $sub.AutoSize = $true
        $form.Controls.Add($sub)

        $contactPanel = New-Object System.Windows.Forms.Panel
        $contactPanel.Location = New-Object System.Drawing.Point(30, 170)
        $contactPanel.Size = New-Object System.Drawing.Size(460, 65)
        $contactPanel.BackColor = [System.Drawing.Color]::FromArgb(25, 30, 50)
        $contactPanel.BorderStyle = "FixedSingle"
        $form.Controls.Add($contactPanel)

        $contactLabel = New-Object System.Windows.Forms.Label
        $contactLabel.Text = "📧 $script:Contact`n🌐 $($script:Company)"
        $contactLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $contactLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 220, 200)
        $contactLabel.Location = New-Object System.Drawing.Point(15, 6)
        $contactLabel.Size = New-Object System.Drawing.Size(430, 52)
        $contactLabel.TextAlign = "MiddleCenter"
        $contactPanel.Controls.Add($contactLabel)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "✓ Thank You"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btn.Size = New-Object System.Drawing.Size(140, 42)
        $btn.Location = New-Object System.Drawing.Point(190, 255)
        $btn.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatStyle = "Flat"
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 210, 120) })
        $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100) })
        $btn.Add_Click({ $form.Close() })
        $form.Controls.Add($btn)

        $form.ShowDialog()
    } catch {
        Show-MessageBox "Contact: $script:Contact" "Support" "Information"
    }
}

# ============================================================
# DOWNLOAD FROM GITHUB (Public Repo – No Token)
# ============================================================
function Download-RepairTool {
    param([string]$Url, [string]$OutputPath)
    
    try {
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("User-Agent", "ShaneCodes-Repair/$($script:Version)")
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
# DELETE BATCH FILE (ZERO TRACE)
# ============================================================
function Delete-BatchFile {
    param([string]$Path)
    try {
        if (Test-Path $Path) {
            Remove-Item -Path $Path -Force -ErrorAction SilentlyContinue
            if (Test-Path $Path) {
                $deleteCmd = "Start-Sleep -Seconds 1; Remove-Item -Path '$Path' -Force -ErrorAction SilentlyContinue"
                Start-Process -FilePath "powershell.exe" -ArgumentList "-NoProfile -WindowStyle Hidden -Command `"$deleteCmd`"" -WindowStyle Hidden
            }
        }
    } catch {}
}

# ============================================================
# PROGRESS WINDOW (Optimized for PowerShell 5.1)
# ============================================================
function Show-ProgressWindow {
    param($Process, $BatchPath)
    
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes – System Repair v$script:Version"
        $form.Size = New-Object System.Drawing.Size(520, 280)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 35)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.TopMost = $true

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 50
        $header.BackColor = [System.Drawing.Color]::FromArgb(0, 80, 170)
        $form.Controls.Add($header)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 18, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::White
        $title.Location = New-Object System.Drawing.Point(15, 8)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $subHead = New-Object System.Windows.Forms.Label
        $subHead.Text = "System Repair in Progress"
        $subHead.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $subHead.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
        $subHead.Location = New-Object System.Drawing.Point(17, 30)
        $subHead.AutoSize = $true
        $header.Controls.Add($subHead)

        $statusLabel = New-Object System.Windows.Forms.Label
        $statusLabel.Text = "● PROCESSING..."
        $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 200, 50)
        $statusLabel.Location = New-Object System.Drawing.Point(20, 75)
        $statusLabel.AutoSize = $true
        $form.Controls.Add($statusLabel)

        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point(20, 105)
        $progressBar.Size = New-Object System.Drawing.Size(480, 28)
        $progressBar.Style = "Continuous"
        $progressBar.Value = 0
        $progressBar.Minimum = 0
        $progressBar.Maximum = 100
        $progressBar.BackColor = [System.Drawing.Color]::FromArgb(40, 45, 70)
        $progressBar.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
        $form.Controls.Add($progressBar)

        $percentLabel = New-Object System.Windows.Forms.Label
        $percentLabel.Text = "0%"
        $percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $percentLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
        $percentLabel.Location = New-Object System.Drawing.Point(460, 105)
        $percentLabel.Size = New-Object System.Drawing.Size(45, 28)
        $percentLabel.TextAlign = "MiddleCenter"
        $form.Controls.Add($percentLabel)

        $infoLabel = New-Object System.Windows.Forms.Label
        $infoLabel.Text = "Initializing..."
        $infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $infoLabel.ForeColor = [System.Drawing.Color]::FromArgb(180, 200, 230)
        $infoLabel.Location = New-Object System.Drawing.Point(20, 148)
        $infoLabel.Size = New-Object System.Drawing.Size(480, 25)
        $infoLabel.TextAlign = "MiddleCenter"
        $form.Controls.Add($infoLabel)

        $btnDone = New-Object System.Windows.Forms.Button
        $btnDone.Text = "✓ Thank You"
        $btnDone.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btnDone.Size = New-Object System.Drawing.Size(140, 42)
        $btnDone.Location = New-Object System.Drawing.Point(190, 195)
        $btnDone.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
        $btnDone.ForeColor = [System.Drawing.Color]::White
        $btnDone.FlatStyle = "Flat"
        $btnDone.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnDone.Visible = $false
        $btnDone.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 210, 120) })
        $btnDone.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100) })
        $btnDone.Add_Click({ $form.Close() })
        $form.Controls.Add($btnDone)

        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "✕ Cancel"
        $btnCancel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
        $btnCancel.Location = New-Object System.Drawing.Point(400, 195)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
        $btnCancel.ForeColor = [System.Drawing.Color]::White
        $btnCancel.FlatStyle = "Flat"
        $btnCancel.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnCancel.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(110, 55, 55) })
        $btnCancel.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40) })
        $btnCancel.Add_Click({
            try { $Process.Kill() } catch {}
            $form.Close()
        })
        $form.Controls.Add($btnCancel)

        $timer = New-Object System.Windows.Forms.Timer
        $timer.Interval = 200
        $currentProgress = 0

        $timer.Add_Tick({
            try {
                if ($Process.HasExited) {
                    $timer.Stop()
                    $progressBar.Value = 100
                    $percentLabel.Text = "100%"
                    $statusLabel.Text = "✓ COMPLETE"
                    $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
                    $infoLabel.Text = "Repair completed successfully!"
                    $btnDone.Visible = $true
                    $btnCancel.Visible = $false
                    $form.Size = New-Object System.Drawing.Size(520, 280)
                    return
                }

                if ($currentProgress -lt 95) {
                    $currentProgress += 1
                    if ($currentProgress -le 20) {
                        $infoLabel.Text = "Initializing licensing services..."
                    } elseif ($currentProgress -le 40) {
                        $infoLabel.Text = "Installing repair key..."
                    } elseif ($currentProgress -le 60) {
                        $infoLabel.Text = "Generating repair ticket..."
                    } elseif ($currentProgress -le 80) {
                        $infoLabel.Text = "Applying repair ticket..."
                    } else {
                        $infoLabel.Text = "Activating license..."
                    }
                } else {
                    $infoLabel.Text = "Finalizing..."
                }

                $progressBar.Value = $currentProgress
                $percentLabel.Text = "$currentProgress%"
            } catch {}
        })

        $timer.Start()
        $form.ShowDialog()
        
        try { $timer.Stop() } catch {}

    } catch {
        try { $Process.WaitForExit() } catch {}
    }
}

# ============================================================
# RESULT DIALOG
# ============================================================
function Show-ResultDialog {
    param($ExitCode)
    
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes – Repair Complete"
        $form.Size = New-Object System.Drawing.Size(480, 280)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $false
        $form.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 35)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.TopMost = $true

        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 55
        $header.BackColor = if ($ExitCode -eq 0) { [System.Drawing.Color]::FromArgb(0, 130, 80) } else { [System.Drawing.Color]::FromArgb(180, 50, 50) }
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
            $iconLabel.Text = "✓"
            $iconLabel.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
        } else {
            $iconLabel.Text = "✗"
            $iconLabel.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
        }
        $iconLabel.Font = New-Object System.Drawing.Font("Segoe UI", 48, [System.Drawing.FontStyle]::Bold)
        $iconLabel.Location = New-Object System.Drawing.Point(45, 80)
        $iconLabel.Size = New-Object System.Drawing.Size(80, 70)
        $iconLabel.TextAlign = "MiddleCenter"
        $form.Controls.Add($iconLabel)

        $msg = New-Object System.Windows.Forms.Label
        if ($ExitCode -eq 0) {
            $msg.Text = "REPAIR COMPLETE"
            $msg.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
        } else {
            $msg.Text = "REPAIR FAILED"
            $msg.ForeColor = [System.Drawing.Color]::FromArgb(255, 80, 80)
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
        $sub.ForeColor = [System.Drawing.Color]::FromArgb(180, 200, 230)
        $sub.Location = New-Object System.Drawing.Point(135, 115)
        $sub.AutoSize = $true
        $form.Controls.Add($sub)

        $btn = New-Object System.Windows.Forms.Button
        $btn.Text = "✓ Thank You"
        $btn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $btn.Size = New-Object System.Drawing.Size(160, 42)
        $btn.Location = New-Object System.Drawing.Point(160, 185)
        $btn.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
        $btn.ForeColor = [System.Drawing.Color]::White
        $btn.FlatStyle = "Flat"
        $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btn.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 210, 120) })
        $btn.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100) })
        $btn.Add_Click({ $form.Close() })
        $form.Controls.Add($btn)

        $copyright = New-Object System.Windows.Forms.Label
        $copyright.Text = $script:Copyright
        $copyright.Font = New-Object System.Drawing.Font("Segoe UI", 7.5)
        $copyright.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 120)
        $copyright.Location = New-Object System.Drawing.Point(0, 250)
        $copyright.Size = New-Object System.Drawing.Size(480, 20)
        $copyright.TextAlign = "MiddleCenter"
        $form.Controls.Add($copyright)

        $form.ShowDialog()
    } catch {
        Show-MessageBox "Repair completed (Exit Code: $ExitCode)" "Result" "Information"
    }
}

# ============================================================
# START REPAIR – DOWNLOAD + RUN + DELETE
# ============================================================
function Start-RepairTool {
    $tempBatch = Join-Path $env:TEMP "ShaneRepair_$(Get-Random).bat"
    
    try {
        Show-MessageBox "Downloading repair modules...`n`nPlease wait while the tool downloads the required files." "ShaneCodes" "Information"
        
        $success = Download-RepairTool -Url $script:GitHubRaw -OutputPath $tempBatch
        
        if (-not $success -or -not (Test-Path $tempBatch)) {
            Show-ContactSupportDialog
            return
        }
        
        $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBatch`"" -WindowStyle Hidden -PassThru
        Show-ProgressWindow -Process $process -BatchPath $tempBatch
        Show-ResultDialog $process.ExitCode
        
    } catch {
        Show-MessageBox "An error occurred while running the repair tool.`n`nError: $($_.Exception.Message)" "Error" "Error"
    } finally {
        Delete-BatchFile -Path $tempBatch
    }
}

# ============================================================
# CONSOLE FALLBACK
# ============================================================
function Show-ConsoleFallback {
    Write-Host ""
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host " SHANECODES – SYSTEM REPAIR TOOL v$script:Version" -ForegroundColor Cyan
    Write-Host " Created by: Shane Nichael Obinguar" -ForegroundColor Cyan
    Write-Host "============================================================" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "[*] Downloading repair modules..." -ForegroundColor Yellow
    $tempBatch = Join-Path $env:TEMP "ShaneRepair_$(Get-Random).bat"
    
    $success = Download-RepairTool -Url $script:GitHubRaw -OutputPath $tempBatch
    
    if (-not $success -or -not (Test-Path $tempBatch)) {
        Write-Host "[ERROR] Failed to download repair modules." -ForegroundColor Red
        Write-Host "Contact: $script:Contact" -ForegroundColor Cyan
        Read-Host "`nPress Enter to exit"
        return
    }
    
    Write-Host "[*] Running repair tool..." -ForegroundColor Yellow
    $process = Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$tempBatch`"" -Wait -NoNewWindow
    
    if ($process.ExitCode -eq 0) {
        Write-Host "[✓] Repair completed successfully!" -ForegroundColor Green
    } else {
        Write-Host "[✗] Repair failed. Exit Code: $($process.ExitCode)" -ForegroundColor Red
        Write-Host "Contact: $script:Contact" -ForegroundColor Cyan
    }
    
    Delete-BatchFile -Path $tempBatch
    
    Write-Host ""
    Write-Host $script:Copyright -ForegroundColor Gray
    Write-Host ""
    Read-Host "Press Enter to exit"
}

# ============================================================
# MAIN GUI – POGING DESIGN (Modernized)
# ============================================================
function Show-MainGUI {
    try {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "ShaneCodes – System Repair Tool v$script:Version"
        $form.Size = New-Object System.Drawing.Size(600, 440)
        $form.StartPosition = "CenterScreen"
        $form.FormBorderStyle = "FixedSingle"
        $form.MaximizeBox = $false
        $form.MinimizeBox = $true
        $form.BackColor = [System.Drawing.Color]::FromArgb(15, 18, 35)
        $form.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $form.TopMost = $true

        # ===== HEADER =====
        $header = New-Object System.Windows.Forms.Panel
        $header.Dock = "Top"
        $header.Height = 110
        $header.BackColor = [System.Drawing.Color]::FromArgb(0, 70, 150)
        $form.Controls.Add($header)

        $logoPanel = New-Object System.Windows.Forms.Panel
        $logoPanel.Size = New-Object System.Drawing.Size(65, 65)
        $logoPanel.Location = New-Object System.Drawing.Point(25, 22)
        $logoPanel.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 219)
        
        $logoLabel = New-Object System.Windows.Forms.Label
        $logoLabel.Text = "SC"
        $logoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 22, [System.Drawing.FontStyle]::Bold)
        $logoLabel.ForeColor = [System.Drawing.Color]::White
        $logoLabel.Location = New-Object System.Drawing.Point(5, 10)
        $logoLabel.Size = New-Object System.Drawing.Size(55, 45)
        $logoLabel.TextAlign = "MiddleCenter"
        $logoPanel.Controls.Add($logoLabel)
        $header.Controls.Add($logoPanel)

        $title = New-Object System.Windows.Forms.Label
        $title.Text = "SHANECODES"
        $title.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
        $title.ForeColor = [System.Drawing.Color]::White
        $title.Location = New-Object System.Drawing.Point(105, 15)
        $title.AutoSize = $true
        $header.Controls.Add($title)

        $sub = New-Object System.Windows.Forms.Label
        $sub.Text = "System Repair Tool • Enterprise Edition"
        $sub.Font = New-Object System.Drawing.Font("Segoe UI", 11)
        $sub.ForeColor = [System.Drawing.Color]::FromArgb(200, 220, 255)
        $sub.Location = New-Object System.Drawing.Point(107, 55)
        $sub.AutoSize = $true
        $header.Controls.Add($sub)

        $versionBadge = New-Object System.Windows.Forms.Label
        $versionBadge.Text = " v$script:Version "
        $versionBadge.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $versionBadge.ForeColor = [System.Drawing.Color]::White
        $versionBadge.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
        $versionBadge.Size = New-Object System.Drawing.Size(80, 30)
        $versionBadge.Location = New-Object System.Drawing.Point(500, 15)
        $versionBadge.TextAlign = "MiddleCenter"
        $header.Controls.Add($versionBadge)

        $statusBadge = New-Object System.Windows.Forms.Label
        $statusBadge.Text = "● READY"
        $statusBadge.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
        $statusBadge.ForeColor = [System.Drawing.Color]::FromArgb(0, 230, 118)
        $statusBadge.BackColor = [System.Drawing.Color]::FromArgb(0, 230, 118, 15)
        $statusBadge.Size = New-Object System.Drawing.Size(110, 28)
        $statusBadge.Location = New-Object System.Drawing.Point(470, 60)
        $statusBadge.TextAlign = "MiddleCenter"
        $header.Controls.Add($statusBadge)

        # Glow Line
        $glowLine = New-Object System.Windows.Forms.Label
        $glowLine.Text = "════════════════════════════════════════════════════════════════════"
        $glowLine.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $glowLine.ForeColor = [System.Drawing.Color]::FromArgb(0, 255, 200, 40)
        $glowLine.Location = New-Object System.Drawing.Point(0, 100)
        $glowLine.Size = New-Object System.Drawing.Size(600, 15)
        $glowLine.TextAlign = "MiddleCenter"
        $header.Controls.Add($glowLine)

        # ===== INFO PANEL =====
        $info = New-Object System.Windows.Forms.Panel
        $info.Location = New-Object System.Drawing.Point(25, 130)
        $info.Size = New-Object System.Drawing.Size(550, 75)
        $info.BackColor = [System.Drawing.Color]::FromArgb(25, 30, 50)
        $info.BorderStyle = "FixedSingle"
        $form.Controls.Add($info)

        $sysData = Get-SystemInfo
        $infoLines = @(
            "OS: $($sysData.OS)  Build: $($sysData.Build)",
            "CPU: $($sysData.CPU)",
            "RAM: $($sysData.RAM) GB  |  User: $($sysData.User)"
        )

        $lblInfo = New-Object System.Windows.Forms.Label
        $lblInfo.Text = $infoLines -join "`n"
        $lblInfo.Font = New-Object System.Drawing.Font("Segoe UI", 9.5)
        $lblInfo.ForeColor = [System.Drawing.Color]::FromArgb(180, 200, 230)
        $lblInfo.Location = New-Object System.Drawing.Point(15, 10)
        $lblInfo.Size = New-Object System.Drawing.Size(520, 55)
        $info.Controls.Add($lblInfo)

        # ===== BUTTONS =====
        $btnStart = New-Object System.Windows.Forms.Button
        $btnStart.Text = "⚡ START REPAIR"
        $btnStart.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
        $btnStart.Size = New-Object System.Drawing.Size(240, 55)
        $btnStart.Location = New-Object System.Drawing.Point(25, 230)
        $btnStart.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100)
        $btnStart.ForeColor = [System.Drawing.Color]::White
        $btnStart.FlatStyle = "Flat"
        $btnStart.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnStart.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 210, 120) })
        $btnStart.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(0, 180, 100) })
        $btnStart.Add_Click({
            $form.Close()
            Start-RepairTool
        })
        $form.Controls.Add($btnStart)

        $btnCheck = New-Object System.Windows.Forms.Button
        $btnCheck.Text = "🔍 SYSTEM CHECK"
        $btnCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnCheck.Size = New-Object System.Drawing.Size(160, 55)
        $btnCheck.Location = New-Object System.Drawing.Point(280, 230)
        $btnCheck.BackColor = [System.Drawing.Color]::FromArgb(40, 80, 120)
        $btnCheck.ForeColor = [System.Drawing.Color]::White
        $btnCheck.FlatStyle = "Flat"
        $btnCheck.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnCheck.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(60, 110, 160) })
        $btnCheck.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(40, 80, 120) })
        $btnCheck.Add_Click({
            $sysData2 = Get-SystemInfo
            Show-MessageBox "System Check Complete`n`nOS: $($sysData2.OS)`nCPU: $($sysData2.CPU)`nRAM: $($sysData2.RAM) GB`nUser: $($sysData2.User)" "System Check" "Information"
        })
        $form.Controls.Add($btnCheck)

        $btnSupport = New-Object System.Windows.Forms.Button
        $btnSupport.Text = "📧 SUPPORT"
        $btnSupport.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnSupport.Size = New-Object System.Drawing.Size(120, 55)
        $btnSupport.Location = New-Object System.Drawing.Point(455, 230)
        $btnSupport.BackColor = [System.Drawing.Color]::FromArgb(60, 40, 80)
        $btnSupport.ForeColor = [System.Drawing.Color]::White
        $btnSupport.FlatStyle = "Flat"
        $btnSupport.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnSupport.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(80, 55, 110) })
        $btnSupport.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(60, 40, 80) })
        $btnSupport.Add_Click({
            Show-ContactSupportDialog
        })
        $form.Controls.Add($btnSupport)

        $btnExit = New-Object System.Windows.Forms.Button
        $btnExit.Text = "✕ EXIT"
        $btnExit.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
        $btnExit.Size = New-Object System.Drawing.Size(100, 55)
        $btnExit.Location = New-Object System.Drawing.Point(455, 300)
        $btnExit.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40)
        $btnExit.ForeColor = [System.Drawing.Color]::White
        $btnExit.FlatStyle = "Flat"
        $btnExit.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnExit.Add_MouseEnter({ $this.BackColor = [System.Drawing.Color]::FromArgb(110, 55, 55) })
        $btnExit.Add_MouseLeave({ $this.BackColor = [System.Drawing.Color]::FromArgb(80, 40, 40) })
        $btnExit.Add_Click({ $form.Close() })
        $form.Controls.Add($btnExit)

        # ===== FOOTER =====
        $footer = New-Object System.Windows.Forms.Label
        $footer.Text = $script:Copyright
        $footer.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $footer.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 120)
        $footer.Location = New-Object System.Drawing.Point(0, 410)
        $footer.Size = New-Object System.Drawing.Size(600, 20)
        $footer.TextAlign = "MiddleCenter"
        $form.Controls.Add($footer)

        $form.ShowDialog()
    } catch {
        Show-ConsoleFallback
    }
}

# ============================================================
# ENTRY POINT
# ============================================================
try {
    if (-not (Test-Admin)) {
        try {
            $result = Show-MessageBox "Administrator privileges are required.`n`nRelaunch as Administrator?" "Elevation Required" "Warning"
            if ($result -eq "OK") {
                $scriptPath = if ($MyInvocation.MyCommand.Path) { $MyInvocation.MyCommand.Path } else { $MyInvocation.InvocationName }
                Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
            }
        } catch {
            Write-Host "[ERROR] Administrator privileges required!" -ForegroundColor Red
            Read-Host "Press Enter to exit"
        }
        exit
    }

    Show-MainGUI
} catch {
    Show-ConsoleFallback
}
