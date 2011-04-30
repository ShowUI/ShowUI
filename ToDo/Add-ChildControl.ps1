function Add-ChildControl {
   <#
   .Synopsis
      Adds a Child/Content Control to a Container
   .Description
      Adds a Child Control to a Container
   .Example
      StackPanel -On_Loaded {
         Label "Hello" | Add-ChildControl -parent $this
      }
      
      Description
      -----------
      This example has exactly the same output as just running:
      
      StackPanel { Label "Hello" }
      
      But since it adds the label in the loaded event, it could interact with other controls on the window, etc.
      
   .Parameter control
      The UI Elements to add to the parent
   .Parameter scriptBlock
      A Script Block used to create one or more UI Elements to add 
   .Parameter parameters
      The parameters to the script block
   .Parameter parent
      The container the child controls will be added into
   .Parameter passthru
      If set, the UI element will be returned through the pipeline.      
   #>
   [CmdletBinding(DefaultParameterSetName='Control')]    
   param(
      [Parameter(Position=0, Mandatory=$true)]
      [Windows.Controls.Panel]$parent
   ,
      [Parameter(Mandatory=$true, ParameterSetName='Control', ValueFromPipeline=$true)]
      [Windows.UIElement[]]$control
   ,
      [Parameter(Mandatory=$true, ParameterSetName='ScriptBlock', ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
      [Alias('Definition')]
      [ScriptBlock]$scriptBlock
   ,
      [Parameter(ParameterSetName='ScriptBlock', ValueFromPipelineByPropertyName=$true)]    
      [Hashtable]$parameters
   ,
      [switch]$PassThru
   )

   process {        
      if ($scriptBlock) {
         if ($parameters) {
            $control = & $scriptBlock @parameters
         } else {
            $control = & $scriptBlock
         }           
      }

      $property = @($parent | Get-Member -type Properties -Name (Get-UIContentProperty))[0]
      Set-UIProperty [ref]$parent $property $control
      if( $passThru ){ $control } 
   }
}
# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUySoJcLcx3xY0HBCl2ymS0tix
# cligggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUI0tgsEUa
# hCMU+S71zEKXsB2bKVQwDQYJKoZIhvcNAQEBBQAEggEACsgj+y4kYdWGI9ffe+TX
# gmaNoVS/zl8NZkn4EvA42V4GHJxqllM5nF8C+WEMu5SKhTOzzh+OvgVm6Aut+lFT
# a7RsUSHLIC0TkBNml1yezzPZiZawd7DhYPsva/wlVfW6SIXW8TZHI/5vsEZ3fUcq
# WpBdw4bHN4sd4uMeMTYZLvNBc+urUAPqajrNRgsNGu1c378bqEIeQCMy4PQUWqBu
# qdasgcE2jgQKaDaU1fs2r8RppRbOVZcxSrnpoI5BVOlI6qkniPSnJGShQSrIf4ta
# j3881An2iNJs46JK4S/m/6i3xOslIo5PmiWCtPkmNkHa1CZ6h9vQ8Oz/VkZQo0le
# 4A==
# SIG # End signature block
