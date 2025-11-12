# 📡 WiFi Analyzer - Hybrid Startup Edition

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/hov172/PS_WI-FI_Analyzer/graphs/commit-activity)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/WiFiAnalyzer.svg)](https://www.powershellgallery.com/packages/WiFiAnalyzer)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/WiFiAnalyzer.svg)](https://www.powershellgallery.com/packages/WiFiAnalyzer)

> A comprehensive WiFi analyzer with intelligent hybrid startup capabilities for diagnosing wireless network issues and optimizing performance. Available as both a PowerShell module and standalone script.

![WiFi Analyzer Guided Setup](https://github.com/user-attachments/assets/c9d1b192-5aab-4ede-8925-83db7d72d1cc)

## 🌟 Features

### Hybrid Startup System
- **Guided Setup**: Step-by-step system requirement checks with automatic fixes
- **Quick Start**: Skip validation and go straight to scanning
- **Preference Memory**: Remembers your startup choice for next time

### Network Analysis
- **Comprehensive Scanning**: Detect all nearby WiFi networks (2.4 GHz & 5 GHz)
- **Signal Strength Analysis**: Color-coded visualization (Strong/Medium/Weak)
- **Security Assessment**: WPA3, WPA2, WPA, and Open network detection
- **Channel Congestion**: Analyze interference and get recommendations
- **Connected Network Info**: Shows current SSID, BSSID, and channel

### Performance Testing
- **Download Speed Test**: Measures actual download throughput
- **Upload Speed Test**: Tests upload performance
- **Latency Measurement**: Multi-server ping with fallback
- **Intelligent Fallbacks**: Multiple test servers for reliability

### System Requirements Detection
- **Location Services**: Automatically checks Windows location permissions
- **WiFi Adapter**: Verifies adapter presence and active status
- **Admin Rights**: Detects privilege level with warnings

### Report Generation
- **Multiple Formats**: Export to TXT, HTML, or CSV
- **Complete Information**: System info, network data, speed tests, recommendations
- **Location Tracking**: Building and room number fields for IT support
- **User Information**: Name, ID, email, phone fields

## 📦 Installation

### Standalone Script (Recommended)
```powershell
# Download the script
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/hov172/PS_WI-FI_Analyzer/main/WiFiAnalyzerNew.ps1" -OutFile "WiFiAnalyzer.ps1"

# Run with default (interactive startup)
.\WiFiAnalyzer.ps1

# Run with Quick Start
.\WiFiAnalyzer.ps1 -QuickStart
```

### Requirements
- Windows 10/11
- PowerShell 5.1 or higher
- WiFi adapter
- Location services enabled (for network scanning)

## 🚀 Quick Start

### Interactive Mode (Default)
```powershell
.\wi_fi_analyzer_best_practices_edition.ps1
```
Presents a startup dialog where you can choose:
- **Guided Setup**: Checks system requirements and helps fix issues
- **Quick Start**: Skips validation and starts scanning immediately

### Command Line Options
```powershell
# Skip setup dialog and validation
.\WiFiAnalyzerNew.ps1-QuickStart

# Alias for QuickStart
.\WiFiAnalyzerNew.ps1-SkipPreflightCheck

# Enable verbose diagnostics
.\WiFiAnalyzerNew.ps1-Verbose

# Combine options
.\WiFiAnalyzerNew.ps1-QuickStart -Verbose
```

## 🛠️ Core Functions

### Network Scanning
```powershell
Get-WiFiScan              # Scan all nearby networks
Get-ConnectedSSID         # Get current connection (SSID, BSSID, Channel)
Get-MACAddress            # Get WiFi adapter MAC address
Get-ComputerInfoExtras    # Get computer name and IP address
```

### Analysis & Recommendations
```powershell
Test-ChannelCongestion    # Analyze channel interference
Get-BestChannel           # Get channel recommendations
Get-SignalColor           # Get signal quality rating
Get-SecurityColor         # Get security level rating
```

### Performance Testing
```powershell
Test-NetworkSpeed         # Run download/upload speed test and latency check
```

### System Validation
```powershell
Test-Prerequisites        # Check location services, WiFi adapter, admin rights
```

### Export & Reporting
```powershell
Export-WiFiReport         # Export analysis to TXT/HTML/CSV
```

## 📋 Usage Examples

### Basic GUI Usage
1. Launch the script (double-click or run in PowerShell)
2. Choose startup option (Guided or Quick)
3. Click **Scan Wi-Fi** to analyze networks
4. Review results: system info, speed test, nearby networks, congestion analysis
5. Click **Export** to save report with your information

### Advanced CLI Usage
```powershell
# Use the all-in-one automation function
Invoke-WiFiAnalyzerAll -OutputFormat HTML -SkipReportInfo

# Scan networks programmatically
$networks = Get-WiFiScan
$networks | Format-Table SSID, Signal, Channel, Security, Band

# Get recommendations
$best = Get-BestChannel -networks $networks
Write-Host "Best 2.4 GHz Channel: $($best.'2.4GHz')"
Write-Host "Best 5 GHz Channel: $($best.'5GHz')"

# Check current connection
$connection = Get-ConnectedSSID
Write-Host "Connected to: $($connection.SSID) on Channel $($connection.Channel)"

# Run speed test
$speed = Test-NetworkSpeed
Write-Host "Download: $($speed.DownloadSpeed) Mbps"
Write-Host "Upload: $($speed.UploadSpeed) Mbps"
Write-Host "Latency: $($speed.Latency) ms"
```

## 📊 Report Output

### System Information
- Computer Name
- IP Address
- WiFi MAC Address
- Connected SSID & BSSID
- Connected Channel
- Download Speed (Mbps)
- Upload Speed (Mbps)
- Latency (ms)

### Network List
- SSID (with [*] marker for connected network)
- Signal Strength (%)
- Channel
- Security Type
- Signal Quality (Strong/Medium/Weak)
- Band (2.4 GHz / 5 GHz)
- Channel Width

### Analysis
- Channel Congestion Scores (per channel)
- Congestion Levels (Low/Medium/High)
- Recommended Channels for 2.4 GHz and 5 GHz bands

### User Information (Export)
- Name
- ID Number
- Email Address
- Telephone Number
- Building
- Room Number

## 🎨 Color Coding

### Signal Strength
- 🟢 **Green (Strong)**: ≥70% signal
- 🟠 **Orange (Medium)**: 40-69% signal  
- 🔴 **Red (Weak)**: <40% signal

### Security
- 🟢 **Green**: WPA3
- 🔵 **Blue**: WPA2
- 🟠 **Orange**: WPA
- 🔴 **Red**: Open (No security)

### Congestion Levels
- **Low**: Score <75
- **Medium**: Score 75-150
- **High**: Score >150

## 📝 Troubleshooting

### "Location services not enabled" Error
1. Click **Yes** in the guided setup to open Settings
2. Navigate to **Privacy & security > Location**
3. Enable **Location services**
4. Return to the script and click **OK** to recheck

### "No Wi-Fi adapter found" Error
- Verify WiFi adapter is enabled in Device Manager
- Check that WiFi is turned on in Windows settings
- Restart the script after enabling

### "Wi-Fi adapter found but not active" Warning
- Connect to any WiFi network
- Or enable the WiFi adapter in Network Settings
- Click to rescan

### Script Won't Launch (STA Thread Error)
- The script automatically relaunches in STA mode for GUI
- If issues persist, manually run: `powershell.exe -STA -File .\WiFiAnalyzerNew.ps1`

### Speed Test Fails
- Speed tests may be blocked on restricted networks (schools, corporate)
- The script will still show latency if basic connectivity works
- Results marked as "Partial" when download/upload tests fail

## 🔧 Advanced Configuration

### Preference Storage
Your startup choice is saved in:
```
%APPDATA%\WiFiAnalyzer_Preference.txt
```
Delete this file to reset and show the startup dialog again.

### WhatIf/Confirm Support
```powershell
# Preview what would be exported without actually creating file
Export-WiFiReport -Networks $networks -WhatIf

# Require confirmation before export
Export-WiFiReport -Networks $networks -Confirm
```

### Custom Output Path
```powershell
# Export to specific folder
Invoke-WiFiAnalyzerAll -OutputPath "C:\Reports" -OutputFormat HTML
```

## 🏗️ Architecture

- **[CmdletBinding(SupportsShouldProcess)]**: Full `-WhatIf` and `-Confirm` support
- **Strict Mode**: `Set-StrictMode -Version Latest` for error prevention
- **Error Handling**: Comprehensive try-catch with graceful degradation
- **STA Thread**: Automatic relaunch for Windows Forms GUI
- **State Management**: Consolidated `$app` object for clean scoping
- **Resource Cleanup**: Proper disposal of WebClient and temp files

## 📜 Parameters Reference

| Parameter           | Type     | Description                                   |
|---------------------|----------|-----------------------------------------------|
| `-QuickStart`       | Switch   | Skip guided setup and validation              |
| `-SkipPreflightCheck` | Switch | Alias for `-QuickStart`                       |
| `-Verbose`          | Switch   | Show detailed diagnostic messages             |
| `-WhatIf`           | Switch   | Preview actions without executing             |
| `-Confirm`          | Switch   | Prompt before each action                     |

## 👤 Author

**Jesus Ayala** — Sarah Lawrence College  
[GitHub](https://github.com/hov172) | [Ayala Solutions](https://github.com/hov172)

## 📄 License

MIT License - See LICENSE file for details

---

Made with ❤️ for better WiFi connectivity

## 🆘 Support

For issues, questions, or contributions:
- 📧 Email support: [Contact IT]
- 🐛 Report bugs: [GitHub Issues](https://github.com/hov172/PS_WI-FI_Analyzer/issues)
- 💡 Feature requests: [GitHub Discussions](https://github.com/hov172/PS_WI-FI_Analyzer/discussions)
