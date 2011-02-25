if(!(Get-Command New-BootsWindow -EA SilentlyContinue)) {
   # Add-PsSnapin PoshWpf
   Import-Module PowerBoots
   Add-BootsContentProperty 'DataPoints', 'Series'
   #[Void][Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path "~\Documents\WindowsPowershell\Libraries\WPFVisifire.Charts.dll")) )
   Add-BootsFunction -Assembly "~\Documents\WindowsPowershell\Libraries\WPFVisifire.Charts.dll"
   Add-BootsFunction ([System.Windows.Threading.DispatcherTimer])
}

if(Get-Command Ping-Host -EA SilentlyContinue) {
   $pingcmd = { (Ping-Host $args[0] -count 1 -Quiet).AverageTime }
} else {
   $pingcmd = { [int]([regex]"time=(\d+)ms").Match( (ping $args[0] -n 1) ).Groups[1].Value }
}

$global:onTick = {
$window = $this.Tag
   #  Invoke-BootsWindow $window {
      try {
         foreach($s in $window.Content.Series.GetEnumerator()) {
            $ping = &$pingcmd $s.LegendText
            $points = $s.DataPoints
            foreach($dp in 0..$($points.Count - 1)) 
            {
               if(($dp+1) -eq $points.Count) {
                  $points[$dp].YValue = $ping
               } else {
                  $points[$dp].YValue = $points[$dp+1].YValue
               }
            }
         }
      } catch { 
         Write-Output $_
      }
   #  }
}

function Add-PingHost {
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string[]]$target
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,  
   [Parameter(Position=2)]
   [System.Windows.Window]$window = $global:pingWindow
,
   [Parameter()]
   [Switch]$Passthru
)
PROCESS {
   if($Window) {
      Invoke-BootsWindow $Window { 
         $target | Add-PingHostInternal -render $renderAs -window $window
      }
      return $Window
   } else {
      return New-PingMonitor -Hosts $target -RenderAs $renderAs
   }
}
}

function Add-PingHostInternal {  
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string]$target
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,  
   [Parameter(Position=2)]
   [System.Windows.Window]$window = $global:pingWindow
)
Process {
   $start = $(get-random -min 10 -max 20)
   $window.Content.Series.Add( $(
      DataSeries { 1..25 | %{DataPoint -YValue $start} } -LegendText $target -RenderAs $renderAs
   ) )
}
}

function New-PingMonitor {
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string[]]$hosts = $(Read-Host "Please enter the name of a computer to ping")
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,
   [Parameter()]
   [Switch]$Passthru
)
Process { 
   $script:renderAs = $renderAs
   $script:Hosts = $Hosts
      
   $global:pingWindow = New-BootsWindow -Async {
      Param($window) # New-Boots passes the window to us ...
      # Make a new scriptblock of the OnTick handle, passing it ourselves
      # Make a timer, and stick it in the window....
      $window.Tag = @((DispatcherTimer -Interval "00:00:01.0" -On_Tick $global:onTick -Tag $window), $global:onTick)
      
      Chart {
         foreach($h in $hosts) {
            $script:start = get-random -min 10 -max 20
            DataSeries {
               foreach($i in 1..25) {
                  DataPoint -YValue $script:start
               }
            } -LegendText $h -RenderAs $renderAs
         }
      } -watermark $false
   } -On_ContentRendered {
      $this.tag[0].Start()
   } -On_Closing { 
      $this.tag[0].Remove_Tick($this.tag[1])
      $this.tag[0].Stop()
      $global:pingWindow = $null 
      Remove-BootsWindow $this
   } -Title "Ping Monitor" -Passthru -height 300 -width 800 

   if($Passthru) {
      return $global:pingWindow
   }
}
}
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUyJ02CciZvZ3gGVRcu+eIgnPd
# Vo+gggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUXjQc/HuI
# kOqK7st6Z5Q/xj5kBWAwDQYJKoZIhvcNAQEBBQAEggEAlfrnxZ4Uxhbo1GBp9axD
# Kms8rwKYQZknBilqHP4ddzoP2TEGqJHaCUEEbM23Gy3OtUb8y0ArpYARwZU0pRE/
# xSsl02UOjjk3dJXLdnZH3XgmJ1DMumc1YoFyl0KOcw7hlGPcDBOEBFNYR+4oFil9
# r3ZuyBhPhjdJLM2i/St42e9erRo+NrtOE/gEm38tK+JlukW71ZDx3xy3qS/7AkUQ
# GqA5Tn4sdf67iS2iyPIu3ACjQHkk6m/b4Ry5HMJh0OVzVX8veMLg1YgAnTu7UYim
# YpEwo2hb2oOtZjhKhX3DWJeGb4F3MqKuVtcw0jvXNTsH3+anbt2VdvKiydfqF3fM
# bA==
# SIG # End signature block
