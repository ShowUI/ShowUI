function Set-DependencyProperty {
PARAM(
#   [Parameter(Position=0,Mandatory=$true)]
   $Property
,
   $Value
,
#   [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
   $Element
,
#   [Parameter()]
   [Switch]$Passthru
)
PROCESS {
   if($_) { $Element = $_ }
   if(!$Element) { throw "No element to set dependency properties on!" }

   trap { 
      Write-Host "ERROR Setting Dependency Property" -Fore Red
      Write-Host "Trying to set $Property to $Value" -Fore Red
      continue
   }
   if($Property.GetType() -eq ([System.Windows.DependencyProperty]) -or
      $Property.GetType().IsSubclassOf(([System.Windows.DependencyProperty]))
   ){
      trap { 
         Write-Host "ERROR Setting Dependency Property" -Fore Red
         Write-Host "Trying to set $($Property.FullName) to $Value" -Fore Red
         continue
      }
      $Element.SetValue($Property, ($Value -as $Property.PropertyType))
   } else {
      $Class = ""
      if("$Property".Contains(".")) {
         $Class,$Property = "$Property".Split(".")
      }
         
      if($DependencyProperties.ContainsKey("$Property")){
         $fields = @($DependencyProperties.$Property.Keys -like "*$Class" | Where { $Value -as ([type]$DependencyProperties.$Property.$_.PropertyType))})
         if($fields.Count -eq 0 ) { 
            $fields = @($DependencyProperties.$Property.Keys -like "*$Class" )
         }
         if($fields.Count) {
            $success = $false
            foreach($field in $fields) {
               trap { 
                  Write-Host "ERROR Setting Dependency Property" -Fore Red
                  Write-Host "Trying to set $($field)::$($DependencyProperties.$Property.$field.Name) to $($Param1.Value) -as $($DependencyProperties.$Property.$field.PropertyType)" -Fore Red
                  Write-Host $_
                  Write-Host
                  continue
               }
               $Element.SetValue( ([type]$field)::"$($DependencyProperties.$Property.$field.Name)", ($Param1.Value -as ([type]$DependencyProperties.$Property.$field.PropertyType)))
               if($?) { $success = $true; break }
            }
            if(!$success) { throw "food" }
         } else {
            Write-Host "Couldn't find the right property: $Class.$Property on $($Element.GetType().Name) of type $($Param1.Value.GetType().FullName)" -Fore Red      
         }
      } else {
         Write-Host "Unknown Dependency Property Key: $Property on $($Element.GetType().Name)" -Fore Red      
      }  
   }
   if( $Passthru ) {
      $Element
   }
}
}

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUHwTuNyH7D8p8aBto+KHuBjnp
# HHWgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUtimf+j/k
# EI5s8pQaYQoYg3mLAi4wDQYJKoZIhvcNAQEBBQAEggEACXu5nWz+G1WuZ6CUt93a
# 93koNm5jrt1zBEISJfLpbbPgSQArWRwMzou/4PDMU3D1wzShhldVTzzbWBixuIws
# NRd3fliV4J7uQ8GGHUf0Q9isfnJO5Q8nu9aGpLtTUoB8MBvfFa1ARkp5oRARUHg+
# 8x657hpFMk2GVAuV7C56UflAR6t8q55/WuhUJLDmwaTgAf4Ky0uFD3f9lOF1dp/d
# 4t9VwpijPYwO6J86lGvpduPIKJZQJ+Deb6zamCnFCOr48x9GIZ2Ouhgq5XZhfBiw
# i7iJNtrc4LDo+xfZ24jnqdm75L9XZcTOp3DmqDRJOFfh6U2R5B9586Ckd72JMrSG
# lw==
# SIG # End signature block
