Import-Module PowerBoots -Global
Add-Type -AssemblyName System.Drawing

## Note that functions that are findable in module scope can be used as event handlers
## You can do this with Autoload, with GLOBAL scope, or with &$Module {} invocation:
& (Get-Module PowerBoots) {
   function Global:ConvertTo-DpiRectangle([System.Windows.Media.Visual]$visual,[System.Windows.Rect]$bounds) {
      $source = [System.Windows.PresentationSource]::FromVisual($visual)
      $matrix = $source.CompositionTarget.TransformToDevice

      $origin = $matrix.Transform( (new-object System.Windows.Point $bounds.Left, $bounds.Top) )
      $size   = $matrix.Transform( (new-object System.Windows.Point $bounds.Width,$bounds.Height) )
      return New-Object System.Drawing.Rectangle $origin.X, $origin.Y, $size.X, $size.Y
   }

   function Global:Get-VirtualScreenSize {
      return New-Object System.Windows.Rect ([System.Windows.SystemParameters]::VirtualScreenLeft), 
                                            ([System.Windows.SystemParameters]::VirtualScreenTop),
                                            ([System.Windows.SystemParameters]::VirtualScreenWidth), 
                                            ([System.Windows.SystemParameters]::VirtualScreenHeight)
   }

   function Global:ClosePopup {
      $window = $this.Parent
      if($_.Source -notmatch ".*\.(TextBox|Button)") 
      {
         $window.Close(); 
         $Global:ToastedBoots = $Global:ToastedBoots -ne $window
      }
   }
}

$Global:ToastedBoots = @()

function New-BootsToast {
   Param([string]$Message = "Something Has Happened")
   $Toast = Boots {
         Write-Host "Ok, making toast"
      Border -BorderThickness 4 -BorderBrush "#BE8" -Background "#EFC" -Width 250 -MinHeight 50 {
         Write-Host "Ok, labelling toast"
         Label $Message
      } -On_PreviewMouseLeftButtonDown ClosePopup -Name Toast -On_Loaded {
         Write-Host "Ok, loading toast"
         $Rect = Get-VirtualScreenSize
         # Write-Host "Turning $this into $($this.Parent) and Toasting it"
         $window = $this.Parent
         # Write-Host "Animate from 0 to $($window.ActualHeight), and from $($window.Top) to $($window.Top - $window.ActualHeight)" -Fore Green
         $window.Left = $Rect.Right - $window.ActualWidth
         $window.Top = $Rect.Bottom - ($window.ActualHeight * ($ToastedBoots.Count - 1))
         
         $size = DoubleAnimation -From 0 -To $window.ActualHeight -Duration 0:0:0.5 -"StoryBoard.TargetProperty" "(FrameworkElement.Height)" # -"StoryBoard.TargetName" "Toast" 
         $pos = DoubleAnimation -From $window.Top -To $($window.Top - $window.ActualHeight) -Duration 0:0:0.5 -"StoryBoard.TargetProperty" "(Window.Top)"
         Write-Host "Animate"
         $sb = StoryBoard $pos,$size
         [System.Windows.Media.Animation.StoryBoard]::SetTarget( $size, $toast )
         #[System.Windows.Media.Animation.StoryBoard]::SetTargetProperty( $size, "(FrameworkElement.Height)" )
         
         [System.Windows.Media.Animation.StoryBoard]::SetTarget( $pos, $window )
         #[System.Windows.Media.Animation.StoryBoard]::SetTargetProperty( $pos, "(Window.Top)" )
         $sb.Begin()
         Write-Host "Done Loaded"
      }
   } -Async -Passthru -WindowStyle None -AllowsTransparency -Export

   $Global:ToastedBoots += $Toast
   #[Threading.Thread]::Sleep(600)
   sleep 1
}

Export-ModuleMember -Function New-BootsToast

#  . $ProfileDir\Modules\PowerBoots\Samples\New-BootsToast.ps1

#  $fsw = new-object system.io.filesystemwatcher $pwd
#  $fsw.EnableRaisingEvents = $true
#  $action = { 
#     # Write-Host "$($eventArgs.Name) $($eventArgs.ChangeType)" -fore Cyan
#     New-BootsToast "$($eventArgs.Name) $($eventArgs.ChangeType)"
#     # sleep -milli 1200
#  }

#  Register-ObjectEvent $fsw Created -Action $action
#  Register-ObjectEvent $fsw Deleted -Action $action
                                                                                        
#  Register-ObjectEvent $fsw Changed -Action $action

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUAPzDxHmc1PVK3nOyH/FwTMXy
# LXugggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU006NvcC9
# rFLIs53fu94J+xRe6zcwDQYJKoZIhvcNAQEBBQAEggEAliHUSTd0eycP6AZ1/iTN
# 7SbUg7pq8WnOcBA6xytnu/TVGvdgu8rV5d09d/Rkbf2faKmgx0tFs+qSNRY9e5zM
# CW9yPhXpYn5oHD4ouhoYOGPRe/eWiG8y2rOrgdMXaCDDihy1cGxiWtQdheh+Bn3C
# KpPHknL4Cq2rkumNFKRtWW0nNRNdP6y3VLA18RjKQAEFq97Fz8CgypDW6d5W7YJ/
# xUPTMq3scSx9+XZhU+6cDtyTKN8P2l5gaFCDziJwqU59ZiEEMEalhriyX6k9/Lhr
# +kEbL1c6wAGMEHPsoO+XtkYnOicriZVFABlXaDSF7cm34M+R5R9z4WpA7cG2lik6
# iw==
# SIG # End signature block
