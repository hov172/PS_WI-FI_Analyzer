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

- **Hybrid Startup System**: Guided Setup for beginners, Quick Start for pros
- **Automated Requirement Detection**: Location services, WiFi adapter, step-by-step guidance
- **Network Discovery**: Scan all accessible WiFi networks
- **Signal Analysis**: Color-coded signal strength (Strong, Medium, Weak)
- **Security Assessment**: WPA3, WPA2, WPA, Open detection
- **Channel Congestion Analysis**: Interference detection and recommendations
- **Performance Testing**: Speed test with fallback servers
- **Report Generation**: Export HTML/CSV with all fields
- **Location Tracking**: Building and room number fields
- **Preference Memory**: Remembers startup choice
- **Command Line Support**: Advanced parameters for power users

## 📦 Installation

### PowerShell Gallery
```powershell
Install-Module -Name WiFiAnalyzer -Scope CurrentUser -Force
```

### GitHub
```powershell
git clone https://github.com/hov172/PS_WI-FI_Analyzer.git
cd PS_WI-FI_Analyzer
.\WiFiAnalyzerNew.ps1
```

## 🚀 Quick Start

```powershell
Import-Module WiFiAnalyzer
Start-WiFiAnalyzer
Start-WiFiAnalyzer -QuickStart
Start-WiFiAnalyzerAll -SkipReportInfo
```

## 🛠️ Commands & Parameters

| Command                  | Description                                      |
|--------------------------|--------------------------------------------------|
| Start-WiFiAnalyzerAll    | Full analysis and report from CLI                |
| Start-WiFiAnalyzer       | Launch GUI with startup options                  |
| Start-GuidedSetup        | Guided setup walkthrough                         |
| Start-QuickStart         | Quick start mode                                 |
| Show-WiFiAnalyzerGUI     | Show main GUI form (alias)                       |
| Show-StartupChoiceDialog | Show startup choice dialog                       |
| Show-WiFiReportInfoForm  | Show report info form                            |
| Get-WiFiScan             | Scan for WiFi networks                           |
| Get-MACAddress           | Get WiFi adapter MAC address                     |
| Get-ConnectedSSID        | Get current WiFi connection info                 |
| Get-ComputerInfoExtras   | Get computer name and IP address                 |
| Test-ChannelCongestion   | Analyze channel congestion                       |
| Get-BestChannel          | Recommend best channels                          |
| Export-WiFiReport        | Export analysis report (HTML/CSV)                |

### Key Parameters

- `-QuickStart`: Skip setup dialogs
- `-Debug`: Enable diagnostic output
- `-OutputFormat`: 'HTML' or 'CSV'
- `-OutputPath`: Custom report path
- `-SkipReportInfo`: Skip user info prompts

## 📋 Example Usage

```powershell
# Launch GUI
Start-WiFiAnalyzer

# Quick Start
Start-WiFiAnalyzer -QuickStart

# Full CLI analysis
Start-WiFiAnalyzerAll -OutputFormat HTML -SkipReportInfo

# Export report
$networks = Get-WiFiScan
Export-WiFiReport -networks $networks -OutputFormat CSV -SkipReportInfo

# Get recommendations
$recommendations = Get-BestChannel -networks $networks
Write-Host "Best 2.4GHz: $($recommendations.'2.4GHz')"
Write-Host "Best 5GHz: $($recommendations.'5GHz')"

# Get current connection info
Get-ConnectedSSID

# Get computer info
Get-ComputerInfoExtras

# Analyze channel congestion
Test-ChannelCongestion -networks $networks
```

## 🏢 Location Tracking

- Collects building and room number for IT support
- All reports include location fields

## 📄 Report Fields

- User info: Name, ID, Email, Phone, Building, Room Number
- System info: Computer name, IP, MAC, connected SSID/BSSID
- Network analysis: All detected networks
- Performance: Speed test, latency
- Recommendations: Best channels, congestion scores

## 🎨 Color & Layout

- Signal strength: Green (Strong), Orange (Medium), Red (Weak)
- Security: Green (WPA3), Blue (WPA2), Orange (WPA), Red (Open)
- GUI and report use consistent color palette
- Connected network highlighted in report and CSV

## 📝 Troubleshooting

- Location services required for scanning
- Run PowerShell as admin for full access
- Use `-Scope CurrentUser` if install fails
- See [PowerShell Gallery](https://www.powershellgallery.com/packages/WiFiAnalyzer) for updates

## 👤 Author

**Jesus Ayala** - [Ayala Solutions](https://github.com/hov172)

---

Made with ❤️ for better WiFi connectivity
