function New-UIImage {
#
#.Synopsis
#   Convert a Show-UI element (WPF Visual) into an image
#.Description
#   Takes a WPF Visual element and captures it as an image, optionally saving it to file (otherwise, it's placed on the clipboard).
#.Parameter Content
#   A scriptblock that generates the element that you want to capture an image of
#.Example
#   New-UIImage Statistics.jpg {
#   	StackPanel -Margin "10,5,10,5" -Background White {
#   	   Label "Please enter your name:"
#   	   StackPanel -Orientation Horizontal {
#   	      TextBox -OutVariable global:textbox -Width 150 -On_KeyDown { 
#   	         if($_.Key -eq "Return") { 
#   	            Write-Output $textbox[0].Text
#   	            $ShowUI.ActiveWindow.Close()
#   	         }
#   	      }
#   	      Button "Ok" -Padding "5,0,5,0" -Margin "2,0,0,0" -On_Click { 
#   	         Write-Output $textbox[0].Text
#   	         $ShowUI.ActiveWindow.Close()
#   	      }
#        }
#     }
#  } 
#   
#  Take a Screenshot of an input window. NOTE: this won't capture the window chrome.
#   
#.Example
# New-UIImage Statistics.png {
#    Chart -Width 200 -Height 150 -Theme Theme3 -Watermark $false -Animation $false {
#       DataSeries {
#          1..(Get-Random -min 3 -max 6) | ForEach-Object {
#             DataPoint -YValue (Get-Random 100)
#          }
#       }
#    }
# } | ForEach-Object { 
#   Send-FTP HuddledMasses.org (Get-Credential) -LocalFile $_ -Remotefile "/public_html/$($_.Name)" 
#   [Windows.Clipboard]::SetText( "!http://HuddledMasses.org/$($_.Name)!" )
# }
#
#   Using the Visifire charting components, generate a random chart, convert it to a png image, upload it to my webserver using the NetCmdlets Send-FTP, and finally, send the new URL to the clipboard...
#   
#.Link
#   http://HuddledMasses.org/powerboots-to-image
#.ReturnValue
#   The file path, if saved to file.
#.Notes
# AUTHOR:    Joel Bennett http://HuddledMasses.org
# LASTEDIT:  2009-01-07 11:35:23
#
#[CmdletBinding(DefaultParameterSetName="ToClipboard")]
Param(
   #[Parameter(Position=0, Mandatory=$false, ParameterSetName="ToFile")]
   [string]$FileName
,
   #[Parameter(Position=1, ValueFromPipeline=$true, Mandatory=$true)]
   [ScriptBlock]$Content
,
   [double]$dpiX = 96.0
,
   [double]$dpiY = 96.0
,
   [Windows.Media.PixelFormat]$pixelFormat = "Pbgra32"
)
PROCESS {
   [ScriptBlock]$global:export = iex @"
   { Param(`$ss_win)
      `$null = Export-UIImage '$FileName' `$ss_win '$dpiX,$dpiY' '$pixelFormat'
      `$ss_win.Close()
   }
"@
   $global:bmod = Get-UIModule
   $global:Content = $Content

   $null = Show-UI -Title "ScreenCapWindow" {
      GridPanel $global:Content -Background White
   } -On_ContentRendered {
      & $global:export $this
   }

   Remove-UIWindow "ScreenCapWindow"
   $files = "{0}*{1}" -f [IO.Path]::GetFileNameWithoutExtension($FileName),
                         [IO.Path]::GetExtension($FileName)
   Write-Host $files
   Get-ChildItem $files
}
}

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUq9QLDM7o2gtk7bgT4aQjQVRJ
# zwygggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUok8Ajxgb
# 7SzuiEyae/hiz5LWCCIwDQYJKoZIhvcNAQEBBQAEggEAgdfpqMS4kpvgxt/xTY/8
# 9vcHyBXGCP+HbFNz66rIVjrNbi9s4DZi6sI1dpqBcZza5T4ACRIksE6GOdcVnBdT
# 7BuqTeYi1U9YL6k4cdhkU2/FXR9ZNxCtWBVa17iXcMgGVCdbG+MrU0e7P9TOHjBC
# MfXd8GnCAbDCj09i7oSw6v3LReqewcIjQNmZotGPsKlixVG/BGlZ5MPv7oWekjr7
# sTYi0flWJZPymdsj/WKdx6fd4fDmoa1pP0BNhLOaNbiJZdka9+biim9/lMaXWebY
# S8HFOxmrPDlB15bQ6f/qaSb1RP6yVNaQoChhBlbDqnnz8hWTYKRJ7OeEknyCZW2h
# qQ==
# SIG # End signature block
