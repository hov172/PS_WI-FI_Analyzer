# 📡 WiFi Analyzer - Hybrid Startup Edition

[![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue.svg)](https://github.com/PowerShell/PowerShell)
[![Platform](https://img.shields.io/badge/Platform-Windows-lightgrey.svg)](https://www.microsoft.com/windows)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/hov172/PS_WI-FI_Analyzer/graphs/commit-activity)
[![PowerShell Gallery](https://img.shields.io/powershellgallery/v/WiFiAnalyzer.svg)](https://www.powershellgallery.com/packages/WiFiAnalyzer)
[![PowerShell Gallery Downloads](https://img.shields.io/powershellgallery/dt/WiFiAnalyzer.svg)](https://www.powershellgallery.com/packages/WiFiAnalyzer)

> A comprehensive WiFi analyzer with intelligent hybrid startup capabilities for diagnosing wireless network issues and optimizing performance. Available as both a PowerShell module and standalone script.

![WiFi Analyzer Guided Setup](https://github.com/user-attachments/assets/cc474cc5-8751-4c9b-9d40-476c3dfcda27)

## 🌟 Features

- **🎯 Hybrid Startup System** - Intelligent choice between Guided Setup for beginners and Quick Start for experienced users
- **🔍 Automated Requirement Detection** - Checks location services, WiFi adapters, and provides step-by-step guidance
- **📶 Network Discovery** - Comprehensive scanning of all accessible WiFi networks
- **📊 Signal Analysis** - Color-coded signal strength categories (Strong, Medium, Weak)
- **🔒 Security Assessment** - Identifies protocols (WPA3, WPA2, WPA, Open) with vulnerability warnings
- **📡 Channel Congestion Analysis** - Sophisticated algorithm for interference detection
- **⚡ Performance Testing** - Network speed tests with multiple fallback servers
- **📄 Report Generation** - Comprehensive exportable reports
- **🏢 Location Tracking** - Building and room number fields for IT support
- **💾 Preference Memory** - Remembers user startup preference
- **⌨️ Command Line Support** - Advanced parameters for power users

## 📸 Screenshots

<details>
<summary>Click to view screenshots</summary>

### Main Interface
![Main Interface](https://github.com/user-attachments/assets/ec392510-f839-4b45-9c22-ddeffb8309fb)

### Network Analysis
![Network Analysis](https://github.com/user-attachments/assets/d83236a6-03eb-40c4-8b54-5c497d1c7850)

### Detailed Report
![Detailed Report](https://github.com/user-attachments/assets/1d050260-5854-43a4-bc93-e2e30ca88d9e)

### Export Options
![Export Options](https://github.com/user-attachments/assets/214b3608-41ae-44fb-b1b7-e2ed7f1abc60)

</details>

## 🔗 Related Projects

- **Windows App**: [WinWiFiAnalyzer](https://github.com/hov172/WinWiFiAnalyzer/tree/main)
- **macOS App**: [WifiDiagReport](https://github.com/hov172/WifDiagReport)

## 📦 Installation Methods

### Method 1: PowerShell Gallery (Recommended)

Install the WiFiAnalyzer module directly from PowerShell Gallery:

```powershell
# Install for all users (requires admin)
Install-Module -Name WiFiAnalyzer -Scope AllUsers -Force

# Install for current user only (no admin required)
Install-Module -Name WiFiAnalyzer -Scope CurrentUser -Force

# Verify installation
Get-Module -Name WiFiAnalyzer -ListAvailable
```

**Using PowerShellGet v3 (PSResourceGet):**

```powershell
# Install using the newer PSResourceGet module
Install-PSResource -Name WiFiAnalyzer
```

### Method 2: Manual Installation (GitHub)

Clone or download the repository:

```powershell
# Clone the repository
git clone https://github.com/hov172/PS_WI-FI_Analyzer.git
cd PS_WI-FI_Analyzer

# Run the script directly
.\WiFiAnalyzerNew.ps1
```

### Method 3: Direct Download

1. Download the latest `.nupkg` file from [PowerShell Gallery](https://www.powershellgallery.com/packages/WiFiAnalyzer)
2. Extract the package to your PowerShell modules directory
3. Import the module: `Import-Module WiFiAnalyzer`

## 🚀 Quick Start

### Using the PowerShell Module

Once installed, you can use the module commands:

```powershell
# Import the module
Import-Module WiFiAnalyzer

# Start the WiFi Analyzer GUI
Start-WiFiAnalyzer

# Run with Quick Start mode
Start-WiFiAnalyzer -QuickStart

# Enable debug mode
Start-WiFiAnalyzer -Debug

# Get help on available commands
Get-Command -Module WiFiAnalyzer
Get-Help Start-WiFiAnalyzer -Full
```

### Module Commands

The WiFiAnalyzer module provides the following cmdlets (all using approved PowerShell verbs):

| Command | Description |
|---------|-------------|
| `Start-WiFiAnalyzer` | Launch the main GUI application with startup options |
| `Start-WiFiAnalyzerDirect` | Launch GUI directly (skip startup dialogs) |
| `Get-WiFiScan` | Scan for nearby WiFi networks |
| `Get-MACAddress` | Get the MAC address of your WiFi adapter |
| `Get-ConnectedSSID` | Get info about current WiFi connection |
| `Get-ComputerInfoExtras` | Get computer name and IP address |
| `Test-ChannelCongestion` | Analyze channel congestion levels |
| `Get-BestChannel` | Get channel recommendations for 2.4GHz and 5GHz |
| `Test-NetworkSpeed` | Perform network latency test |
| `Export-WiFiReport` | Generate and save WiFi analysis report (HTML/CSV) |
| `Invoke-WiFiAnalyzerAll` | Run complete analysis and export report from CLI |
| `Start-GuidedSetup` | Launch guided setup walkthrough |
| `Start-QuickStart` | Launch quick start mode |
| `Show-MainWiFiAnalyzerForm` | Show main GUI form directly |
| `Show-StartupChoiceDialog` | Show startup choice dialog |
| `Show-ExportInfoForm` | Show export report info form |

### Command Parameters & Switches

#### Start-WiFiAnalyzer
| Parameter | Type | Description |
|-----------|------|-------------|
| `-QuickStart` | switch | Skip all startup dialogs and launch directly |
| `-SkipPreflightCheck` | switch | Alias for QuickStart |

**Example:**
```powershell
Start-WiFiAnalyzer -QuickStart
```

#### Invoke-WiFiAnalyzerAll
| Parameter | Type | Description |
|-----------|------|-------------|
| `-OutputFormat` | string | 'HTML' or 'CSV' (default: 'HTML') |
| `-OutputPath` | string | Path to save report (optional, defaults to Documents) |
| `-SkipReportInfo` | switch | Skip user info prompts |

**Example:**
```powershell
Invoke-WiFiAnalyzerAll -SkipReportInfo
Invoke-WiFiAnalyzerAll -OutputPath "$env:USERPROFILE\Desktop\WiFiReport.html"
```

#### Export-WiFiReport
| Parameter | Type | Description |
|-----------|------|-------------|
| `-networks` | array | WiFi network objects (required) |
| `-OutputFormat` | string | 'HTML' or 'CSV' (default: 'HTML') |
| `-OutputPath` | string | Path to save report (optional) |
| `-SkipReportInfo` | switch | Skip user info prompts |

**Example:**
```powershell
$networks = Get-WiFiScan
Export-WiFiReport -networks $networks -OutputFormat HTML -SkipReportInfo
```

#### Get-BestChannel
| Parameter | Type | Description |
|-----------|------|-------------|
| `-networks` | array | WiFi network objects from Get-WiFiScan (required) |

**Example:**
```powershell
$networks = Get-WiFiScan
$recommendations = Get-BestChannel -networks $networks
Write-Host "Best 2.4GHz: $($recommendations.'2.4GHz')"
Write-Host "Best 5GHz: $($recommendations.'5GHz')"
```

#### Test-NetworkSpeed
| Parameter | Type | Description |
|-----------|------|-------------|
| `-TestUrl` | string | URL to test against (default: 'https://www.google.com') |
| `-Iterations` | int | Number of test iterations (default: 3) |

**Example:**
```powershell
$speedTest = Test-NetworkSpeed -Iterations 5
Write-Host "Average Latency: $($speedTest.AverageLatency) ms"
```

### Using the Standalone Script

### Prerequisites

- Windows 10/11
- PowerShell 5.1 or later
- Active WiFi adapter
- Location services enabled (for WiFi scanning)

**For PowerShell Gallery Installation:**
- PowerShellGet module (usually pre-installed)
- Internet connection

### Installation

#### PowerShell Gallery (Quick & Easy)

```powershell
# Install the module (one-time setup)
Install-Module -Name WiFiAnalyzer -Scope CurrentUser -Force

# Start using it immediately
Import-Module WiFiAnalyzer
Start-WiFiAnalyzer
```

#### GitHub (Development Version)

1. Clone the repository:
```powershell
git clone https://github.com/hov172/PS_WI-FI_Analyzer.git
cd PS_WI-FI_Analyzer
```

2. Run the script:
```powershell
.\WiFiAnalyzerNew.ps1
```

### Usage Examples

#### Interactive Mode (Recommended)
```powershell
# Using the module
Import-Module WiFiAnalyzer
Start-WiFiAnalyzer

# Or using the standalone script
.\WiFiAnalyzerNew.ps1
```
Shows startup choice dialog - perfect for mixed-skill environments.

#### Quick Start for IT Professionals
```powershell
# Using the module
Start-WiFiAnalyzer -QuickStart

# Or using the standalone script
.\WiFiAnalyzerNew.ps1 -QuickStart
```
Skip all setup checks and go straight to scanning.

#### Command-Line Analysis and Report Generation
```powershell
# Run complete analysis and save to Documents folder
Invoke-WiFiAnalyzerAll -SkipReportInfo

# Specify custom output path
Invoke-WiFiAnalyzerAll -SkipReportInfo -OutputPath "C:\Reports\WiFi_Analysis.html"

# Export as CSV
Invoke-WiFiAnalyzerAll -OutputFormat CSV -OutputPath "C:\Reports\WiFi_Data.csv"
```

#### Advanced Scanning and Analysis
```powershell
# Scan networks and display results
$networks = Get-WiFiScan
$networks | Format-Table SSID, Signal, Channel, Band, Security -AutoSize

# Get channel recommendations
$recommendations = Get-BestChannel -networks $networks
Write-Host "Recommended 2.4GHz Channel: $($recommendations.'2.4GHz')"
Write-Host "Recommended 5GHz Channel: $($recommendations.'5GHz')"

# Test network speed
$speedTest = Test-NetworkSpeed
if ($speedTest.Success) {
    Write-Host "Average Latency: $($speedTest.AverageLatency) ms"
}

# Get system information
$mac = Get-MACAddress
$connected = Get-ConnectedSSID
$computerInfo = Get-ComputerInfoExtras
Write-Host "MAC: $mac"
Write-Host "Connected to: $($connected.SSID)"
Write-Host "Computer: $($computerInfo.ComputerName)"
Write-Host "IP: $($computerInfo.IPAddress)"
```

#### Show Help
```powershell
# Get help on any command
Get-Help Start-WiFiAnalyzer -Full
Get-Help Invoke-WiFiAnalyzerAll -Examples
Get-Help Get-WiFiScan -Detailed

# Or using the standalone script
.\WiFiAnalyzerNew.ps1 -help
```

## 📋 Table of Contents

- [Installation Methods](#-installation-methods)
- [Quick Start](#-quick-start)
- [Module Commands Reference](#module-commands-reference)
- [System Requirements](#-system-requirements)
- [Hybrid Startup System](#-hybrid-startup-system)
- [Core Functionality](#-core-functionality)
- [Channel Analysis](#-channel-analysis)
- [Speed Testing](#-speed-testing)
- [Location Tracking](#-location-tracking)
- [Educational Environment Features](#-educational-environment-features)
- [Report Generation](#-report-generation)
- [Command Line Reference](#-command-line-reference)
- [Quick Reference](#-quick-reference)
- [Contributing](#-contributing)
- [License](#-license)

## 💻 System Requirements

The application performs comprehensive system validation:

- ✅ **Location Services** - Required for WiFi scanning
- ✅ **WiFi Adapter** - Active wireless network adapter  
- ✅ **Admin Rights** - Enhanced permissions (optional but recommended)

Returns detailed status with specific issue identification and automated fixes.

## 🎯 Hybrid Startup System

### Intelligent User Experience

Choose between two startup modes based on your experience level:

#### 🎓 Guided Setup Mode (Recommended)
**Target Users**: Students, first-time users, troubleshooting scenarios

**Features**:
- Comprehensive system requirements checking
- Automatic detection of location service issues
- Step-by-step guidance to fix problems
- Attempts to open Windows Settings automatically
- Provides manual instructions if auto-fix fails
- Only proceeds when system is ready

#### ⚡ Quick Start Mode
**Target Users**: IT professionals, experienced users

**Features**:
- Basic validation with warning dialogs
- Option to continue despite issues
- Direct path to WiFi scanning
- Minimal user interaction

#### 💾 Preference Management

The application remembers your choice for future launches:
- Saves preference to: `%APPDATA%\WiFiAnalyzer_Preference.txt`
- Eliminates need to choose on subsequent runs
- Can be reset at any time

## 🔧 Core Functionality

### Network Scanning

Utilizes Windows' `netsh` command to detect and parse:
- SSID (network name) including hidden networks
- BSSID (MAC address of access points)
- Signal strength (0-100%)
- Channel numbers and width
- Security protocols
- Frequency band (2.4 GHz / 5 GHz)

### Signal Analysis

Signal strength is categorized with visual color-coding:
- **🟢 Strong** (70-100%): Excellent connectivity
- **🟠 Medium** (40-69%): Good connectivity
- **🔴 Weak** (0-39%): Poor connectivity

### Security Assessment

Identifies and color-codes security protocols:
- **🟢 WPA3**: Most secure, modern encryption
- **🔵 WPA2**: Standard secure protocol
- **🟠 WPA**: Older, less secure
- **🔴 Open**: No encryption, vulnerable

## 📊 Channel Analysis

### Channel Congestion Algorithm

The sophisticated algorithm models real-world WiFi interference:

1. **Channel Overlap Modeling**
   - 2.4 GHz channels overlap ±4 channels
   - 5 GHz channels have minimal overlap

2. **Impact Formula**
   ```
   Impact = Signal × (1 - (Distance ÷ 5))
   ```

3. **Cumulative Scoring**
   - Each channel's congestion score is the sum of all impacts
   - Higher scores indicate more congestion/interference

### Channel Recommendations

Provides best channel suggestions for:
- **2.4 GHz band**: Channels 1-14
- **5 GHz band**: Channels 36+

Based on least congested channels in your area.

## ⚡ Speed Testing

### Performance Metrics

Tests network performance with fallback servers:

#### Latency Testing
- Multiple DNS servers (8.8.8.8, 167.206.19.3, 216.244.115.147)
- Average response time in milliseconds
- Automatic fallback on failure

#### Download Testing
- Multiple test file sources
- Measures throughput in Mbps
- Converts MB/s to Mbps for standard reporting
- Designed for educational network restrictions

## 🏢 Location Tracking

### Enhanced User Information

Collects comprehensive user and location data:
- Name and ID number
- Email address
- Telephone number
- **Building name**
- **Room number**

### Benefits

- **Precise Location Information**: Helps IT staff locate issues accurately
- **Pattern Recognition**: Correlates issues with specific locations
- **Faster Support**: Eliminates follow-up questions
- **Historical Tracking**: Better metrics across campus

## 🎓 Educational Environment Features

### For Students
- Step-by-step guidance for first-time users
- Clear visual feedback with color coding
- Educational value about WiFi technology
- No technical knowledge required

### For IT Support Staff
- Quick Start mode for efficient troubleshooting
- Comprehensive reports with location data
- Debug mode for complex issues
- Command line automation

### For Administrators
- Preference management across systems
- Location tracking integration
- Batch deployment capabilities
- Educational network compliance

## 📄 Report Generation

### Comprehensive Export

Reports automatically saved to desktop include:
- **User Details**: Name, ID, contact info, location
- **System Information**: Computer name, IP, MAC, connected network
- **Network Analysis**: All detected networks with full details
- **Performance Metrics**: Speed test results and latency
- **Optimization Recommendations**: Best channels for both bands
- **Technical Details**: Channel congestion scores

## ⌨️ Command Line Reference

```powershell
# Interactive mode (recommended)
.\WiFiAnalyzerNew.ps1

# Quick start for IT professionals
.\WiFiAnalyzerNew.ps1 -QuickStart

# Alternative quick start syntax
.\WiFiAnalyzerNew.ps1 -SkipPreflightCheck

# Debug mode for troubleshooting
.\WiFiAnalyzerNew.ps1 -Debug

# Show all available options
.\WiFiAnalyzerNew.ps1 -help
```

### Deployment Scenarios

#### Lab Computer Setup
1. Run once with desired mode
2. Check "Remember my choice"
3. Future users get automatic startup

#### Help Desk Usage
```powershell
.\WiFiAnalyzerNew.ps1 -QuickStart -Debug
```

#### Student Support
- Students use default interactive mode
- Guided setup teaches system requirements
- Reports include location data for follow-up

## 🛠️ Technical Details

### Module Commands Reference

#### Start-WiFiAnalyzer
Launch the main WiFi Analyzer GUI application.

```powershell
Start-WiFiAnalyzer [-QuickStart] [-Debug] [-SkipPreflightCheck] [-Help]
```

**Parameters:**
- `-QuickStart`: Skip guided setup and go directly to scanning
- `-Debug`: Enable detailed diagnostic output
- `-SkipPreflightCheck`: Alias for QuickStart mode
- `-Help`: Display command help information

**Examples:**
```powershell
# Standard interactive mode
Start-WiFiAnalyzer

# Quick start for experienced users
Start-WiFiAnalyzer -QuickStart

# Debug mode for troubleshooting
Start-WiFiAnalyzer -Debug
```

#### Get-WiFiNetworks
Scan and retrieve information about available WiFi networks.

```powershell
Get-WiFiNetworks [-Detailed] [-Band <String>]
```

**Parameters:**
- `-Detailed`: Include extended network information
- `-Band`: Filter by frequency band ('2.4GHz', '5GHz', or 'All')

**Output Properties:**
- SSID (Network Name)
- BSSID (MAC Address)
- Signal Strength (%)
- Channel Number
- Security Type
- Frequency Band

**Examples:**
```powershell
# Get all networks
Get-WiFiNetworks

# Get only 5GHz networks
Get-WiFiNetworks -Band '5GHz'

# Get detailed information
Get-WiFiNetworks -Detailed | Format-Table
```

#### Get-WiFiSignalStrength
Get the current WiFi signal strength and quality metrics.

```powershell
Get-WiFiSignalStrength [-AsPercentage] [-Continuous]
```

**Parameters:**
- `-AsPercentage`: Return signal strength as percentage (default)
- `-Continuous`: Monitor signal strength continuously

**Examples:**
```powershell
# Get current signal strength
Get-WiFiSignalStrength

# Monitor continuously (Ctrl+C to stop)
Get-WiFiSignalStrength -Continuous
```

#### Test-WiFiSpeed
Perform comprehensive network speed testing.

```powershell
Test-WiFiSpeed [-QuickTest] [-Server <String>]
```

**Parameters:**
- `-QuickTest`: Perform faster, less comprehensive test
- `-Server`: Specify test server (uses fallback servers by default)

**Output:**
- Download Speed (Mbps)
- Latency (ms)
- Connection Quality Assessment

**Examples:**
```powershell
# Standard speed test
Test-WiFiSpeed

# Quick speed test
Test-WiFiSpeed -QuickTest
```

#### Get-WiFiChannelInfo
Analyze WiFi channel usage and congestion.

```powershell
Get-WiFiChannelInfo [-Band <String>] [-ShowRecommendations]
```

**Parameters:**
- `-Band`: Analyze specific band ('2.4GHz', '5GHz', or 'All')
- `-ShowRecommendations`: Include optimal channel recommendations

**Output:**
- Channel congestion scores
- Recommended channels for each band
- Interference analysis

**Examples:**
```powershell
# Analyze all channels
Get-WiFiChannelInfo -ShowRecommendations

# Analyze only 2.4GHz band
Get-WiFiChannelInfo -Band '2.4GHz'
```

#### Export-WiFiReport
Generate and save a comprehensive WiFi analysis report.

```powershell
Export-WiFiReport [-Path <String>] [-IncludeSpeedTest] [-IncludeUserInfo]
```

**Parameters:**
- `-Path`: Specify save location (defaults to Desktop)
- `-IncludeSpeedTest`: Include network speed test results
- `-IncludeUserInfo`: Prompt for user/location information

**Examples:**
```powershell
# Generate report with all data
Export-WiFiReport -IncludeSpeedTest -IncludeUserInfo

# Save to specific location
Export-WiFiReport -Path "C:\Reports\WiFi_Report.txt"
```

#### Get-WiFiSystemInfo
Retrieve system and WiFi adapter information.

```powershell
Get-WiFiSystemInfo [-IncludeDriverInfo]
```

**Parameters:**
- `-IncludeDriverInfo`: Include WiFi driver version and details

**Output:**
- Computer Name
- IP Address
- MAC Address
- WiFi Adapter Name
- Driver Information (if requested)
- Connected Network Details

**Examples:**
```powershell
# Get basic system info
Get-WiFiSystemInfo

# Include driver information
Get-WiFiSystemInfo -IncludeDriverInfo
```

### Module Management

```powershell
# View installed version
Get-Module -Name WiFiAnalyzer -ListAvailable

# Update to latest version
Update-Module -Name WiFiAnalyzer

# Uninstall module
Uninstall-Module -Name WiFiAnalyzer

# Import module manually
Import-Module WiFiAnalyzer

# View all module commands
Get-Command -Module WiFiAnalyzer

# Get detailed help for any command
Get-Help Start-WiFiAnalyzer -Full
Get-Help Get-WiFiNetworks -Examples
```

### Advanced Module Usage

#### Pipeline Support

The module supports PowerShell pipeline operations:

```powershell
# Get networks and filter by signal strength
Get-WiFiScan | Where-Object { $_.Signal -gt 70 }

# Filter by security type
Get-WiFiScan | Where-Object { $_.Security -match 'WPA2' }

# Export to CSV
Get-WiFiScan | Export-Csv -Path "networks.csv" -NoTypeInformation

# Find networks on specific channel
Get-WiFiScan | Where-Object { $_.Channel -eq 6 }

# Get only 5GHz networks
Get-WiFiScan | Where-Object { $_.Band -eq '5 GHz' } | 
    Sort-Object Signal -Descending
```

#### Scripting Examples

```powershell
# Automated monitoring script - check signal strength
while ($true) {
    $connected = Get-ConnectedSSID
    $networks = Get-WiFiScan
    $currentNetwork = $networks | Where-Object { $_.SSID -eq $connected.SSID }
    
    if ($currentNetwork -and $currentNetwork.Signal -lt 30) {
        Write-Warning "Low WiFi signal: $($currentNetwork.Signal)%"
        # Trigger notification or action
    }
    Start-Sleep -Seconds 60
}

# Batch report generation for multiple locations
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$networks = Get-WiFiScan

# Generate reports in different formats
Export-WiFiReport -networks $networks -OutputFormat HTML `
    -OutputPath "C:\Reports\WiFi_Report_$timestamp.html" -SkipReportInfo
    
Export-WiFiReport -networks $networks -OutputFormat CSV `
    -OutputPath "C:\Reports\WiFi_Data_$timestamp.csv" -SkipReportInfo

# Channel optimization check
$networks = Get-WiFiScan
$channels = Get-BestChannel -networks $networks
$connected = Get-ConnectedSSID

Write-Host "Current Network: $($connected.SSID)"
Write-Host "Recommended 2.4GHz Channel: $($channels.'2.4GHz')"
Write-Host "Recommended 5GHz Channel: $($channels.'5GHz')"

# Automated daily report
$job = {
    Import-Module WiFiAnalyzer
    $date = Get-Date -Format "yyyy-MM-dd"
    Invoke-WiFiAnalyzerAll -SkipReportInfo `
        -OutputPath "C:\Reports\Daily\WiFi_$date.html"
}
$trigger = New-JobTrigger -Daily -At 9am
Register-ScheduledJob -Name "DailyWiFiReport" -ScriptBlock $job -Trigger $trigger
```

### Troubleshooting Module Installation

If you encounter issues installing the module:

```powershell
# Check PowerShell Gallery connectivity
Test-NetConnection www.powershellgallery.com -Port 443

# Set PowerShell Gallery as trusted
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

# Install with verbose output
Install-Module -Name WiFiAnalyzer -Verbose

# Check for conflicting modules
Get-Module -ListAvailable | Where-Object Name -like "*wifi*"

# Reinstall if needed
Uninstall-Module -Name WiFiAnalyzer -Force
Install-Module -Name WiFiAnalyzer -Force
```

## 🛠️ Technical Details

### Built With
- PowerShell 5.1+
- .NET Windows Forms
- Native Windows networking commands

### Key Technologies
- `netsh wlan` for WiFi information
- `System.Windows.Forms` for GUI
- `System.Net.WebClient` for speed testing
- `Get-NetAdapter` for network interfaces

### Performance Optimizations
- Efficient regex parsing
- Memory management with cleanup
- Non-blocking UI operations
- Minimal system resource impact

### Security Considerations
- No credential storage
- Local-only operation
- Automatic temporary file cleanup
- Graceful permission handling

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

**Repository**: https://github.com/hov172/PS_WI-FI_Analyzer

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

**Jesus Ayala** - [Ayala Solutions](https://github.com/hov172)

## 📋 Quick Reference

### Essential Commands Cheat Sheet

```powershell
# Installation
Install-Module -Name WiFiAnalyzer -Scope CurrentUser -Force

# Launch GUI
Start-WiFiAnalyzer                    # Interactive mode with startup dialog
Start-WiFiAnalyzer -QuickStart        # Skip setup checks
Start-WiFiAnalyzerDirect              # Direct launch (no dialogs)

# Command-Line Analysis
Invoke-WiFiAnalyzerAll -SkipReportInfo                    # Quick report
Invoke-WiFiAnalyzerAll -OutputPath "C:\Reports\wifi.html" # Custom path

# Network Scanning & Analysis
Get-WiFiScan                          # List all networks
Get-WiFiScan | Where-Object {$_.Band -eq '5 GHz'}         # 5GHz only
Get-ConnectedSSID                     # Current connection
Get-MACAddress                        # Adapter MAC address

# Channel Analysis
$networks = Get-WiFiScan
Get-BestChannel -networks $networks   # Get recommendations
Test-ChannelCongestion -networks $networks  # Analyze congestion

# Network Testing
Test-NetworkSpeed                     # Latency test
Test-NetworkSpeed -Iterations 5       # Custom iterations

# Report Generation  
$networks = Get-WiFiScan
Export-WiFiReport -networks $networks -OutputFormat HTML
Export-WiFiReport -networks $networks -OutputFormat CSV -SkipReportInfo

# System Information
Get-ComputerInfoExtras               # Computer name & IP
Get-ConnectedSSID                    # Current SSID & BSSID

# Module Management
Get-Command -Module WiFiAnalyzer      # List all commands
Update-Module -Name WiFiAnalyzer      # Update to latest
Get-Help Start-WiFiAnalyzer -Full    # Detailed help
Get-Help Invoke-WiFiAnalyzerAll -Examples  # Command examples
```

### Common Use Cases

#### Monitor Signal Strength
```powershell
# Continuous monitoring with color-coded output
while ($true) {
    $connected = Get-ConnectedSSID
    $networks = Get-WiFiScan
    $current = $networks | Where-Object { $_.SSID -eq $connected.SSID }
    
    if ($current) {
        $signal = $current.Signal
        $color = if ($signal -ge 70) { 'Green' } elseif ($signal -ge 40) { 'Yellow' } else { 'Red' }
        Write-Host "[$($connected.SSID)] Signal: $signal%" -ForegroundColor $color
    }
    Start-Sleep -Seconds 5
}
```

#### Find Best Networks
```powershell
Get-WiFiScan | 
    Where-Object { $_.Signal -gt 70 -and $_.Security -match 'WPA2' } |
    Sort-Object Signal -Descending |
    Select-Object SSID, Signal, Channel, Band, Security |
    Format-Table -AutoSize
```

#### Export Analysis to CSV
```powershell
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
Get-WiFiScan | 
    Export-Csv -Path "wifi_scan_$timestamp.csv" -NoTypeInformation
```

#### Channel Optimization Check
```powershell
$networks = Get-WiFiScan
$analysis = Get-BestChannel -networks $networks
Write-Host "Recommended 2.4GHz Channel: $($analysis.'2.4GHz')" -ForegroundColor Cyan
Write-Host "Recommended 5GHz Channel: $($analysis.'5GHz')" -ForegroundColor Cyan

# Show congestion data
$congestion = Test-ChannelCongestion -networks $networks
$congestion.GetEnumerator() | Sort-Object Value | 
    Select-Object @{N='Channel';E={$_.Name}}, @{N='Congestion';E={[math]::Round($_.Value,2)}} |
    Format-Table -AutoSize
```

#### Complete System Report
```powershell
# Gather all information
$networks = Get-WiFiScan
$mac = Get-MACAddress
$connected = Get-ConnectedSSID
$computerInfo = Get-ComputerInfoExtras
$channels = Get-BestChannel -networks $networks
$speed = Test-NetworkSpeed

# Display summary
Write-Host "`n=== WiFi System Report ===" -ForegroundColor Cyan
Write-Host "Computer: $($computerInfo.ComputerName)"
Write-Host "IP Address: $($computerInfo.IPAddress)"
Write-Host "MAC Address: $mac"
Write-Host "Connected: $($connected.SSID)"
Write-Host "Networks Found: $($networks.Count)"
Write-Host "Best 2.4GHz Ch: $($channels.'2.4GHz')"
Write-Host "Best 5GHz Ch: $($channels.'5GHz')"
if ($speed.Success) {
    Write-Host "Avg Latency: $($speed.AverageLatency) ms"
}
```

### Troubleshooting Common Issues

#### Module Not Found
```powershell
# Refresh module cache
Get-Module -ListAvailable -Refresh

# Reinstall
Uninstall-Module WiFiAnalyzer -Force -ErrorAction SilentlyContinue
Install-Module WiFiAnalyzer -Force
```

#### Location Services Error
1. Open **Settings** → **Privacy & Security** → **Location**
2. Enable **"Location services"**
3. Enable **"Let apps access your location"**
4. Restart the application

#### No WiFi Networks Found
```powershell
# Check WiFi adapter status
Get-NetAdapter | Where-Object {$_.InterfaceDescription -match 'Wireless'}

# Enable WiFi adapter if disabled
Enable-NetAdapter -Name "Wi-Fi"

# Verify location services
Get-Service -Name lfsvc | Select-Object Status
```

#### Permission Issues
```powershell
# Option 1: Run PowerShell as Administrator
Start-Process powershell -Verb RunAs

# Option 2: Install for current user only
Install-Module WiFiAnalyzer -Scope CurrentUser -Force
```

## 🙏 Acknowledgments

- Designed specifically for educational institutions
- Optimized for Sarah Lawrence College IT infrastructure
- Built with feedback from students and IT support staff

## 📞 Support

For issues, questions, or suggestions:
- Open an [issue](https://github.com/hov172/PS_WI-FI_Analyzer/issues)
- Visit the [PowerShell Gallery page](https://www.powershellgallery.com/packages/WiFiAnalyzer)
- Visit the [GitHub repository](https://github.com/hov172/PS_WI-FI_Analyzer)
- Contact IT support at your institution

### Reporting Issues

When reporting issues, please include:
- PowerShell version: `$PSVersionTable.PSVersion`
- Module version: `(Get-Module WiFiAnalyzer).Version`
- Windows version: `[System.Environment]::OSVersion.Version`
- Error messages or unexpected behavior details

### Getting Help

```powershell
# View module information
Get-Module WiFiAnalyzer

# Get command help
Get-Help Start-WiFiAnalyzer -Full

# View examples
Get-Help Get-WiFiNetworks -Examples

# Check for updates
Find-Module WiFiAnalyzer
```

---

<div align="center">

**[⬆ back to top](#-wifi-analyzer---hybrid-startup-edition)**

Made with ❤️ for better WiFi connectivity

</div>
