Param([int[]]$which=0)

if(!(get-command New-Visifire.Charts.DataSeries -EA 0)){
   Add-BootsContentProperty 'DataPoints', 'Series'
   Add-UIFunction -Assembly "$ShowUI.InstallPath\BinaryAssemblies\WPFVisifire.Charts.dll"
}




switch($which) {
0 { 
@"
This script just runs the various Visifire demo scripts I've written to test Boots.
You need to pass it a number (between 1 and 5) for each sample you want to run!
"@
}
1 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Boots {
      New-Visifire.Charts.Chart -MinWidth 200 -MinHeight 150 -Theme Theme3 {
         New-Visifire.Charts.DataSeries {
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
         }
      }
   } -Title "Sample, Theme 3" -inline
}
2 {
   Write-Warning "This sample requires HttpRest and Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   [int]$tk    = (Invoke-Http get http://google.com/search -with @{q="TCL Tk"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   [int]$shoes = (Invoke-Http get http://google.com/search -with @{q="Ruby Shoes Rb"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   [int]$boots = (Invoke-Http get http://google.com/search -with @{q="PowerShell PowerBoots"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   Boots {
      New-Visifire.Charts.Chart -MinHeight 300 -MinWidth 400 {
         New-Visifire.Charts.DataSeries -RenderAs Bar {
            New-Visifire.Charts.DataPoint -YValue $tk    -AxisXLabel Tk    -Href http://google.com/search?q=TCL+Tk
            New-Visifire.Charts.DataPoint -YValue $shoes -AxisXLabel Shoes -Href http://google.com/search?q=Ruby+Shoes
            New-Visifire.Charts.DataPoint -YValue $boots -AxisXLabel Boots -Href http://google.com/search?q=PowerSHell+PowerBoots
         }
      }
   } -inline
}
3 {
   Write-Warning "This sample requires Visifire and -STA -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Write-Host "Doing an ActiveDirectory Search. This may take a long time. (Ctrl+C to cancel)"
   $ad=New-Object DirectoryServices.DirectorySearcher [ADSI]''
   # Set a limit or TimeOut, PageSize lets us get more later
   $ad.PageSize = 200

   # ADSI field names are awful.
   # l = location, l=* returns only users with locations set
   $ad.Filter = "(&(objectClass=Person)(l=*))"  
   $results = $ad.FindAll().GetEnumerator() | ForEach { $_ }
   $users   = $results | ForEach { $_.GetDirectoryEntry() }

   # "l" is a PropertyValueCollection, use the first value
   $users | Group-Object {$_.l[0]}  | ForEach { 
      New-Visifire.Charts.DataPoint -YValue ([int]$_.Count) -AxisXLabel $_.Name 
   }| New-Visifire.Charts.DataSeries -RenderAs Doughnut | 
      New-Visifire.Charts.Chart -Height 300 -Width 300  | 
      Boots -Title "AD Users by Location" -inline
}
4 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Boots {
   ls | ForEach { 
      New-Visifire.Charts.DataPoint -YValue ([DateTime]::Now - $_.LastWriteTime).TotalDays `
                -ZValue ($_.Length/1KB) `
                -AxisXLabel $_.Name -Tag $_ `
                -On_MouseLeftButtonUp { 
                  if($this.Tag) { 
                     Write-BootsOutput $this.Tag; 
                     $global:series.DataPoints.Remove($this)
                  }
               }
   } | New-Visifire.Charts.DataSeries -RenderAs Bubble -ToolTipText "#AxisXLabel`nAge: #YValue days, Size: #ZValue Kb" | 
      Tee-Object -Variable global:series |
      New-Visifire.Charts.Chart -MinHeight 350 -MinWidth 800 -Theme Theme3 
   } -inline # | Remove-Item -Confirm
}
5 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   # Write-Host "We're going to ask for your password here, so we can upload an image via FTP"
   # $credential = Get-Credential

   if($PsVersionTable) {
      ## BUG BUG: Setting boolan properties isn't working in PowerShell 1
      Write-Host "Using PowerShell 2 Version" -Fore Cyan
      New-BootsImage VisiFire-BootsImage.jpg {
         New-Visifire.Charts.Chart -Width 200 -Height 150 -Theme Theme3 -Watermark:$false -Animation:$false -Series {
            New-Visifire.Charts.DataSeries {
               1..(Get-Random -min 3 -max 6) | ForEach-Object  {
                  New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
               }
            }
         }
      }
      #| ForEach-Object { 
      #   Send-FTP HuddledMasses.org $credential -LocalFile $_ -Remotefile "$imgPath/$($_.Name)" 
      #   [Windows.Clipboard]::SetText( "!http://huddledmasses.org/images/PowerBoots/$($_.Name)!" )
      #}
   } else {
      Write-Host "Using PowerShell 1 Version" -Fore Cyan
      Boots -Title "ScreenCapWindow" {
         New-Visifire.Charts.Chart -Width 200 -Height 150 -Theme Theme3 -Watermark:$false -Animation:$false -Series {
            New-Visifire.Charts.DataSeries {
               1..(Get-Random -min 3 -max 6) | ForEach-Object  {
                  New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
               }
            }
         } | tee -var global:chart  
      } -inline
      sleep 5
      Export-BootsImage VisiFire-BootsImage.jpg $global:chart
      Remove-UIWindow "ScreenCapWindow" 
   }
}

}
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUMrYos+oGDoTwZ5/4A13GhwCb
# qDmgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUQhYEI49W
# x+wWsfCebJ5IKr1D85YwDQYJKoZIhvcNAQEBBQAEggEAc6MYXOXlpJjCbNyWhgN6
# Z7zScS8UwQUxwZf8F00RcOkWHeRjaLna44lU4Rmi+w4KZXBBCvNjbRJHs8GIHdE7
# tzuKWTprGdLdTjwW5h1fAcAKkgmh1VEXxbWH29LrRXtAmHlRzJQOqowI7j7v0XSR
# xf0DHNBvZ6o1jdgwQEthJVwDVHNjp3o/d/rzaYYxQqQHAkTuccelq2/Sa0dALISG
# u3R3lFeNphCX3UNW3ZSEw2lOquaXhjOxIQqHVSBX7qXBXZZMTBRaiRX7YJliK9E+
# N9yKP4zmd7hgD5HPcQB/nRnuUykdmoeIQkqNpkRpyE9DcAqUhsdQYv5OfOp3/a72
# 5g==
# SIG # End signature block
