[CmdletBinding(DefaultParameterSetName='KeyOnly')]
PARAM(
	[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.Key]$Key
,
	[Parameter(Mandatory=$true, Position=1, ParameterSetName='WithModifier', ValueFromPipelineByPropertyName=$true)]
	# [Parameter(Mandatory=$true, Position=1, ParameterSetName='WithDisplayString', ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.ModifierKeys]$Modifiers
, 
	[Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
   [System.String]$DisplayString 
,
   [Parameter(ValueFromRemainingArguments=$true)]
   [string[]]$DependencyProps
)
## Preload the assembly if it's not already loaded


if( [Array]::BinarySearch(@(Get-UIAssemblies), 'PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) -lt 0 ) {
   $null = [Reflection.Assembly]::Load( 'PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) 
}
if($ExecutionContext.SessionState.Module.Guid -ne (Get-UIModule).Guid) {
	Write-Debug "KeyGesture not invoked in ShowUI context. Attempting to reinvoke."
   $scriptParam = $PSBoundParameters
   return iex "& (Get-UIModule) '$($MyInvocation.MyCommand.Path)' `@PSBoundParameters"
}
# Write-Host "KeyGesture in module $($executioncontext.sessionstate.module) context!" -fore Green


function Global:New-System.Windows.Input.KeyGesture {
<#
.Synopsis
   Create a new KeyGesture object
.Description
   Generates a new System.Windows.Input.KeyGesture object, and allows setting all of it's properties
.Parameter Key
   The name of the key to bind to this gesture. (can be just a letter, like "W")
.Parameter Modifiers
   The modifier keys to modify this gesture. The possible enumeration values are: None, Alt, Control, Shift, Windows. Defaults to None.
   You can pass this as an array of strings, or as a single string with multiple modifiers joined by +:
   -Modifiers Control
   -Modifiers Control+Shift
   -Modifiers Control, Shift
   
.Parameter DisplayString
   Optionally, an alternate string to display as the gesture.
   For example, if you specify the Key "F4" and the Modifiers "Ctrl", "Alt" ... the default display string is: "Ctrl+Alt+F4", so if you would like to see, for instance: Control+Alt, F4 then you can specify it in this parameter.
.Notes
 AUTHOR:    Joel Bennett http://HuddledMasses.org
 LASTEDIT:  04/22/2010 16:58:33
#>
 
[CmdletBinding(DefaultParameterSetName='KeyOnly')]
PARAM(
	[Parameter(Mandatory=$true, Position=0, ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.Key]$Key
,
	[Parameter(Mandatory=$true, Position=1, ParameterSetName='WithModifier', ValueFromPipelineByPropertyName=$true)]
	# [Parameter(Mandatory=$true, Position=1, ParameterSetName='WithDisplayString', ValueFromPipelineByPropertyName=$true)]
   [System.Windows.Input.ModifierKeys]$Modifiers
, 
	[Parameter(Mandatory=$false, Position=2, ValueFromPipelineByPropertyName=$true)]
   [System.String]$DisplayString 
,
   [Parameter(ValueFromRemainingArguments=$true)]
   [string[]]$DependencyProps
)
BEGIN {
   $All = Get-Parameter New-System.Windows.Input.KeyBinding | ForEach-Object { $_.Key } | Sort
}
PROCESS {
   switch($PSCmdlet.ParameterSetName) {
      "WithModifier" {
         if($DisplayString){
            $DObject = New-Object System.Windows.Input.KeyGesture $Key, $Modifiers, $DisplayString
         } else {
            $DObject = New-Object System.Windows.Input.KeyGesture $Key, $Modifiers
         }
      }
      "KeyOnly" {
         $DObject = New-Object System.Windows.Input.KeyGesture $Key
      }
   }

   $null = $PSBoundParameters.Remove("Key")
   $null = $PSBoundParameters.Remove("Modifiers")
   $null = $PSBoundParameters.Remove("DisplayString")

   Set-UIProperties $PSBoundParameters ([ref]$DObject) $All
   Microsoft.PowerShell.Utility\Write-Output $DObject
} #Process
}

Set-Alias KeyGesture New-System.Windows.Input.KeyGesture
New-System.Windows.Input.KeyGesture @PSBoundParameters

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUx/tt6k5JHd4V1s/glxYweFUp
# QOqgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUzOl0kqHp
# JBAA+yDvMBWBs3oDvz8wDQYJKoZIhvcNAQEBBQAEggEAPGjqk6W43OHgS4TtpIhf
# ywSSIJlfAx3PymzASG1keCAJxp3G/kG0VAm8hWJN1ml15nCbyNlV2vKkhWs6O9y/
# XYYAJFtIqQMqO9GOujpXzyzaFniOOgVCisv8p9xRa8/WWQqFu4ablA4me1kAWsOu
# FYhha+4mrV5o2JIOpxEDN4PcJtUkUjeTWzpc1jEu/yTmlfpFJZDnIsJ6zaBDO1gl
# jW+rihvE/+883TtqOzRaVEOGhAs/OnbxAzamI6463tPgnz9A7FT6O+heehs7dMx/
# Uql3HRZgTGRbGr7mIRDkZeVw8Bqo5Lb43DJ8tp0plzHeU++Xm8T8O8TFVENxaFbV
# ug==
# SIG # End signature block
