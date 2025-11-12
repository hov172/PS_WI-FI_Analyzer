#Requires -Version 5.1
<#!
.SYNOPSIS
  Wi-Fi Analyzer (GUI/CLI hybrid) that scans nearby networks, analyzes congestion, and exports a report.

.DESCRIPTION
  Provides Guided and Quick start flows, parses `netsh wlan` output, recommends channels for 2.4/5 GHz,
  performs a basic latency/download check, and exports TXT/HTML/CSV. Implements PowerShell best practices:
  - Advanced function script: [CmdletBinding(SupportsShouldProcess)] with -WhatIf/-Confirm
  - Strict mode & Stop-on-error defaults
  - WinForms STA relaunch when needed
  - Parameter validation and output typing
  - Proper disposal of WebClient and temp files
  - Minimal reliance on script scope; consolidated app state

.PARAMETER QuickStart
  Skip guided checks and start scanning.

.PARAMETER SkipPreflightCheck
  Alias for QuickStart.

.EXAMPLE
  .\WiFiAnalyzer.ps1 -QuickStart -Verbose

.NOTES
  Author: Jesus Ayala — Sarah Lawrence College
  License: MIT
#>

[CmdletBinding(SupportsShouldProcess)]
param(
  [switch]$QuickStart,
  [switch]$SkipPreflightCheck
)

# -------------------------------
# Hardened defaults
# -------------------------------
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

# Consolidated app state (keeps globals tidy)
$app = [pscustomobject]@{
  Networks        = @()
  Mac             = ''
  Recommended     = @{}
  ComputerName    = ''
  IpAddress       = ''
  ConnectedSsid   = ''
  ConnectedBssid  = ''
  ConnectedChannel = ''
  CongestionData  = @{}
  SpeedTest       = [pscustomobject]@{ DownloadSpeed = 0; Latency = 0; Status='Not Run'; Details='' }
}

# Import WinForms assemblies (safe to load even in non-STA; UI will relaunch STA later)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# -------------------------------
# Core Wi-Fi functions
# -------------------------------
function Get-WiFiScan {
  <# Returns array of PSCustomObject: SSID,BSSID,Signal,Channel,Security,Width,Band #>
  $networks = @()
  $ssid = ''
  $security = ''
  try {
    $output = netsh wlan show networks mode=bssid | Out-String
  } catch {
    Write-Verbose "netsh scan failed: $($_.Exception.Message)"; return @()
  }
  $lines = $output -split "`r`n"
  for ($i = 0; $i -lt $lines.Length; $i++) {
    $line = $lines[$i].Trim()
    if ($line -match "^SSID\s+\d+\s*:\s*(.+)$") { $ssid = $matches[1].Trim(); $security = 'Unknown' }
    if ($line -match "Authentication\s*:\s*(.+)$") { $security = $matches[1].Trim() }
    if ($line -match "^BSSID\s+\d+\s*:\s*(.+)$") {
      $bssid = $matches[1].Trim(); $signal = $null; $channel = $null; $width = $null
      for ($j = 1; $j -le 8; $j++) {
        if ($i + $j -ge $lines.Length) { break }
        $next = $lines[$i+$j].Trim()
        if     ($next -match "^Signal\s*:\s*(\d+)%") { $signal = [int]$matches[1] }
        elseif ($next -match "^Channel\s*:\s*(\d+)$") { $channel = [int]$matches[1] }
        elseif ($next -match "^Channel width\s*:\s*(.+)$") { $width = $matches[1].Trim() }
      }
      if ($ssid -and $bssid -and $null -ne $signal -and $null -ne $channel) {
        if ($ssid) {
          $ssidDisplay = $ssid
        } else {
          $ssidDisplay = '[Hidden Network]'
        }
        
        if ($width) {
          $widthDisplay = $width
        } else {
          $widthDisplay = 'Standard'
        }
        
        if ($channel -gt 14) {
          $bandDisplay = '5 GHz'
        } else {
          $bandDisplay = '2.4 GHz'
        }
        
        $networks += [pscustomobject]@{
          SSID     = $ssidDisplay
          BSSID    = $bssid
          Signal   = $signal
          Channel  = $channel
          Security = $security
          Width    = $widthDisplay
          Band     = $bandDisplay
        }
      }
    }
  }
  return $networks
}

function Get-MACAddress {
  try {
    $output = netsh wlan show interfaces | Out-String
    foreach ($line in $output -split "`r`n") {
      if ($line -match "^\s*Physical address\s*:\s*([0-9a-fA-F:-]+)") { return $matches[1].Trim() }
    }
  } catch { Write-Verbose "MAC query failed: $($_.Exception.Message)" }
  return 'Unavailable'
}

function Get-ConnectedSSID {
  $ssid=''; $bssid=''; $channel=''
  try {
    $output = netsh wlan show interfaces | Out-String
    foreach ($line in $output -split "`r`n") {
      if ($line -match "^\s*SSID\s*:\s*(.+)$") {
        $val=$matches[1].Trim()
        if ($val -and $val -ne 'N/A') {
          $ssid=$val
        }
      }
      elseif ($line -match "^\s*BSSID\s*:\s*(.+)$")  { $bssid=$matches[1].Trim() }
      elseif ($line -match "^\s*Channel\s*:\s*(\d+)") { $channel=$matches[1].Trim() }
    }
  } catch { Write-Verbose "SSID query failed: $($_.Exception.Message)" }
  return @{ SSID=$ssid; BSSID=$bssid; Channel=$channel }
}

function Get-ComputerInfoExtras {
  $name = $env:COMPUTERNAME; $ip = $null
  try {
    $wifi = Get-NetAdapter -Physical | Where-Object { $_.Status -eq 'Up' -and ($_.InterfaceDescription -match 'Wireless' -or $_.Name -match 'Wi-Fi') }
    if ($wifi) {
      $ipEntry = Get-NetIPAddress -InterfaceIndex $wifi.ifIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue | Where-Object { $_.IPAddress -notlike '169.*' } | Select-Object -First 1
      if ($ipEntry) { $ip = $ipEntry.IPAddress }
    }
  } catch { Write-Verbose "Adapter/IP query failed: $($_.Exception.Message)" }
  
  if ($ip) {
    $ipDisplay = $ip
  } else {
    $ipDisplay = 'Unavailable'
  }
  
  return @{ ComputerName=$name; IPAddress = $ipDisplay }
}

function Get-SignalColor([int]$signal) {
  if ($signal -ge 70) { return 'Strong','Green' }
  elseif ($signal -ge 40) { return 'Medium','Orange' }
  else { return 'Weak','Red' }
}

function Get-SecurityColor([string]$security) {
  if ($security -match 'WPA3') { return 'WPA3','Green' }
  elseif ($security -match 'WPA2') { return 'WPA2','Blue' }
  elseif ($security -match 'WPA') { return 'WPA','Orange' }
  elseif ($security -match 'Open') { return 'Open','Red' }
  else { return $security,'Black' }
}

function Test-ChannelCongestion($networks) {
  $channelAnalysis = @{}
  $n24 = $networks | Where-Object { [int]$_.Channel -le 14 }
  $n5  = $networks | Where-Object { [int]$_.Channel -gt 14 }
  foreach ($n in $n24) {
    $ch = [int]$n.Channel; $sig = [int]$n.Signal
    $start=[Math]::Max(1,$ch-4); $end=[Math]::Min(14,$ch+4)
    for ($i=$start; $i -le $end; $i++) {
      $dist=[Math]::Abs($i-$ch); $impact=$sig*(1-($dist/5))
      if ($channelAnalysis.ContainsKey($i)) {
        $channelAnalysis[$i]+=$impact
      } else {
        $channelAnalysis[$i]=$impact
      }
    }
  }
  foreach ($n in $n5) {
    $ch=[int]$n.Channel; $sig=[int]$n.Signal
    if ($channelAnalysis.ContainsKey($ch)) {
      $channelAnalysis[$ch]+=$sig
    } else {
      $channelAnalysis[$ch]=$sig
    }
  }
  return $channelAnalysis
}

function Get-BestChannel($networks) {
  if (-not $networks -or $networks.Count -eq 0) { return @{ '2.4GHz'='N/A'; '5GHz'='N/A'; CongestionData=@{} } }
  $cong = Test-ChannelCongestion $networks
  $c24 = $cong.GetEnumerator() | Where-Object { $_.Name -le 14 } | Sort-Object Name
  $c5  = $cong.GetEnumerator() | Where-Object { $_.Name -gt 14 } | Sort-Object Name
  
  if ($c24) {
    $b24 = ($c24 | Sort-Object Value | Select-Object -First 1)
  } else {
    $b24 = $null
  }
  
  if ($c5) {
    $b5 = ($c5 | Sort-Object Value | Select-Object -First 1)
  } else {
    $b5 = $null
  }
  
  if ($b24) {
    $best24 = $b24.Name
  } else {
    $best24 = 'N/A'
  }
  
  if ($b5) {
    $best5 = $b5.Name
  } else {
    $best5 = 'N/A'
  }
  
  return @{ '2.4GHz' = $best24; '5GHz' = $best5; CongestionData=$cong }
}

# -------------------------------
# Network speed (latency + tiny download)
# -------------------------------
function Test-NetworkSpeed {
  $result = [pscustomobject]@{ DownloadSpeed=0; UploadSpeed=0; Latency=0; Status='Failed'; Details='' }
  try {
    $pingServers = @('8.8.8.8','1.1.1.1','9.9.9.9')
    $ok=$false
    foreach ($s in $pingServers) {
      try {
        $p = Test-Connection -ComputerName $s -Count 2 -ErrorAction Stop
        $avg = ($p | Measure-Object -Property ResponseTime -Average).Average
        $result.Latency = [math]::Round($avg,0); $ok=$true; $result.Details += "Ping OK $s. "
        break
      } catch { $result.Details += "Ping fail $s. " }
    }
    if (-not $ok) { $result.Status = 'Failed: All ping tests failed'; return $result }

    $result.Status = "Partial: Latency OK ($($result.Latency)ms), download test pending."
    $urls = @(
      'https://ipv4.download.thinkbroadband.com/1MB.zip',
      'https://proof.ovh.net/files/1Mb.dat'
    )
    $tmp = Join-Path ([IO.Path]::GetTempPath()) "speedtest.tmp"
    try {
      foreach ($u in $urls) {
        try {
          $wc = New-Object System.Net.WebClient
          try {
            $start=Get-Date; $wc.DownloadFile($u,$tmp); $end=Get-Date
          } finally { $wc.Dispose() }
          $sizeMB = (Get-Item $tmp).Length / 1MB
          $secs = ($end - $start).TotalSeconds
          if ($secs -gt 0) {
            $mbps = [math]::Round(($sizeMB / $secs) * 8,2)
            $result.DownloadSpeed = $mbps
            $result.Status = 'Success'
            $result.Details += "Download OK via $u. "
            break
          }
        } catch { $result.Details += "Download fail $u. " }
      }
      
      # Basic upload test using HTTP POST
      if ($result.DownloadSpeed -gt 0) {
        try {
          $uploadData = [byte[]]::new(102400) # 100KB test data
          $rng = New-Object System.Random
          $rng.NextBytes($uploadData)
          
          $uploadUrls = @('https://httpbin.org/post', 'https://postman-echo.com/post')
          foreach ($uploadUrl in $uploadUrls) {
            try {
              $wc = New-Object System.Net.WebClient
              try {
                $start = Get-Date
                $wc.UploadData($uploadUrl, 'POST', $uploadData) | Out-Null
                $end = Get-Date
              } finally { $wc.Dispose() }
              
              $sizeMB = $uploadData.Length / 1MB
              $secs = ($end - $start).TotalSeconds
              if ($secs -gt 0) {
                $mbps = [math]::Round(($sizeMB / $secs) * 8,2)
                $result.UploadSpeed = $mbps
                $result.Details += "Upload OK. "
                break
              }
            } catch { $result.Details += "Upload test failed via $uploadUrl. " }
          }
        } catch { $result.Details += "Upload test skipped: $($_.Exception.Message). " }
      }
      
      if ($result.Status -ne 'Success') { $result.Status = 'Partial: Latency OK, downloads failed' }
    } finally { if (Test-Path $tmp) { Remove-Item $tmp -Force -ErrorAction SilentlyContinue } }
    return $result
  } catch { $result.Status = "Failed: $($_.Exception.Message)"; $result.Details = "Exception: $($_.Exception)"; return $result }
}

# -------------------------------
# Preflight & preferences
# -------------------------------
function Test-Prerequisites {
  $r = @{ LocationServices=$false; WiFiAdapter=$false; AdminRights=$false; OverallStatus=$false; Issues=@(); Warnings=@() }
  
  # Check Wi-Fi adapter first
  try {
    $adapters = @(Get-NetAdapter -ErrorAction Stop | Where-Object { $_.InterfaceDescription -match 'Wireless' -or $_.Name -match 'Wi-Fi' })
    if ($adapters.Count -eq 0) { 
      $r.Issues += 'No Wi-Fi adapter found'
    } else {
      $activeAdapters = @($adapters | Where-Object { $_.Status -eq 'Up' })
      if ($activeAdapters.Count -eq 0) { 
        $r.Issues += 'Wi-Fi adapter found but not active (disabled or not connected)'
      } else { 
        $r.WiFiAdapter = $true 
      }
    }
  } catch { 
    $r.Warnings += "Could not verify Wi-Fi adapter status: $($_.Exception.Message)" 
  }
  
  # Check location services by attempting to scan networks
  try {
    $wlanScan = netsh wlan show networks 2>&1 | Out-String
    
    # Check for error conditions that indicate location services are disabled
    if ($wlanScan -match 'requires that location services be turned on' -or 
        $wlanScan -match 'location permission' -or 
        $wlanScan -match 'Access is denied' -or
        $wlanScan -match 'denied' -or
        $wlanScan -match 'There is no wireless interface on the system') {
      if ($wlanScan -match 'no wireless interface') {
        $r.Issues += 'No wireless interface detected by netsh'
      } else {
        $r.Issues += 'Location services not enabled for Wi-Fi scanning'
      }
      $r.LocationServices = $false
    } 
    # Check for success - network scan returned results or showed interface
    elseif ($wlanScan -match 'SSID \d+' -or 
            $wlanScan -match 'Interface name' -or 
            $wlanScan -match 'currently visible' -or
            $wlanScan -match 'Network type') {
      # Successfully scanned networks - location services are working
      $r.LocationServices = $true
    } 
    # Edge case: empty results but no error
    elseif ($wlanScan -match 'There are 0 networks') {
      # No networks found but scan worked - location services are enabled
      $r.LocationServices = $true
    }
    else {
      # Command succeeded but output is unclear - try to be permissive
      $r.Warnings += 'Location services status unclear from netsh output - attempting to proceed'
      $r.LocationServices = $true
    }
  } catch { 
    $r.Issues += "Wi-Fi scan test failed: $($_.Exception.Message)" 
    $r.LocationServices = $false
  }
  
  # Check admin rights
  try {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $r.AdminRights = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $r.AdminRights) { 
      $r.Warnings += 'Running without administrator privileges (some features may be limited)' 
    }
  } catch { 
    $r.Warnings += 'Could not determine privilege level' 
  }
  
  $r.OverallStatus = $r.LocationServices -and $r.WiFiAdapter
  return $r
}

function Get-UserPreference {
  try {
    $prefPath = Join-Path $env:APPDATA 'WiFiAnalyzer_Preference.txt'
    if (Test-Path $prefPath) { return Get-Content $prefPath -Raw }
  } catch { Write-Verbose "Get preference failed: $($_.Exception.Message)" }
  return $null
}

function Save-UserPreference([string]$preference) {
  try {
    $prefPath = Join-Path $env:APPDATA 'WiFiAnalyzer_Preference.txt'
    if ($PSCmdlet.ShouldProcess($prefPath,'Save user preference')) {
      $preference | Set-Content -Path $prefPath -Encoding UTF8
    }
    Write-Information "Preference saved: $preference"
  } catch { Write-Verbose "Save preference failed: $($_.Exception.Message)" }
}

# -------------------------------
# Guided / Quick flows
# -------------------------------
function Invoke-GuidedSetup {
  Write-Verbose 'Starting Guided Setup'
  try {
    do {
      $p = Test-Prerequisites
      if ($p.OverallStatus) {
        [Windows.Forms.MessageBox]::Show("All system requirements are met!`n`nStarting Wi-Fi Analyzer...",'System Check Passed',[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Information) | Out-Null
        return $true
      }
      $msg = "System requirements check found issues:`n`n" + ($p.Issues | ForEach-Object { "X $_" } | Out-String) + ($p.Warnings | ForEach-Object { "! $_" } | Out-String) + "`nWould you like to fix these issues?"
      $res = [Windows.Forms.MessageBox]::Show($msg,'System Requirements',[Windows.Forms.MessageBoxButtons]::YesNoCancel,[Windows.Forms.MessageBoxIcon]::Warning)
      switch ($res) {
        'Yes' {
          try {
            if ($PSCmdlet.ShouldProcess('ms-settings:privacy-location','Open Settings')) { Start-Process 'ms-settings:privacy-location' | Out-Null }
            [Windows.Forms.MessageBox]::Show('Please enable Location Services and click OK to recheck.','Fix Issues') | Out-Null
          } catch { [Windows.Forms.MessageBox]::Show('Open Settings > Privacy and security > Location','Manual Setup Required') | Out-Null }
          continue
        }
        'No'  {
          $c = [Windows.Forms.MessageBox]::Show('Continue anyway? The Wi-Fi analyzer may not work properly.','Continue with Issues?',[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Question)
          return ($c -eq 'Yes')
        }
        default { return $false }
      }
    } while ($true)
  } catch {
    [Windows.Forms.MessageBox]::Show("An error occurred during guided setup: $($_.Exception.Message)",'Guided Setup Error',[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    return $false
  }
}

function Invoke-QuickStart {
  Write-Verbose 'Quick Start validation'
  try {
    $p = Test-Prerequisites
    if (-not $p.OverallStatus) {
      $msg = "Quick validation found potential issues:`n`n" + ($p.Issues | ForEach-Object { "* $_" } | Out-String) + "`nContinue anyway?"
      $res = [Windows.Forms.MessageBox]::Show($msg,'Quick Start - Issues',[Windows.Forms.MessageBoxButtons]::YesNo,[Windows.Forms.MessageBoxIcon]::Warning)
      if ($res -eq 'No') { return $false }
    }
    return $true
  } catch {
    [Windows.Forms.MessageBox]::Show("An error occurred during quick start: $($_.Exception.Message)",'Quick Start Error',[Windows.Forms.MessageBoxButtons]::OK,[Windows.Forms.MessageBoxIcon]::Error) | Out-Null
    return $false
  }
}

# -------------------------------
# Export (TXT/HTML/CSV)
# -------------------------------
function Export-WiFiReport {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter(Mandatory)][pscustomobject[]]$Networks,
    [ValidateSet('TXT','HTML','CSV')][string]$OutputFormat='TXT',
    [ValidateScript({ if($_ -and -not (Test-Path $_ -PathType Container)){ throw 'OutputPath must be an existing folder'; } $true })]
    [string]$OutputPath,
    [switch]$SkipReportInfo,
    $Mac,$RecommendedChannels,$ComputerName,$IpAddress,$UserInfo,$ConnectedSSID,$ConnectedBSSID,$ConnectedChannel,$SpeedTest,$CongestionData
  )
  if ($OutputPath) {
    $targetDir = $OutputPath
  } else {
    $targetDir = [Environment]::GetFolderPath('Desktop')
  }
  $filePath  = Join-Path $targetDir ("WiFi_Analysis_Report." + $OutputFormat.ToLower())
  if (-not $PSCmdlet.ShouldProcess($filePath,"Export Wi-Fi report ($OutputFormat)")) { return }

  switch ($OutputFormat) {
    'TXT'  {
      $lines = @()
      $lines += 'Wi-Fi Analysis Report'
      $lines += ('=' * 25)
      if (-not $SkipReportInfo -and $UserInfo) {
        $lines += 'Submitted By:'
        $lines += "Name         : $($UserInfo.Name)"
        $lines += "ID Number    : $($UserInfo.ID)"
        $lines += "Email        : $($UserInfo.Email)"
        $lines += "Telephone    : $($UserInfo.Phone)"
        $lines += "Building     : $($UserInfo.Building)"
        $lines += "Room Number  : $($UserInfo.RoomNumber)"
        $lines += ''
      }
      $lines += 'System Info:'
      $lines += "Computer Name      : $ComputerName"
      $lines += "Computer IP        : $IpAddress"
      $lines += "Wi-Fi MAC Address  : $Mac"
      $lines += "Connected SSID     : $ConnectedSSID ($ConnectedBSSID)"
      if ($ConnectedChannel) {
        $lines += "Connected Channel  : $ConnectedChannel"
      }
      $lines += ''
      if ($SpeedTest.Status -eq 'Success') { $lines += "Download Speed    : $($SpeedTest.DownloadSpeed) Mbps"; $lines += "Latency           : $($SpeedTest.Latency) ms" }
      else {
        $lines += "Speed Test        : $($SpeedTest.Status)"
        if ($SpeedTest.Details) {
          $lines += "Test Details      : $($SpeedTest.Details)"
        }
      }
      $lines += ''
      $lines += ("{0,-35} {1,-10} {2,-10} {3,-15} {4,-10} {5,-10} {6,-15}" -f 'SSID','Signal(%)','Channel','Security','Quality','Band','Width')
      $lines += ('-'*105)
      foreach ($n in $Networks) {
        if ($n.SSID -eq $ConnectedSSID -and $n.BSSID -eq $ConnectedBSSID) {
          $ssidLbl = "[*] $($n.SSID)"
        } else {
          $ssidLbl = $n.SSID
        }
        $qual, $null = Get-SignalColor $n.Signal
        $lines += ("{0,-35} {1,-10} {2,-10} {3,-15} {4,-10} {5,-10} {6,-15}" -f $ssidLbl,$n.Signal,$n.Channel,$n.Security,$qual,$n.Band,$n.Width)
      }
      $lines | Set-Content -Path $filePath -Encoding UTF8
    }
    'CSV'  {
      $csv = $Networks | Select-Object SSID,BSSID,Signal,Channel,Security,Width,Band | ConvertTo-Csv -NoTypeInformation
      $csv | Set-Content -Path $filePath -Encoding UTF8
    }
    'HTML' {
      $rows = $Networks | ForEach-Object { "<tr><td>$($_.SSID)</td><td>$($_.BSSID)</td><td>$($_.Signal)</td><td>$($_.Channel)</td><td>$($_.Security)</td><td>$($_.Band)</td><td>$($_.Width)</td></tr>" }
      $html = @(
        '<!doctype html>','<meta charset="utf-8"/>','<title>Wi-Fi Analysis Report</title>',
        '<style>body{font-family:Segoe UI,Arial,sans-serif;margin:24px} table{border-collapse:collapse;width:100%} th,td{border:1px solid #ddd;padding:8px} th{background:#f4f6f8;text-align:left}</style>',
        '<h1>Wi-Fi Analysis Report</h1>',
        '<h2>System</h2>',
        ("<p><b>Computer:</b> {0} | <b>IP:</b> {1} | <b>MAC:</b> {2} | <b>Connected:</b> {3} ({4})</p>" -f $ComputerName,$IpAddress,$Mac,$ConnectedSSID,$ConnectedBSSID),
        '<h2>Networks</h2>','<table><thead><tr><th>SSID</th><th>BSSID</th><th>Signal</th><th>Channel</th><th>Security</th><th>Band</th><th>Width</th></tr></thead><tbody>',
        $rows,
        '</tbody></table>'
      ) -join "`n"
      $html | Set-Content -Path $filePath -Encoding UTF8
    }
  }
  [Windows.Forms.MessageBox]::Show("Report exported to: $filePath","Export Complete") | Out-Null
}

# -------------------------------
# GUI
# -------------------------------
function Show-MainWiFiAnalyzerForm {
  $form = New-Object Windows.Forms.Form
  $form.Text = 'Wi-Fi Analyzer'
  $form.Size = New-Object Drawing.Size(850,600)
  $form.StartPosition = 'CenterScreen'
  $form.Padding = New-Object Windows.Forms.Padding(15)

  $btnScan   = New-Object Windows.Forms.Button; $btnScan.Text='Scan Wi-Fi'; $btnScan.Size=New-Object Drawing.Size(120,35); $btnScan.Location=New-Object Drawing.Point(20,20); $btnScan.Font=New-Object Drawing.Font('Segoe UI',10)
  $btnExport = New-Object Windows.Forms.Button; $btnExport.Text='Export';   $btnExport.Size=New-Object Drawing.Size(120,35); $btnExport.Location=New-Object Drawing.Point(160,20); $btnExport.Enabled=$false; $btnExport.Font=New-Object Drawing.Font('Segoe UI',10)
  $rtb       = New-Object Windows.Forms.RichTextBox; $rtb.Multiline=$true; $rtb.ScrollBars='Vertical'; $rtb.Location=New-Object Drawing.Point(20,70); $rtb.Size=New-Object Drawing.Size(790,470); $rtb.Font=New-Object Drawing.Font('Consolas',10); $rtb.BackColor=[Drawing.Color]::White
  $form.Controls.AddRange(@($btnScan,$btnExport,$rtb))

  $btnScan.Add_Click({
    $rtb.Text = 'Scanning Wi-Fi networks and analyzing environment...'
    $extras = Get-ComputerInfoExtras; $app.ComputerName=$extras.ComputerName; $app.IpAddress=$extras.IPAddress
    $app.Networks = Get-WiFiScan; $app.Mac = Get-MACAddress
    $ssidInfo = Get-ConnectedSSID; $app.ConnectedSsid=$ssidInfo.SSID; $app.ConnectedBssid=$ssidInfo.BSSID; $app.ConnectedChannel=$ssidInfo.Channel
    $rec = Get-BestChannel $app.Networks; $app.Recommended=@{ '2.4GHz'=$rec.'2.4GHz'; '5GHz'=$rec.'5GHz' }; $app.CongestionData=$rec.CongestionData

    $rtb.Clear()
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Computer Name     : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.ComputerName)`r`n")
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Computer IP       : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.IpAddress)`r`n")
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Wi-Fi MAC Address : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.Mac)`r`n")
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Connected SSID    : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.ConnectedSsid) ($($app.ConnectedBssid))`r`n")
    if ($app.ConnectedChannel) {
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Connected Channel : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.ConnectedChannel)`r`n")
    }
    $rtb.AppendText("`r`n")

    $rtb.AppendText("Running network speed test... Please wait...`r`n")
    $app.SpeedTest = Test-NetworkSpeed
    if ($app.SpeedTest.Status -eq 'Success') {
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Download Speed    : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.SpeedTest.DownloadSpeed) Mbps`r`n")
      if ($app.SpeedTest.UploadSpeed -gt 0) {
        $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Upload Speed      : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.SpeedTest.UploadSpeed) Mbps`r`n")
      }
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Latency           : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.SpeedTest.Latency) ms`r`n`r`n")
    } elseif ($app.SpeedTest.Status -match 'Partial') {
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Latency           : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.AppendText("$($app.SpeedTest.Latency) ms`r`n")
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Speed Test Status : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.SelectionColor='Orange'; $rtb.AppendText("Limited - Download test unavailable`r`n`r`n"); $rtb.SelectionColor='Black'
    } else {
      $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText('Speed Test Failed : '); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10); $rtb.SelectionColor='Red'; $rtb.AppendText("$($app.SpeedTest.Status)`r`n"); $rtb.SelectionColor='Black'; $rtb.AppendText("Note: Speed testing may be limited on restricted networks.`r`n`r`n")
    }

    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',11,[Drawing.FontStyle]::Bold); $rtb.AppendText("Nearby Networks:`r`n")
    $rtb.SelectionFont=New-Object Drawing.Font('Consolas',10,[Drawing.FontStyle]::Bold); $rtb.AppendText(("{0,-35} {1,-10} {2,-10} {3,-15} {4,-10} {5,-10} {6,-15}`r`n" -f 'SSID','Signal(%)','Channel','Security','Quality','Band','Width'))
    $rtb.AppendText((''.PadRight(115,'-')) + "`r`n"); $rtb.SelectionFont=New-Object Drawing.Font('Consolas',10)

    foreach ($n in $app.Networks) {
      if ($n.SSID -eq $app.ConnectedSsid -and $n.BSSID -eq $app.ConnectedBssid) {
        $ssidLbl = "[*] $($n.SSID)"
      } else {
        $ssidLbl = $n.SSID
      }
      $qual,$qColor = Get-SignalColor $n.Signal; $secLbl,$secColor = Get-SecurityColor $n.Security
      $rtb.SelectionColor='Black';  $rtb.AppendText(("{0,-35} " -f $ssidLbl))
      $rtb.SelectionColor=$qColor;  $rtb.AppendText(("{0,-10} " -f $n.Signal))
      $rtb.SelectionColor='Black';  $rtb.AppendText(("{0,-10} " -f $n.Channel))
      $rtb.SelectionColor=$secColor;$rtb.AppendText(("{0,-15} " -f $secLbl))
      $rtb.SelectionColor=$qColor;  $rtb.AppendText(("{0,-10} " -f $qual))
      $rtb.SelectionColor='Black';  $rtb.AppendText(("{0,-10} " -f $n.Band))
      $rtb.SelectionColor='Black';  $rtb.AppendText(("{0,-15}`r`n" -f $n.Width))
    }

    # Congestion summary
    $rtb.SelectionColor='Black'; $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',11,[Drawing.FontStyle]::Bold); $rtb.AppendText("`r`nChannel Congestion Analysis:`r`n")
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText("2.4 GHz Band:`r`n"); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10)
    $c24 = $app.CongestionData.GetEnumerator() | Where-Object { $_.Name -le 14 } | Sort-Object Name
    foreach ($ch in $c24) {
      if ($ch.Value -gt 150) {
        $lvl = 'High'
      } elseif ($ch.Value -gt 75) {
        $lvl = 'Medium'
      } else {
        $lvl = 'Low'
      }
      $rtb.AppendText("  Channel $($ch.Name): $lvl congestion (Score: $([math]::Round($ch.Value,1)))`r`n")
    }
    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $rtb.AppendText("`r`n5 GHz Band:`r`n"); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10)
    $c5 = $app.CongestionData.GetEnumerator() | Where-Object { $_.Name -gt 14 } | Sort-Object Name
    foreach ($ch in $c5) {
      if ($ch.Value -gt 150) {
        $lvl = 'High'
      } elseif ($ch.Value -gt 75) {
        $lvl = 'Medium'
      } else {
        $lvl = 'Low'
      }
      $rtb.AppendText("  Channel $($ch.Name): $lvl congestion (Score: $([math]::Round($ch.Value,1)))`r`n")
    }

    $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',11,[Drawing.FontStyle]::Bold); $rtb.AppendText("`r`nRecommended Channels:`r`n"); $rtb.SelectionFont=New-Object Drawing.Font('Segoe UI',10)
    $rtb.AppendText("2.4 GHz Band: Channel $($app.Recommended.'2.4GHz')`r`n"); $rtb.AppendText("5 GHz Band  : Channel $($app.Recommended.'5GHz')`r`n`r`n")

    $btnExport.Enabled = $app.Networks.Count -gt 0
  })

  $btnExport.Add_Click({
    if ($app.Networks.Count -gt 0) {
      $userInfo = Show-ExportInfoForm
      if ($userInfo) {
        Export-WiFiReport -Networks $app.Networks -Mac $app.Mac -RecommendedChannels $app.Recommended -ComputerName $app.ComputerName -IpAddress $app.IpAddress -UserInfo $userInfo -ConnectedSSID $app.ConnectedSsid -ConnectedBSSID $app.ConnectedBssid -ConnectedChannel $app.ConnectedChannel -SpeedTest $app.SpeedTest -CongestionData $app.CongestionData -OutputFormat 'TXT'
      }
    } else {
      [Windows.Forms.MessageBox]::Show('Nothing to export. Please run a scan first.','Export Error') | Out-Null
    }
  })

  [void]$form.ShowDialog()
}

function Show-ExportInfoForm {
  $f = New-Object Windows.Forms.Form; $f.Text='Export Info'; $f.Size=New-Object Drawing.Size(400,360); $f.StartPosition='CenterScreen'
  $labels = @('Your Name:','ID Number:','Email Address:','Telephone Number:','Building:','Room Number:'); $textboxes = @()
  for ($i=0; $i -lt $labels.Count; $i++) {
    $l=New-Object Windows.Forms.Label; $l.Text=$labels[$i]; $l.Location=New-Object Drawing.Point(20,(30+($i*40))); $l.Size=New-Object Drawing.Size(120,20); $f.Controls.Add($l)
    $t=New-Object Windows.Forms.TextBox; $t.Location=New-Object Drawing.Point(150,(30+($i*40))); $t.Size=New-Object Drawing.Size(220,20); $f.Controls.Add($t); $textboxes+=$t
  }
  $ok=New-Object Windows.Forms.Button; $ok.Text='OK'; $ok.Location=New-Object Drawing.Point(150,270); $ok.Size=New-Object Drawing.Size(100,30); $ok.DialogResult=[Windows.Forms.DialogResult]::OK; $f.AcceptButton=$ok; $f.Controls.Add($ok)
  if ($f.ShowDialog() -eq 'OK') {
    return @{ Name=$textboxes[0].Text; ID=$textboxes[1].Text; Email=$textboxes[2].Text; Phone=$textboxes[3].Text; Building=$textboxes[4].Text; RoomNumber=$textboxes[5].Text }
  } else {
    return $null
  }
}

# -------------------------------
# Startup choice dialog & flow
# -------------------------------
function Show-StartupChoiceDialog {
  $frm = New-Object Windows.Forms.Form; $frm.Text='Wi-Fi Analyzer - Startup Options'; $frm.Size=New-Object Drawing.Size(520,420); $frm.StartPosition='CenterScreen'; $frm.FormBorderStyle='FixedDialog'; $frm.MaximizeBox=$false; $frm.MinimizeBox=$false
  $hdr=New-Object Windows.Forms.Label; $hdr.Text='Wi-Fi Analyzer'; $hdr.Location=New-Object Drawing.Point(20,20); $hdr.Size=New-Object Drawing.Size(470,30); $hdr.Font=New-Object Drawing.Font('Segoe UI',16,[Drawing.FontStyle]::Bold); $hdr.ForeColor='DarkBlue'; $hdr.TextAlign='MiddleCenter'; $frm.Controls.Add($hdr)
  $sub=New-Object Windows.Forms.Label; $sub.Text='Choose your startup preference:'; $sub.Location=New-Object Drawing.Point(20,60); $sub.Size=New-Object Drawing.Size(470,20); $sub.Font=New-Object Drawing.Font('Segoe UI',10); $sub.TextAlign='MiddleCenter'; $frm.Controls.Add($sub)
  $p1=New-Object Windows.Forms.Panel; $p1.Location=New-Object Drawing.Point(30,100); $p1.Size=New-Object Drawing.Size(450,90); $p1.BorderStyle='FixedSingle'; $p1.BackColor='LightBlue'; $frm.Controls.Add($p1)
  $b1=New-Object Windows.Forms.Button; $b1.Text='[G] Guided Setup (Recommended)'; $b1.Location=New-Object Drawing.Point(10,10); $b1.Size=New-Object Drawing.Size(280,35); $b1.Font=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $b1.BackColor='White'; $p1.Controls.Add($b1)
  $d1=New-Object Windows.Forms.Label; $d1.Text='Checks system requirements and guides you through setup.`r`nPerfect for first-time users or troubleshooting.'; $d1.Location=New-Object Drawing.Point(10,50); $d1.Size=New-Object Drawing.Size(430,35); $d1.Font=New-Object Drawing.Font('Segoe UI',9); $p1.Controls.Add($d1)
  $p2=New-Object Windows.Forms.Panel; $p2.Location=New-Object Drawing.Point(30,210); $p2.Size=New-Object Drawing.Size(450,90); $p2.BorderStyle='FixedSingle'; $p2.BackColor='LightGreen'; $frm.Controls.Add($p2)
  $b2=New-Object Windows.Forms.Button; $b2.Text='[Q] Quick Start'; $b2.Location=New-Object Drawing.Point(10,10); $b2.Size=New-Object Drawing.Size(150,35); $b2.Font=New-Object Drawing.Font('Segoe UI',10,[Drawing.FontStyle]::Bold); $b2.BackColor='White'; $p2.Controls.Add($b2)
  $d2=New-Object Windows.Forms.Label; $d2.Text='Skip setup checks and go straight to Wi-Fi scanning.`r`nFor experienced users who already configured their system.'; $d2.Location=New-Object Drawing.Point(10,50); $d2.Size=New-Object Drawing.Size(430,35); $d2.Font=New-Object Drawing.Font('Segoe UI',9); $p2.Controls.Add($d2)
  $tip=New-Object Windows.Forms.Label; $tip.Text='Tip: You can skip this dialog next time using command line parameters'; $tip.Location=New-Object Drawing.Point(30,320); $tip.Size=New-Object Drawing.Size(450,15); $tip.Font=New-Object Drawing.Font('Segoe UI',8,[Drawing.FontStyle]::Italic); $tip.ForeColor='Gray'; $frm.Controls.Add($tip)
  $chk=New-Object Windows.Forms.CheckBox; $chk.Text='Remember my choice'; $chk.Location=New-Object Drawing.Point(30,340); $chk.Size=New-Object Drawing.Size(200,20); $chk.Font=New-Object Drawing.Font('Segoe UI',9); $frm.Controls.Add($chk)
  $frm.Tag = @{ Choice=$null; Remember=$false }
  $b1.Add_Click({ $frm.Tag.Choice='Guided'; $frm.Tag.Remember=$chk.Checked; $frm.DialogResult=[Windows.Forms.DialogResult]::OK; $frm.Close() })
  $b2.Add_Click({ $frm.Tag.Choice='Quick';  $frm.Tag.Remember=$chk.Checked; $frm.DialogResult=[Windows.Forms.DialogResult]::OK; $frm.Close() })
  $res = $frm.ShowDialog()
  if ($res -eq [Windows.Forms.DialogResult]::OK) {
    if ($frm.Tag.Remember -and $frm.Tag.Choice) { Save-UserPreference $frm.Tag.Choice }
    return $frm.Tag.Choice
  } else {
    return 'Cancel'
  }
}

# -------------------------------
# Help & combined entrypoint
# -------------------------------
function Show-Help {
@"
Wi-Fi Analyzer — Usage

INTERACTIVE MODE (Default)
  .\WiFiAnalyzer.ps1

COMMAND LINE OPTIONS
  -QuickStart              Skip checks and scan immediately
  -SkipPreflightCheck      Alias for -QuickStart
  -Verbose                 Show verbose diagnostics

PREFERENCES
  Stored in %APPDATA%\WiFiAnalyzer_Preference.txt
  Delete the file to reset.

EXAMPLES
  .\WiFiAnalyzer.ps1 -QuickStart -Verbose
"@ | Write-Host -ForegroundColor Cyan
}

# Relaunch in STA for GUI flows
if ([Threading.Thread]::CurrentThread.ApartmentState -ne 'STA' -and -not ($QuickStart -or $SkipPreflightCheck)) {
  $ps = (Get-Process -Id $PID).Path
  $args = "-STA -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" " + ($MyInvocation.UnboundArguments -join ' ')
  Start-Process -FilePath $ps -ArgumentList $args | Out-Null
  return
}

function Invoke-WiFiAnalyzer {
  if ($args -contains '-help' -or $args -contains '--help' -or $args -contains '/?') {
    Show-Help
    return
  }
  if ($QuickStart -or $SkipPreflightCheck) {
    if (Invoke-QuickStart) {
      Show-MainWiFiAnalyzerForm
    } else {
      Write-Information 'Quick start cancelled'
    }
    return
  }
  $pref = Get-UserPreference
  if ($pref) {
    switch ($pref.Trim()) {
      'Guided' {
        if (Invoke-GuidedSetup) { Show-MainWiFiAnalyzerForm }
        return
      }
      'Quick' {
        if (Invoke-QuickStart) { Show-MainWiFiAnalyzerForm }
        return
      }
    }
  }
  $choice = Show-StartupChoiceDialog
  switch ($choice) {
    'Guided' {
      if (Invoke-GuidedSetup) { Show-MainWiFiAnalyzerForm }
    }
    'Quick' {
      if (Invoke-QuickStart) { Show-MainWiFiAnalyzerForm }
    }
    default {
      Write-Information 'Startup cancelled'
    }
  }
}

# Export dialog helper used above
function Show-ExportInfoForm {  # (redeclared to ensure forward reference in single-file script)
  $form = New-Object System.Windows.Forms.Form
  $form.Text = 'Export Info'; $form.Size = New-Object System.Drawing.Size(400, 360); $form.StartPosition = 'CenterScreen'
  $labels = @('Your Name:', 'ID Number:', 'Email Address:', 'Telephone Number:', 'Building:', 'Room Number:')
  $textboxes = @()
  for ($i = 0; $i -lt $labels.Count; $i++) {
    $label = New-Object System.Windows.Forms.Label; $label.Text = $labels[$i]; $label.Location = New-Object System.Drawing.Point(20, (30 + ($i * 40))); $label.Size = New-Object System.Drawing.Size(120, 20); $form.Controls.Add($label)
    $textbox = New-Object System.Windows.Forms.TextBox; $textbox.Location = New-Object System.Drawing.Point(150, (30 + ($i * 40))); $textbox.Size = New-Object System.Drawing.Size(220, 20); $form.Controls.Add($textbox); $textboxes += $textbox
  }
  $okButton = New-Object System.Windows.Forms.Button; $okButton.Text = 'OK'; $okButton.Location = New-Object System.Drawing.Point(150, 270); $okButton.Size = New-Object System.Drawing.Size(100, 30); $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK; $form.AcceptButton = $okButton; $form.Controls.Add($okButton)
  if ($form.ShowDialog() -eq 'OK') {
    return @{ Name = $textboxes[0].Text; ID = $textboxes[1].Text; Email = $textboxes[2].Text; Phone = $textboxes[3].Text; Building = $textboxes[4].Text; RoomNumber = $textboxes[5].Text }
  } else {
    return $null
  }
}

# Convenience: all-in-one automation entry
function Invoke-WiFiAnalyzerAll {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [switch]$SkipReportInfo,
    [ValidateSet('TXT','HTML','CSV')][string]$OutputFormat='TXT',
    [ValidateScript({ if($_ -and -not (Test-Path $_ -PathType Container)){ throw 'OutputPath must be an existing folder' } $true })]
    [string]$OutputPath
  )
  $nets = Get-WiFiScan
  $mac  = Get-MACAddress
  $ext  = Get-ComputerInfoExtras
  $ssid = Get-ConnectedSSID
  $rec  = Get-BestChannel $nets
  $spd  = Test-NetworkSpeed
  if ($SkipReportInfo) {
    $user = @{ Name=''; ID=''; Email=''; Phone=''; Building=''; RoomNumber='' }
  } else {
    $user = Show-ExportInfoForm
  }
  if (-not $user) { Write-Information 'User cancelled info collection. Aborting export.'; return }
  Export-WiFiReport -Networks $nets -Mac $mac -RecommendedChannels $rec -ComputerName $ext.ComputerName -IpAddress $ext.IPAddress -UserInfo $user -ConnectedSSID $ssid.SSID -ConnectedBSSID $ssid.BSSID -ConnectedChannel $ssid.Channel -SpeedTest $spd -CongestionData $rec.CongestionData -OutputFormat $OutputFormat -OutputPath $OutputPath
  Write-Information 'Wi-Fi analysis and report export complete.'
}

# Entry point
Invoke-WiFiAnalyzer
