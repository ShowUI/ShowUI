
function Set-DependencyProperty {
[CmdletBinding()]
PARAM(
   [Parameter(Position=0,Mandatory=$true)]
   $Property
,
   [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
   $Element
,
   [Parameter()]
   [Switch]$Passthru
)
DYNAMICPARAM {
   trap { 
      Write-Host "ERROR Evaluating DynamicParam for Dependency Property (See: `$Exception and `$CallStack)" -Fore Red
      Write-Host "Trying to set $Property to $($Param1.Value)" -Fore Red
      Write-Host $_ -fore Red
      $Global:Exception = $_.Exception
      $Global:CallStack = Get-PSCallStack
      Write-Host $this -fore DarkRed
      continue
   }   
   if($DebugPreference -ne "SilentlyContinue") { 
      Write-Host "Dependency Property: $($Element.GetType().FullName): $Property " -foreground Yellow 
   }
   $paramDictionary = new-object System.Management.Automation.RuntimeDefinedParameterDictionary
   $Param1 = new-object System.Management.Automation.RuntimeDefinedParameter
   $Param1.Name = "Value"
   # $Param1.Attributes.Add( (New-ParameterAttribute -Position 1) )
   $Param1.Attributes.Add( (New-Object System.Management.Automation.ParameterAttribute -Property @{ Position = 1 }) )   
   ## We maybe don't need to keep this in memory?
   # $DependencyProperties = Import-CliXml $PowerBootsPath\DependencyPropertyCache.clixml

   if( $Property ) {
      if($Property.GetType() -eq ([System.Windows.DependencyProperty]) -or
         $Property.GetType().IsSubclassOf(([System.Windows.DependencyProperty]))) 
      {
         if($DebugPreference -ne "SilentlyContinue") { 
            Write-Host "Property passed in as type. $Property -is $($Property.GetType())" -foreground Cyan
         }
         $Param1.ParameterType = $Property.PropertyType
      } 
      elseif($Property -is [string] -and $Property.Contains(".") -or $Property.Contains("-")) 
      {
         if($Property.Contains("-")) { $Property = $Property -replace "-","." }
         
      
         [string]$Class,[string]$PropertyName = $Property -split "\.(?!.*\.)"
         [string]$PropertyName = $DependencyProperties.Keys -ieq $PropertyName
         if($DebugPreference -ne "SilentlyContinue") { 
            Write-Host "Property passed in as dotted string: '$Class.$PropertyName' $($DependencyProperties.$PropertyName.Keys -join ', ')" -foreground Cyan
         }
         if($PropertyName){
            [string]$type = $DependencyProperties.$PropertyName.Keys -like "*.$Class"
            if(!$type) {
               [string]$type = $DependencyProperties.$PropertyName.Keys -like "*$Class"
            }
            if($DebugPreference -ne "SilentlyContinue") { 
               # $Classes = $DependencyProperties.$PropertyName.Keys -join ', '
               Write-Host "Property '$PropertyName' on $(@($type).Count) class(es): $Type" -foreground Cyan
            }
            if(@($type).Count -gt 1) {
               Write-Warning "Couldn't figure which '$Class' you mean. Please use the full name of one of: '$($type -join ''',''')'"
            } elseif($type) { 
               $Param1.ParameterType = [type]$DependencyProperties.$PropertyName.$Type.PropertyType
               $Property = "$Type.$PropertyName"
            }
            if($DebugPreference -ne "SilentlyContinue") { 
               $Param1 | Out-String | Write-Host -fore White
            }
         }
      } 
      elseif($DependencyProperties.ContainsKey($Property))
      {
         if($DebugPreference -ne "SilentlyContinue") { 
            Write-Host "Property for $($element.GetType().FullName) passed in as string: $($DependencyProperties.$Property.Keys)" -foreground Cyan
         }
         if($Element -and $DependencyProperties.($Property).ContainsKey( $element.GetType().FullName )) { 
            $Param1.ParameterType = [type]$DependencyProperties.($Property).($element.GetType().FullName).PropertyType
         } else {
            $Param1.ParameterType = [type]@($DependencyProperties.($Property).Values)[0].PropertyType
         }
      }
      else 
      {
         $Param1.ParameterType = [PSObject]
      }
   }
   else 
   {
      $Param1.ParameterType = [PSObject]
   }
   
   $paramDictionary.Add("Value", $Param1)
   if($DebugPreference -ne "SilentlyContinue") { 
      Write-Host "Parameter Dictionary from Dynamic Parameter:" -Foreground Cyan
      foreach($ky in $paramDictionary.Keys) {
         Write-Host "$ky = $($paramDictionary[$ky] | Format-Table | Out-String)" -Foreground Cyan
      }
      Write-Host "Dependency Property: $($Element.GetType().FullName).$Property " -Foreground Yellow 
   }
   return $paramDictionary
}
#  BEGIN {
   #  if($DebugPreference -ne "SilentlyContinue") { 
      #  Write-Host "Dependency Property: $($Element.GetType().FullName).$Property = $Value" -foreground Yellow 
   #  }
#  }

PROCESS {   
   if($DebugPreference -ne "SilentlyContinue") { 
      Write-Host "Dependency Property: $($Element.GetType().FullName): $Property " -foreground Magenta 
   }
   trap { 
      Write-Host "ERROR Evaluating DynamicParam for Dependency Property (See: `$Exception and `$CallStack)" -Fore Red
      Write-Host "Trying to set $Property to $($Param1.Value)" -Fore Red
      Write-Host $_ -fore Red
      $Global:Exception = $_.Exception
      $Global:CallStack = Get-PSCallStack
      Write-Host $this -fore DarkRed
      continue
   }

   
   if($Property.GetType() -eq ([System.Windows.DependencyProperty]) -or $Property.GetType().IsSubclassOf(([System.Windows.DependencyProperty]))
   ){
      trap { 
         Write-Host "ERROR Setting Dependency Property" -Fore Red
         Write-Host "Trying to set $($Property.FullName) to $($Param1.Value)" -Fore Red
         continue
      }
      $Element.SetValue($Property, ($Param1.Value -as $Property.PropertyType))
   } else {
      if("$Property".Contains("-")) { $Property = $Property -replace "-","." }
   
      if("$Property".Contains(".")) {
         [string]$Class,[string]$PropertyName = $Property -split "\.(?!.*\.)"
         [string]$PropertyName = $DependencyProperties.Keys -ieq $PropertyName
      
         if($DebugPreference -ne "SilentlyContinue") { 
            Write-Host "Property passed in as dotted string: '$Class.$PropertyName' $($DependencyProperties.$PropertyName.Keys -join ', ')" -foreground Green
         }
         if($PropertyName -and $DependencyProperties.ContainsKey($PropertyName)){
            $DependencyProperties.$PropertyName.Keys -like "*.$Class" | % { Write-Host "`$DependencyProperties.$PropertyName.$_.PropertyType" }
         
            $fields = @($DependencyProperties.($PropertyName).Keys -like "*.$Class" | ? { $Param1.Value -as ([type])})
            $fields += @($DependencyProperties.($PropertyName).Keys -like "*$Class" | ? { $Param1.Value -as ([type]$DependencyProperties.$PropertyName.$_.PropertyType)})
            if($fields.Count -eq 0 ) { 
               $fields = @($DependencyProperties.($PropertyName).Keys -like "*$Class")
            }
            if($fields.Count) {
               $success = $false
               foreach($field in $fields) {
                  trap { 
                     Write-Host "ERROR Setting Dependency Property" -Fore Red
                     Write-Host "Trying to set $($field)::$($DependencyProperties.($PropertyName).($field).Name) to $($Param1.Value) -as $($DependencyProperties.($PropertyName).($field).PropertyType)" -Fore Red
                     continue
                  }
                  $Element.SetValue( ([type]$field)::"$($DependencyProperties.($PropertyName).($field).Name)", ($Param1.Value -as ([type]$DependencyProperties.($PropertyName).($field).PropertyType)))
                  if($?) { $success = $true; break }
               }
               if(!$success) { throw "Couldn't match $Class.$PropertyName" }
            } else {
               Write-Host "Couldn't find the right property: $Class.$PropertyName on $($Element.GetType().Name) of type $($Param1.Value.GetType().FullName)" -Fore Red      
            }
         } else {
            Write-Host "Unknown Dependency Property Key: $PropertyName on $($Element.GetType().Name)" -Fore Red      
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU18AgngAwrlPrJ3LjdhgFoPT4
# OdWgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU+AAdyvX3
# jIYVRpGTKjtPe2JQsvIwDQYJKoZIhvcNAQEBBQAEggEAurNFrfEyqF7DCyScXr0/
# 1lTUKC6ATfOfx8uq2xzuOi2q4xN7KUjgxsvLbn6pkuEM5TRS10+w0XDotvQA/iSx
# MYI17BvDyxROeh2333j7MalPRkdK0Vya8VwcDDJrm/DMRzTn7ewiJOdnE4nMJzld
# /Vnf+A4JuqGBt9/AalGfZbwBYkBb80KCnnMj5gh0qaQCY0mw35DjkdASvqaVQtYX
# vQwMjywMgbdZj9SE1fjKTb0RPOuuWBtWl1e6dZoo3wPSjA3mfWeXRvkY4/WEQA9C
# pWu/f9QmQXOSNAMqkkNEIExrZfqYexYe/csBxz+SeHs46WUBe/2TaMIO3mqHqs58
# pw==
# SIG # End signature block
