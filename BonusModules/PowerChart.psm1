####  Before this will work, YOU MUST HAVE:
####   INSTALLED the JUNE WPF Toolkit http://wpf.codeplex.com 
####   INSTALLED, and IMPORTED in your current session, the PowerBoots Module

if(Get-Command New-System.Windows.VisualState) {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   ForEach { [Reflection.Assembly]::LoadFrom( $_.FullName ) } | Out-Null
   
   $Error.Clear()
   
   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
} else {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   Add-BootsFunction

   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
}

Add-BootsTemplate C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\XamlTemplates\PowerCharting.xaml

# . C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\New-PowerChart.ps1
# New-PowerChart Area { ls | ? {!$_.PSIsContainer} } Name Length -Background White
# New-PowerChart Pie { ls | ?{!$_.PSIsContainer} } Name Length

function Ping-Host {
   New-Object PSObject | 
   Add-Member NoteProperty   Time $(Get-Date) -Passthru |
   Add-Member NoteProperty   Ping $([int]([regex]"time=(\d+)ms").Match( (ping.exe $args[0] -n 1) ).Groups[1].Value) -Passthru | 
   Add-Member ScriptProperty Age  { ($(Get-Date) - $this.Time).TotalMinutes } -Passthru
}

## Bind to a queue to hold the most recent 20 items for the chart
#  $global:pings = new-object system.collections.queue 21
#  $global:pings.Enqueue($(Ping-Host "huddledmasses.org"))
#  New-PowerChart Line { 
#     $global:pings.Enqueue( (Ping-Host huddledmasses.org) )
#     if($pings.Count -gt 20) { $pings.Dequeue()|Out-Null } 
#     Write-Output $pings
#  } Age Ping -Interval "00:00:02"                                      

#  Boots { 
#     $global:timer = DispatcherTimer -Interval "00:00:10" -On_Tick { $series.ItemsSource = ls | ? { !$_.PsIsContainer } }
#     Chart { PieSeries -DependentValuePath Length -IndependentValuePath Name | Tee -var global:series }
#     $timer.Start()
#  } -On_Closed { $timer.Stop() }


function New-PowerChart() {
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
# #region Params
param(
   [Parameter(Position=0, Mandatory=$true)]
   [ValidateSet("Area","Bar","Bubble","Column","Line","Pie","Scatter")]
   [String[]]
   ${ChartType}
,
   [Parameter(Position=1, Mandatory=$true, HelpMessage='The data for the chart ...')]
   [System.Management.Automation.ScriptBlock[]]
   ${ItemsSource}
,
   [Parameter(Position=2, Mandatory=$true, HelpMessage='The property name for the independent values ...')]
   [String[]]
   ${IndependentValuePath}
,  
   [Parameter(Position=3, Mandatory=$true, HelpMessage='The property name for the dependent values ...')]
   [String[]]
   ${DependentValuePath}
,
   [Parameter(Position=4, HelpMessage='The property name for the size values ...')]
   [String[]]
   ${SizeValuePath}
,  
   [TimeSpan]    
   ${Interval}
)
# #endregion

begin
{
   $BootsWindow.Tag = @{ 
      "ChartType" = $ChartType
      "ItemsSource" = $ItemsSource
      "DependentValuePath" = $DependentValuePath
      "IndependentValuePath" = $IndependentValuePath
      "Interval" = $Interval
      "Series" = @()
   }


   if($Interval) {
      # Write-Host "Setting Udpate Interval to $($BootsWindow.Tag.Interval)" -Fore Cyan
         
      $BootsWindow.Tag.Timer = DispatcherTimer -Interval $Interval -Tag $BootsWindow.Tag -On_Tick {
                        # Write-Host "tick. " -nonewline -fore cyan
                        $i=0
                        $BootsWindow.Tag.Series | ForEach{ $_.ItemsSource = &$($BootsWindow.Tag.ItemsSource[$i++]) }
                     }
      $this.Add_Loaded( { $BootsWindow.Tag.Timer.Start() } )
      $this.Add_Closed( { $BootsWindow.Tag.Timer.Stop() } )
   }
   Chart {
      # Write-Host "Three" -Fore Cyan
      for($c=0; $c -lt $BootsWindow.Tag.ChartType.length; $c++) {
         $chartType = $BootsWindow.Tag.ChartType[$c].ToLower()
         if($BootsWindow.Tag.SizeValuePath -and $BootsWindow.Tag.ChartType[$c] -eq "Bubble") {
            # Write-Host "$($this.tag.ChartType[$c])Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -SizeValuePath $($BootsWindow.Tag.SizeValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])}) -DataPointStyle `$this.FindResource('$($this.tag.ChartType[$c])DataPointTooltipsFix')"
            $BootsWindow.Tag.Series += iex "$($chartType)Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -SizeValuePath $($BootsWindow.Tag.SizeValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])})" # -DataPointStyle `$this.FindResource('$($BootsWindow.Tag.ChartType[$c])DataPointTooltipsFix')"
            $BootsWindow.Tag.Series[-1].DataPointStyle = $this.FindResource("$($chartType)DataPointTooltipsFix")
         } elseif($BootsWindow.Tag.ChartType[$c] -eq "Pie") {                                                                                                                                                          
            # Write-Host "$($this.tag.ChartType[$c])Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])}) -StylePalette =  `$this.FindResource('$($this.tag.ChartType[$c])PaletteTooltipsFix')"
            $BootsWindow.Tag.Series += iex "$($chartType)Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])})"# -StylePalette `$this.FindResource('$($chartType)PaletteTooltipsFix')"
            $BootsWindow.Tag.Series[-1].StylePalette = $this.FindResource("$($chartType)PaletteTooltipsFix")
         } else {                                                                                                                                                          
            # Write-Host "$($this.tag.ChartType[$c])Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])}) -DataPointStyle `$this.FindResource('$($this.tag.ChartType[$c])DataPointTooltipsFix')"
            $BootsWindow.Tag.Series += iex "$($chartType)Series -DependentValuePath $($BootsWindow.Tag.DependentValuePath[$c]) -IndependentValuePath $($BootsWindow.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($BootsWindow.Tag.ItemsSource[$c])})" #-DataPointStyle `$this.FindResource('$($chartType)DataPointTooltipsFix')"
            #$global:bind = $BootsWindow.Tag.Series[-1].SetResourceReference( ($BootsWindow.Tag.Series[-1].GetType()::DataPointStyleProperty), "$($chartType)DataPointTooltipsFix")
            $BootsWindow.Tag.Series[-1].DataPointStyle = $this.FindResource("$($chartType)DataPointTooltipsFix")
         }       
      }
      # Write-Host "Series: $($BootsWindow.Tag.Series.Count): $($BootsWindow.Tag.Series)" -Fore Green
      $BootsWindow.Tag.Series
      # Write-Host "Four" -Fore Cyan
   } -Background Transparent -BorderThickness 0
   # Write-Host "Five" -Fore Green
}
}

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSY0AyYcKVzdseV1+hKsru7UA
# BfugggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTEwMDUxNDAwMDAwMFoXDTExMDUxNDIzNTk1OVowgZUx
# CzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUwNjg1MDEUMBIGA1UECAwLQ29ubmVjdGlj
# dXQxEDAOBgNVBAcMB05vcndhbGsxFjAUBgNVBAkMDTQ1IEdsb3ZlciBBdmUxGjAY
# BgNVBAoMEVhlcm94IENvcnBvcmF0aW9uMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfUdxwiuWDb8zId
# KuMg/jw0HndEcIsP5Mebw56t3+Rb5g4QGMBoa8a/N8EKbj3BnBQDJiY5Z2DGjf1P
# n27g2shrDaNT1MygjYfLDntYzNKMJk4EjbBOlR5QBXPM0ODJDROg53yHcvVaXSMl
# 498SBhXVSzPmgprBJ8FDL00o1IIAAhYUN3vNCKPBXsPETsKtnezfzBg7lOjzmljC
# mEOoBGT1g2NrYTq3XqNo8UbbDR8KYq5G101Vl0jZEnLGdQFyh8EWpeEeksv7V+YD
# /i/iXMSG8HiHY7vl+x8mtBCf0MYxd8u1IWif0kGgkaJeTCVwh1isMrjiUnpWX2NX
# +3PeTmsCAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBTK0OAaUIi5wvnE8JonXlTXKWENvTAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAWGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAEss8yuj+rZvx2UFAgkz/DueB8gwqUTzFbw2prxqee
# zdCEbnrsGQMNdPMJ6v9g36MRdvAOXqAYnf1RdjNp5L4NlUvEZkcvQUTF90Gh7OA4
# rC4+BjH8BA++qTfg8fgNx0T+MnQuWrMcoLR5ttJaWOGpcppcptdWwMNJ0X6R2WY7
# bBPwa/CdV0CIGRRjtASbGQEadlWoc1wOfR+d3rENDg5FPTAIdeRVIeA6a1ZYDCYb
# 32UxoNGArb70TCpV/mTWeJhZmrPFoJvT+Lx8ttp1bH2/nq6BDAIvu0VGgKGxN4bA
# T3WE6MuMS2fTc1F8PCGO3DAeA9Onks3Ufuy16RhHqeNcMYICTDCCAkgCAQEwgaow
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIQKQm90jYWUDdv7EgFkuELajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUl7gB4xC6
# c9r8kBa/blGg7ipxKqgwDQYJKoZIhvcNAQEBBQAEggEAPoTrQ9vGz9C1aas15zWc
# 8/Y1qdHD8bMwBjOoI5jYkgR+4u1e7q1Xp4BFYrTx6BTfv2rlQHECablh+VmI68fr
# hwVLQrH5Pn7iBd1ce7twxC4jJChJwsjuZ3KaMK3uKK/3aTzkJL4KofqAtR/lZ/Hz
# I2jcVZn7a8TVZOeTRJ6jN+88ZRlDIobQG6nO0/hVJd/Qojhcm7FroFpkARqyYlW3
# BrqET6FgDc7gBr8NK+nRaczPld6h1X98mHqo38JAhQ85zmewxnSI9NqUC5hS7qjz
# RfNrXzhWOc3Pd7RgmD2p1Rpx84lPCGJQfWq75hgID5lwVON1EYzwObQtyYbcdbz6
# qA==
# SIG # End signature block
