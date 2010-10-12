if(!$PSScriptRoot){ 
   Write-Debug $($MyInvocation.MyCommand | fl * | out-string)
   $PSScriptRoot=(Split-Path $MyInvocation.MyCommand.Path -Parent) 
}

$EAP = $Global:ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
Add-PsSnapin PoshWpf
$ErrorActionPreference = $EAP

$PowerBootsPath = $PSScriptRoot
$ParameterHashCache = @{}
$DependencyProperties = @{}
if(Test-Path $PowerBootsPath\DependencyPropertyCache.xml) {
   $DependencyProperties = [System.Windows.Markup.XamlReader]::Parse( (gc $PowerBootsPath\DependencyPropertyCache.xml) )
}
$LoadedAssemblies = @(); 

$null = [Reflection.Assembly]::Load( "PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )

## Dot-Source all of these
. "$PowerBootsPath\Core Functions\UtilityFunctions.ps1"
. "$PowerBootsPath\Core Functions\ContentProperties.ps1"
. "$PowerBootsPath\Core Functions\Add-BootsFunction1.ps1"
. "$PowerBootsPath\Core Functions\Set-DependencyProperty1.ps1"
. "$PowerBootsPath\Core Functions\New-BootsImage.ps1"
. "$PowerBootsPath\Core Functions\Set-PowerBootsProperties.ps1"
. "$PowerBootsPath\Core Functions\Add-ChildControl.ps1"

## Put ths scripts into the path
[string[]]$path = ${Env:Path}.Split(";")
if($path -notcontains "$PowerBootsPath\Types_Generated\") {
   ## Note: Functions in "Types_StaticOverrides" override regular functions
   $path += "$PowerBootsPath\Types_StaticOverrides\","$PowerBootsPath\Types_Generated\"
   ${Env:Path} = [string]::Join(";", $path)
}

## Generate aliases for all the functions ....
$Scripts = Get-ChildItem "$PowerBootsPath\Types_Generated\New-*.ps1","$PowerBootsPath\Types_StaticOverrides\New-*.ps1" -ErrorAction 0
if(!$Scripts) {
   & "$PowerBootsPath\Core\Reset-DefaultBoots.ps1"
   $Scripts = Get-ChildItem "$PowerBootsPath\Types_Generated\New-*.ps1","$PowerBootsPath\Types_StaticOverrides\New-*.ps1" -ErrorAction 0
}

foreach($script in $Scripts) {
   $TypeName = $script.Name -replace 'New-(.*).ps1','$1'
   
   # Set-Alias -Name "New-$TypeName" $Script.FullName                     -EA "SilentlyContinue" -EV +ErrorList
   Set-Alias -Name "$($TypeName.Split('.')[-1])" "New-$TypeName"        -EA "SilentlyContinue" -EV +ErrorList
}

## Extra aliases....
# A work around for the built-in "Grid" alias, call it GridPanel (which is what the class ought to be anyway?)
$errorList = @()
## We don't need this work around for the "Grid" alias anymore
## but we preserve compatability by still generating GridPanel (which is what the class ought to be anyway?)
Set-Alias -Name GridPanel  -Value "New-System.Windows.Controls.Grid"   -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning """GridPanel"" alias not created, you must use New-System.Windows.Controls.Grid" }

$errorList = @()
Set-Alias -Name Boots      -Value "New-BootsWindow"         -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "Boots alias not created, you must use the full New-BootsWindow function name!" }

$errorList = @()
Set-Alias -Name BootsImage -Value "Out-BootsImage"          -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "BootsImage alias not created, you must use the full Out-BootsImage function name!" }

Set-Alias -Name obi        -Value "Out-BootsImage"          -EA "SilentlyContinue"
Set-Alias -Name sap        -Value "Set-DependencyProperty"  -EA "SilentlyContinue"
Set-Alias -Name gbw        -Value "Get-BootsWindow"         -EA "SilentlyContinue"
Set-Alias -Name rbw        -Value "Remove-BootsWindow"      -EA "SilentlyContinue"

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7Yj9rP/1VXNmyns5kWnzj8/H
# HvygggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUm7Jbt34N
# 7kaTbynuYApi/DkaXN0wDQYJKoZIhvcNAQEBBQAEggEAjSE1cIjGtY+cYoJDrqPv
# 9ELLRNnwTM3otcg+RN/CjeSKHilvTsP1aMrJUFlbUrufn6UJH9n5eduKYGMDbYC6
# n5vYHnslCDEdvBHPmHDwu3aGv4cHeWeaJv255UAx6iMx2uf4G8W/sZOND8MIitUi
# 4abASswtpILRMiXYIZk3Ii3KgvjI3w4BTnHMU93dv1Z6zd74GvJBrHslcBovT+Xl
# zWexfhO0w0ZAqLrek0um4RDnBwI3Vsz3Ll6/+V3FPauo5qeRyKt+tItcfqyWugUn
# FU0NHEdnydWXsP/URCBD5d8izYQQWVUvo5MelOXJfKO6b2fwRPeJ6vAkkGdV11xn
# ng==
# SIG # End signature block
