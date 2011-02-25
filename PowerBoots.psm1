##Requires -Version 2.0
####################################################################################################
if(!(Test-Path Variable::PowerBootsPath)) {
New-Variable PowerBootsPath $PSScriptRoot -Description "PowerBoots Variable: The root folder for PowerBoots" -Option Constant, ReadOnly, AllScope -Scope Global
}
$ParameterHashCache = @{}
[Hashtable]$DependencyProperties = @{}
if(Test-Path $PowerBootsPath\DependencyPropertyCache.xml) {
   [Hashtable]$DependencyProperties = [System.Windows.Markup.XamlReader]::Parse( (gc $PowerBootsPath\DependencyPropertyCache.xml) )
}
$LoadedAssemblies = @(); 

$null = [Reflection.Assembly]::Load( "PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )

## Dotsource these rather than autoloading because we're guaranteed to need them
. "$PowerBootsPath\Core\Add-BootsFunction.ps1"
. "$PowerBootsPath\Core\Set-DependencyProperty.ps1"
. "$PowerBootsPath\Core\Set-PowerBootsProperties.ps1"
. "$PowerBootsPath\Core\UtilityFunctions.ps1"
. "$PowerBootsPath\Core\ContentProperties.ps1"

## Dotsource this because calling it from inside AutoLoad messes with the -Scope value
# . "$PowerBootsPath\Core\Export-NamedControl.ps1"

## Autoload these for public consumption if needed
AutoLoad "$PowerBootsPath\Core\New-BootsImage.ps1" -Alias New-BootsImage -Module PowerBoots

## TODO: This would be a great function to add, if we could make it ADD instead of SET.
# AutoLoad "$PowerBootsPath\New Functions\Add-ChildControl.ps1" Add-ChildControl PowerBoots

## Add-EventHandler is deprecated because the compiled Register-BootsEvent is a better way
#. "$PowerBootsPath\New Functions\Add-EventHandler.ps1"
## TODO: Can Register-BootsEvent be an actual PSEvent and still execute on the thread the way I need it to?

## Select-ChildControl (aka: Get-ChildControl) is deprecated because Export-NamedControls is a better way
#. "$PowerBootsPath\New Functions\Select-ChildControl.ps1"
## I don't need this one, 'cause I've integrated it into the core! ;)
# . "$PowerBootsPath\New Functions\ConvertTo-DataTemplate.ps1"

## TODO: I'm not really sure how these fit in yet
# "$PowerBootsPath\Core\ConvertTo-GridLength.ps1"
# "$PowerBootsPath\Extras\Enable-Multitouch.ps1"
# "$PowerBootsPath\Extras\Export-Application.ps1"

# This is #Requires -STA
New-Variable IsSTA ([System.Threading.Thread]::CurrentThread.ApartmentState -eq "STA") -Description "PowerBoots Variable: Whether the host is in Single-Threaded Apartment (STA) mode."

## In case they delete the "Deprecated" folder (like I would)...
if(Test-Path "$PowerBootsPath\Deprecated\Out-BootsWindow.ps1") {
   if( !$IsSTA ) { 
      function Out-BootsWindow {
         Write-Error "Out-BootsWindow disabled in MTA mode. Use New-BootsWindow instead. (You must run PowerShell with -STA switch to enable Out-BootsWindow)"
      }
   } else { # Requires -STA
      AutoLoad "$PowerBootsPath\Deprecated\Out-BootsWindow.ps1" -Alias Out-BootsWindow -Module PowerBoots
   }
}

## Thanks to Autoload, I'm not altering the path ...
## Put the scripts into the path
#  [string[]]$path = ${Env:Path}.Split(";")
#  if($path -notcontains "$PowerBootsPath\Types_Generated\") {
   #  ## Note: Functions in "Types_StaticOverrides" override regular functions
   #  $path += "$PowerBootsPath\Types_StaticOverrides\","$PowerBootsPath\Types_Generated\"
   #  ${Env:Path} = [string]::Join(";", $path)
#  }


## Autoload all the functions ....
if(!(Get-ChildItem "$PowerBootsPath\Types_Generated\New-*.ps1" -ErrorAction SilentlyContinue)) {
   & "$PowerBootsPath\Core\Reset-DefaultBoots.ps1"
}

foreach($script in Get-ChildItem "$PowerBootsPath\Types_Generated\New-*.ps1", "$PowerBootsPath\Types_StaticOverrides\New-*.ps1" -ErrorAction 0) {
   $TypeName = $script.Name -replace 'New-(.*).ps1','$1'
   
   Set-Alias -Name "$($TypeName.Split('.')[-1])" "New-$TypeName"        -EA "SilentlyContinue" -EV +ErrorList
   AutoLoad -Name $Script.FullName -Alias "New-$TypeName" -Module PowerBoots
   # Write-Host -fore yellow $(Get-Command "New-$TypeName" | Out-String)
}

## Extra aliases....
$errorList = @()
## We don't need this work around for the "Grid" alias anymore
## but we preserve compatability by still generating GridPanel (which is what the class ought to be anyway?)
Set-Alias -Name GridPanel  -Value "New-System.Windows.Controls.Grid"   -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning """GridPanel"" alias not created, you must use New-System.Windows.Controls.Grid" }

$errorList = @()
Set-Alias -Name Boots      -Value "New-BootsWindow"         -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "Boots alias not created, you must use the full New-BootsWindow function name!" }

$errorList = @()
Set-Alias -Name Show-UI    -Value "New-BootsWindow"         -EA "SilentlyContinue" -EV +ErrorList
Set-Alias -Name Show       -Value "New-BootsWindow"         -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "Show alias to New-BootsWindow not created!" }

$errorList = @()
Set-Alias -Name UIOut        -Value "Write-BootsOutput"         -EA "SilentlyContinue" -EV +ErrorList
Set-Alias -Name Write-UIOutput      -Value "Write-BootsOutput"         -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "UIOut alias to New-BootsWindow not created!" }

$errorList = @()
Set-Alias -Name BootsImage -Value "Out-BootsImage"          -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "BootsImage alias not created, you must use the full Out-BootsImage function name!" }

Set-Alias -Name obi    -Value "Out-BootsImage"          -EA "SilentlyContinue"
Set-Alias -Name sdp    -Value "Set-DependencyProperty"  -EA "SilentlyContinue"
Set-Alias -Name gbw    -Value "Get-BootsWindow"         -EA "SilentlyContinue"
Set-Alias -Name rbw    -Value "Remove-BootsWindow"      -EA "SilentlyContinue"
                                                    
$BootsFunctions = @("Add-BootsFunction", "Set-DependencyProperty", "New-*") +
                  @("Get-BootsModule", "Get-BootsAssemblies", "Get-Parameter", "Get-BootsParam" ) + 
                  @("Get-BootsContentProperty", "Add-BootsContentProperty", "Remove-BootsContentProperty") +
                  @("Get-BootsHelp", "Get-BootsCommand", "Out-BootsWindow", "New-BootsImage") +
                  @("Select-BootsElement","Select-ChildControl", "Add-ChildControl", "Add-EventHandler" ) +
                  @("ConvertTo-GridLength", "Enable-MultiTouch", "Export-Application") + 
                  @("Autoloaded", "Export-NamedElement")

Export-ModuleMember -Function $BootsFunctions -Cmdlet (Get-Command -Module PoshWpf) -Alias * -Variable "PowerBootsPath", "IsSTA"

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpiUWVXZ2rnu7de9iBUlyHQ7t
# wEqgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU3D/4OXlk
# 5ZvcDZT/EP/2whgXTrwwDQYJKoZIhvcNAQEBBQAEggEAuVogcoPlxuxwB8oilYvA
# +07fPvUAdAjBpjXRaskMXgCbkujL+7OhHU7MyJvdCRmCjXUUL/ZkZGPruOj8AK67
# XbKD9defg78FSSxUjAjjG4g73pok3OxnfcdBLLWMCE/7Ib/IgQ/eLfgn1IrfW/dO
# a3w4yIqOzOoORMFNKPWhuNVLf+wGwq6Wmck2HHdbsVUqMireq77ff5zDjtbhdq4p
# xekhJn5F9UNbK1CORchdsnegdaCHat4+tZbUryd9dyYsGFAaV+YUXyR/C6hXOxu2
# c3/qWTkll7lPulotj6OqlAV09Q7/PsqVeAMV8w7YW/zbqoKEIcjR7NsvUUuFmbBm
# sg==
# SIG # End signature block
