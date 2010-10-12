function Get-BootsModule { $executioncontext.sessionstate.module }


function global:Export-NamedElement {
##.Synopsis 
## Recursively enumerate all the descendants of the visual object and set variables if they have names
param(
   [Parameter(ValueFromPipeline=$true, Position=1, Mandatory=$false)]
   [System.Windows.Media.Visual] $VisualElement = $BootsWindow
, 
   [string]$scope = "global"
)
   for ($i = 0; $i -lt [System.Windows.Media.VisualTreeHelper]::GetChildrenCount($VisualElement); $i++)
   {
      ## Retrieve child visual at specified index value.
      $childVisual = [System.Windows.Media.VisualTreeHelper]::GetChild($VisualElement, $i);
      if ($childVisual -is [System.Windows.FrameworkElement])
      {
         ## Do processing of the child visual object.
         [string]$name = $childVisual.GetValue([System.Windows.FrameworkElement]::NameProperty)
         if($name -and [System.Windows.Threading.Dispatcher]::CurrentDispatcher.CheckAccess())
         {
            Set-Variable $name -Value $childVisual -Scope $Scope -Option AllScope
         }
      }
      ## Enumerate children of the child visual object.
      Export-NamedElement -VisualElement $childVisual -Scope $scope
   }
}


#  function Get-BootsModule { 
#  [CmdletBinding()]
#  Param()
#     $PSCmdlet.MyInvocation.MyCommand.Module 
#  }


function Get-BootsAssemblies {
#
#.Synopsis
#   Get a list of FullNames for the loaded assemblies
#.Description
#   Gets a list of assemblies, with a Location property added to the ones which are not in the GAC
#
   $assm =  [System.AppDomain]::CurrentDomain.GetAssemblies()
   ## Update the list if we need to...
   if($assm.Count -ne $LoadedAssemblies.Count) {
      $LoadedAssemblies = $assm | Sort FullName | ForEach-Object { 
         if($_.GlobalAssemblyCache) { 
            $_.FullName
         } else {
            Add-Member -input $_.FullName -Type NoteProperty -Name Location -Value $_.Location -Passthru
         }
      }
   }
   $LoadedAssemblies
}
#
#.Synopsis
#   Get a list of parameters for a command
#.Description
#   Get-Parameter gets a list of the parameters for a command
#   but only includes the "Common Parameters" when they are specifically requested
#
function Get-Parameter {
PARAM([string]$CommandName, [switch]$IncludeCommon)
   (New-Object System.Management.Automation.CommandMetaData @(Get-Command $CommandName)[0], $IncludeCommon).Parameters.GetEnumerator()
}

function Get-BootsParam {
#
#.Synopsis
#   Get information about the possible parameters for a specific WPF type
#.Parameter CommandName
#   The name of the command you want help for (eg: "Window" or "New-System.Windows.Window")
#.Parameter Parameter
#   An optional pattern for the name(s) of the parameter(s) you want help for.
#.Example
#   Get-BootsParam Window
#   
#   Returns the list of parameters (including Events) for the WIndow class.
#.Example
#   Get-BootsParam Window On_TextInput
#   
#   Returns the details about the On_TextInput, including the expected type, and the parameter attributes.
#
PARAM([string]$CommandName, [string]$Parameter)

   if($Parameter) {
      Get-Parameter $CommandName $false | ? { $_.Key -match $Parameter } | Sort-Object Key | Format-Wide Key
   } else {
      Get-Parameter $CommandName $false | Sort-Object Key | Format-Wide Key
   }
}

## Get a list of all the boots commands
function Get-BootsCommand {
#.Synopsis
#  Lists all the Boots aliases
   $commands = get-alias | ? { $_.Definition -like "New-ObjectFromAlias" } | %{$_.Name}
   Get-Alias |? { $commands -contains $_.Definition }
   Write-Warning "Get-BootsCommand is deprecated. Use: Get-Command -Module PowerBoots"
}

## Open an MSDN link for a boots element
function Get-BootsHelp {
PARAM([string]$TypeName)
   [Diagnostics.Process]::Start( "http://msdn.microsoft.com/library/$(Get-BootsType $TypeName)" )
}


# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoIQYrYe4QNa2EL9VSnR8RBW+
# dUCgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBbFNy+3o
# 3tlAYVrDCcmTNZtb7ggwDQYJKoZIhvcNAQEBBQAEggEAKiJkHAS3+1Q40OVgitdU
# F0nnfdleYWl8Qghnzonco64shXWRr0NrhuA66s8VRdxc60RMgO3KUceWhoTwD7Yq
# yu8JeRy9m2wLk2E9M9Un5JURfoLqiqGGpmdhn2ijxC3tbFpNfm3KBUNbFWKAkbas
# b4Cyg482vt2xA7MJh5VaDJIncuK4kPjiuLQRYxJPT44xD5z9b2/mEqPlpTVpYfeP
# z9Kt1HVEDu9nj8wC5gQ5kqeL2xQWi7IE3VlGN87D3fhFbWLyBI4kNagFClovqZgn
# oJacUm9BcFoh/NDhDZgc405B1sBVbtaZhPdaIQ1XmztRgpAWHVEM/nd9eiii9n4T
# iQ==
# SIG # End signature block
