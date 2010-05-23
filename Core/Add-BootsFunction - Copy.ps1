function Add-BootsFunction {
<#
.Synopsis
   Add support for a new class to Boots by creating the dynamic constructor function(s).
.Description
   Creates a New-Namespace.Type function for each type passed in, as well as a short form "Type" alias.

   Exposes all of the properties and events of the type as perameters to the function. 

   NOTE: The Type MUST have a default parameterless constructor.
.Parameter Type
   The type you want to create a constructor function for.  It must have a default parameterless constructor.
.Example
   Add-BootsFunction ([System.Windows.Controls.Button])
   
   Creates a new boots function for the Button control.

.Example
   [Reflection.Assembly]::LoadWithPartialName( "PresentationFramework" ).GetTypes() | Add-BootsFunction

   Will create boots functions for all the WPF components in the PresentationFramework assembly.  Note that you could also load that assembly using GetAssembly( "System.Windows.Controls.Button" ) or Load( "PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )

.Example
   Add-BootsFunction -Assembly PresentationFramework

   Will create boots functions for all the WPF components in the PresentationFramework assembly.

.Links 
   http://HuddledMasses.org/powerboots
.ReturnValue
   The name(s) of the function(s) created -- so you can export them, if necessary.
.Notes
 AUTHOR:    Joel Bennett http://HuddledMasses.org
 LASTEDIT:  2009-01-13 16:35:23
#>
[CmdletBinding(DefaultParameterSetName="FromType")]
PARAM(
   [Parameter(Position=0,ValueFromPipeline=$true,ParameterSetName="FromType",Mandatory=$true)]
   [type[]]$type
,
   [Alias("FullName")]
   [Parameter(Position=0,ValueFromPipelineByPropertyName=$true,ParameterSetName="FromAssembly",Mandatory=$true)]
   [string[]]$Assembly
,
   [Parameter()]
   [switch]$Force
)
BEGIN {
   [Type[]]$Empty=@()
   if(!(Test-Path "$PowerBootsPath\Types_Generated")) {   
      MkDir "$PowerBootsPath\Types_Generated"
   }
}
END {
   Export-CliXml -Input $DependencyProperties -Path $PowerBootsPath\DependencyPropertyCache.clixml
}
PROCESS {
   if($PSCmdlet.ParameterSetName -eq "FromAssembly") {
      [type[]]$type = @()
      foreach($lib in $Assembly) {
         $asm =  $null
         trap { continue }
         if(Test-Path $lib) {
            $asm =  [Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path $lib -EA "SilentlyContinue") -EA "SilentlyContinue") )
         }
         if(!$asm) {
            ## BUGBUG: LoadWithPartialName is "Obsolete" -- but it still works in 2.0/3.5
            $asm =  [Reflection.Assembly]::LoadWithPartialName( $lib )
         }
         if($asm) {
            $type += $asm.GetTypes() | ?{ $_.IsPublic    -and !$_.IsEnum      -and 
                                         !$_.IsAbstract  -and !$_.IsInterface -and 
                                         $_.GetConstructor( "Instance,Public", $Null, $Empty, @() )}
         } else {
            Write-Error "Can't find the assembly $lib, please check your spelling and try again"
         }
      }
   }

   $LoadedAssemblies = Get-BootsAssemblies 
   
   foreach($T in $type) {
      $TypeName = $T.FullName
      $ScriptPath = "$PowerBootsPath\Types_Generated\New-$TypeName.ps1"
      Write-Verbose $TypeName

      ## Collect all dependency properties ....
      $T.GetFields() |
         Where-Object { $_.FieldType -eq [System.Windows.DependencyProperty] } |
         Select-Object Name, @{n="DeclaringType";e={$_.DeclaringType.FullName}}, 
                  @{n="PropertyType";e={$_.DeclaringType::"$($_.Name)".PropertyType.FullName}},
                  @{n="Field";e={$_.DeclaringType::"$($_.Name)".Name}} |
         ForEach-Object { 
            Write-Verbose "Dependency Property: $($_.Field)"
            if($DependencyProperties.ContainsKey( $_.Field )) {
               $DependencyProperties[$_.Field] = @($DependencyProperties[$_.Field]) + @($_)
            } else {
               $DependencyProperties[$_.Field] = $_
            }
         }
            
      if(!( Test-Path $ScriptPath ) -OR $Force) {
         $Pipelineable = @();
         ## Get (or generate) a set of parameters based on the the Type Name
         $Parameters = "[CmdletBinding(DefaultParameterSetName='Default')]`nPARAM(`n" + [String]::Join("`n, `n", @(
            ## Add all properties
            foreach ($p in $T.GetProperties("Public,Instance,FlattenHierarchy") | 
                              where {$_.CanWrite -Or $_.PropertyType.GetInterface([System.Collections.IList]) } | Sort Name -Unique)
            {
               if($p.Name -match "^$($BootsContentProperties -Join '$|^')`$") {
                  $Pipelineable += @(Add-Member -in $p.Name -Type NoteProperty -Name "IsCollection" -Value $($p.PropertyType.GetInterface([System.Collections.IList]) -ne $null) -Passthru)
                  "`t[Parameter(ParameterSetName='Default',Position=1,ValueFromPipeline=`$true)]" +
                  "`n`t[Object[]]`$$($p.Name)"
               } elseif($p.PropertyType -eq [System.Boolean]) {
                  "`t[Parameter(ParameterSetName='Default')]"+
                  "`n`t[Switch]`$$($p.Name)"
               } else {
                  "`t[Parameter(ParameterSetName='Default')]"+
                  "`n`t[Object[]]`$$($p.Name)"
               }
            }
            
            ## Add all events
            foreach ($e in $T.GetEvents("Public,Instance,FlattenHierarchy"))
            {
               "`t[Parameter(ParameterSetName='Default')]" +
               "`n`t[PSObject]`$On_$($e.Name)"
            }
         )) + "`n,`n`t[Parameter(ValueFromRemainingArguments=`$true)]`n`t[string[]]`$DependencyProps`n)"

         $collectable = [bool]$(@(foreach($p in @($Pipelineable)){$p.IsCollection}) -contains $true)
         $ofs = "`n";

         #  Write-Host "Pipelineable Content Property for $TypeName: $($Pipelineable -ne $Null)" -Fore Cyan
         #  foreach($p in $Pipelineable) {write-host "$p is $(if(!$p.IsCollection) { "not " })a collection"}

### These three are "built in" to boots, so we don't need to write preloading for them
# PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
# WindowsBase, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
# PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35

$function = $(
"
$Parameters

## Preload the assembly if it's not already loaded


if( [Array]::BinarySearch(@(Get-BootsAssemblies), '$($T.Assembly.FullName)' ) -lt 0 ) {
$(
   $index = [Array]::BinarySearch($LoadedAssemblies, $T.Assembly.FullName)
   
   if( $index -gt 0 -and $LoadedAssemblies[$index].Location ) {
"  `$null = [Reflection.Assembly]::LoadFrom( '" + $LoadedAssemblies[$index].Location + "' ) "
   } else {
"  `$null = [Reflection.Assembly]::Load( '" + $($T.Assembly.FullName) + "' ) "

   }
)
}
if(`$ExecutionContext.SessionState.Module.Guid -ne (Get-BootsModule).Guid) {
	Write-Debug `"$($T.Name) not invoked in PowerBoots context. Attempting to reinvoke.`"
   `$scriptParam = `$PSBoundParameters
   return iex `"& (Get-BootsModule) '`$(`$MyInvocation.MyCommand.Path)' ```@PSBoundParameters`"
}
# Write-Host ""$($T.Name) in module `$(`$executioncontext.sessionstate.module) context!"" -fore Green


function Global:New-$TypeName {
<#
.Synopsis
   Create a new $($T.Name) object
.Description
   Generates a new $TypeName object, and allows setting all of it's properties
.Notes
 AUTHOR:    Joel Bennett http://HuddledMasses.org
 LASTEDIT:  $(Get-Date)
#>
 
$Parameters
BEGIN {
   `$DObject = New-Object $TypeName
   `$All = Get-Parameter New-$TypeName | ForEach-Object { `$_.Key } | Sort
}
PROCESS {
"
if(!$collectable) {
"
   # The content of $TypeName is not a collection
   # So if we're in a pipeline, make a new $($T.Name) each time
   if(`$_) { 
      `$DObject = New-Object $TypeName
   }
"
}

'Set-PowerBootsProperties $PSBoundParameters ([ref]$DObject) $All'

if(!$collectable) {
@'
   Microsoft.PowerShell.Utility\Write-Output $DObject
} #Process
'@
   } else {
@'
} #Process
END {
   Microsoft.PowerShell.Utility\Write-Output $DObject
}
'@
   }
@"
}
                                                                        
New-$TypeName `@PSBoundParameters
"@
)

         Set-Content -Path $ScriptPath -Value $Function
      }
      New-Alias -Name $T.Name "New-$TypeName" -EA "SilentlyContinue" -Scope Global
   }                                                         
}#PROCESS
}#Add-BootsFunction
# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUNulWQrLED0HZAfYTVBI9b/RI
# c+aggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
# EwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERp
# Z2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMDcxMDI0MjIwMTQ1WhcNMTIxMDI0MjIw
# MTQ1WjCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzAp
# BgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNV
# BAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1lZGlhdGUgT2JqZWN0
# IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyiOLIjUemqAbPJ1J
# 0D8MlzgWKbr4fYlbRVjvhHDtfhFN6RQxq0PjTQxRgWzwFQNKJCdU5ftKoM5N4YSj
# Id6ZNavcSa6/McVnhDAQm+8H3HWoD030NVOxbjgD/Ih3HaV3/z9159nnvyxQEckR
# ZfpJB2Kfk6aHqW3JnSvRe+XVZSufDVCe/vtxGSEwKCaNrsLc9pboUoYIC3oyzWoU
# TZ65+c0H4paR8c8eK/mC914mBo6N0dQ512/bkSdaeY9YaQpGtW/h/W/FkbQRT3sC
# pttLVlIjnkuY4r9+zvqhToPjxcfDYEf+XD8VGkAqle8Aa8hQ+M1qGdQjAye8OzbV
# uUOw7wIDAQABo4ICfzCCAnswDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwHQYD
# VR0OBBYEFNBOD0CZbLhLGW87KLjg44gHNKq3MIGoBgNVHSMEgaAwgZ2AFE4L7xqk
# QFulF2mHMMo0aEPQQa7yoYGBpH8wfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
# YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
# IFNpZ25pbmcxKTAnBgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9y
# aXR5ggEBMAkGA1UdEgQCMAAwPQYIKwYBBQUHAQEEMTAvMC0GCCsGAQUFBzAChiFo
# dHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQwYAYDVR0fBFkwVzAsoCqg
# KIYmaHR0cDovL2NlcnQuc3RhcnRjb20ub3JnL3Nmc2NhLWNybC5jcmwwJ6AloCOG
# IWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDCBggYDVR0gBHsweTB3
# BgsrBgEEAYG1NwEBBTBoMC8GCCsGAQUFBwIBFiNodHRwOi8vY2VydC5zdGFydGNv
# bS5vcmcvcG9saWN5LnBkZjA1BggrBgEFBQcCARYpaHR0cDovL2NlcnQuc3RhcnRj
# b20ub3JnL2ludGVybWVkaWF0ZS5wZGYwEQYJYIZIAYb4QgEBBAQDAgABMFAGCWCG
# SAGG+EIBDQRDFkFTdGFydENvbSBDbGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRl
# IE9iamVjdCBTaWduaW5nIENlcnRpZmljYXRlczANBgkqhkiG9w0BAQUFAAOCAgEA
# UKLQmPRwQHAAtm7slo01fXugNxp/gTJY3+aIhhs8Gog+IwIsT75Q1kLsnnfUQfbF
# pl/UrlB02FQSOZ+4Dn2S9l7ewXQhIXwtuwKiQg3NdD9tuA8Ohu3eY1cPl7eOaY4Q
# qvqSj8+Ol7f0Zp6qTGiRZxCv/aNPIbp0v3rD9GdhGtPvKLRS0CqKgsH2nweovk4h
# fXjRQjp5N5PnfBW1X2DCSTqmjweWhlleQ2KDg93W61Tw6M6yGJAGG3GnzbwadF9B
# UW88WcRsnOWHIu1473bNKBnf1OKxxAQ1/3WwJGZWJ5UxhCpA+wr+l+NbHP5x5XZ5
# 8xhhxu7WQ7rwIDj8d/lGU9A6EaeXv3NwwcbIo/aou5v9y94+leAYqr8bbBNAFTX1
# pTxQJylfsKrkB8EOIx+Zrlwa0WE32AgxaKhWAGho/Ph7d6UXUSn5bw2+usvhdkW4
# npUoxAk3RhT3+nupi1fic4NG7iQG84PZ2bbS5YxOmaIIsIAxclf25FwssWjieMwV
# 0k91nlzUFB1HQMuE6TurAakS7tnIKTJ+ZWJBDduUbcD1094X38OvMO/++H5S45Ki
# 3r/13YTm0AWGOvMFkEAF8LbuEyecKTaJMTiNRfBGMgnqGBfqiOnzxxRVNOw2hSQp
# 0B+C9Ij/q375z3iAIYCbKUd/5SSELcmlLl+BuNknXE0wggc0MIIGHKADAgECAgFR
# MA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
# b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2ln
# bmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMiBQcmltYXJ5IEludGVybWVk
# aWF0ZSBPYmplY3QgQ0EwHhcNMDkxMTExMDAwMDAxWhcNMTExMTExMDYyODQzWjCB
# qDELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5ldyBZb3JrMRcwFQYDVQQHEw5XZXN0
# IEhlbnJpZXR0YTEtMCsGA1UECxMkU3RhcnRDb20gVmVyaWZpZWQgQ2VydGlmaWNh
# dGUgTWVtYmVyMRUwEwYDVQQDEwxKb2VsIEJlbm5ldHQxJzAlBgkqhkiG9w0BCQEW
# GEpheWt1bEBIdWRkbGVkTWFzc2VzLm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAMfjItJjMWVaQTECvnV/swHQP0FTYUvRizKzUubGNDNaj7v2dAWC
# rAA+XE0lt9JBNFtCCcweDzphbWU/AAY0sEPuKobV5UGOLJvW/DcHAWdNB/wRrrUD
# dpcsapQ0IxxKqpRTrbu5UGt442+6hJReGTnHzQbX8FoGMjt7sLrHc3a4wTH3nMc0
# U/TznE13azfdtPOfrGzhyBFJw2H1g5Ag2cmWkwsQrOBU+kFbD4UjxIyus/Z9UQT2
# R7bI2R4L/vWM3UiNj4M8LIuN6UaIrh5SA8q/UvDumvMzjkxGHNpPZsAPaOS+RNmU
# Go6X83jijjbL39PJtMX+doCjS/lnclws5lUCAwEAAaOCA4EwggN9MAkGA1UdEwQC
# MAAwDgYDVR0PAQH/BAQDAgeAMDoGA1UdJQEB/wQwMC4GCCsGAQUFBwMDBgorBgEE
# AYI3AgEVBgorBgEEAYI3AgEWBgorBgEEAYI3CgMNMB0GA1UdDgQWBBR5tWPGCLNQ
# yCXI5fY5ViayKj6xATCBqAYDVR0jBIGgMIGdgBTQTg9AmWy4SxlvOyi44OOIBzSq
# t6GBgaR/MH0xCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
# KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMSkwJwYD
# VQQDEyBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eYIBFTCCAUIGA1Ud
# IASCATkwggE1MIIBMQYLKwYBBAGBtTcBAgEwggEgMC4GCCsGAQUFBwIBFiJodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIG3BggrBgEFBQcC
# AjCBqjAUFg1TdGFydENvbSBMdGQuMAMCAQEagZFMaW1pdGVkIExpYWJpbGl0eSwg
# c2VlIHNlY3Rpb24gKkxlZ2FsIExpbWl0YXRpb25zKiBvZiB0aGUgU3RhcnRDb20g
# Q2VydGlmaWNhdGlvbiBBdXRob3JpdHkgUG9saWN5IGF2YWlsYWJsZSBhdCBodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMGMGA1UdHwRcMFowK6ApoCeG
# JWh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL2NydGMyLWNybC5jcmwwK6ApoCeGJWh0
# dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydGMyLWNybC5jcmwwgYkGCCsGAQUFBwEB
# BH0wezA3BggrBgEFBQcwAYYraHR0cDovL29jc3Auc3RhcnRzc2wuY29tL3N1Yi9j
# bGFzczIvY29kZS9jYTBABggrBgEFBQcwAoY0aHR0cDovL3d3dy5zdGFydHNzbC5j
# b20vY2VydHMvc3ViLmNsYXNzMi5jb2RlLmNhLmNydDAjBgNVHRIEHDAahhhodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEFBQADggEBACY+J88ZYr5A
# 6lYz/L4OGILS7b6VQQYn2w9Wl0OEQEwlTq3bMYinNoExqCxXhFCHOi58X6r8wdHb
# E6mU8h40vNYBI9KpvLjAn6Dy1nQEwfvAfYAL8WMwyZykPYIS/y2Dq3SB2XvzFy27
# zpIdla8qIShuNlX22FQL6/FKBriy96jcdGEYF9rbsuWku04NqSLjNM47wCAzLs/n
# FXpdcBL1R6QEK4MRhcEL9Ho4hGbVvmJES64IY+P3xlV2vlEJkk3etB/FpNDOQf8j
# RTXrrBUYFvOCv20uHsRpc3kFduXt3HRV2QnAlRpG26YpZN4xvgqSGXUeqRceef7D
# dm4iTdHK5tIxggI0MIICMAIBATCBkjCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoT
# DVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmlj
# YXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJ
# bnRlcm1lZGlhdGUgT2JqZWN0IENBAgFRMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBQTom0cCYji
# WE1N4j3Mxxs83KXyjTANBgkqhkiG9w0BAQEFAASCAQCJ8Dn7PHoh33J/hmDSlhK0
# rKj56dVmj0Wlgjpyawtp3Q88hyamTUxqobwl86vBH/mTGy1XJRmqnzhb4/4uld9X
# R6apwqkvYCWs+WeKyProvTGayedzs7P4vJ8l0LW4mxEbwQNESULLlB8BY7DXZZ8n
# ev5FUwvXeUQjHoTyawJq9KYMzQJnUA8LriSK2wxQ805yNzuAKuiRoEZ+aqRRxVco
# m2Jqh3bfK1nWrty7DCPPMNR/1cPT8CdqAM/QewkVkvOCXs+mhC+s1QjH5ei1RHKO
# vGur1CdpvNo6dcFnTPJ62dKucvCckhUHPiOByQcwPCsH2atOc2lVW1GIYziGf3Ku
# SIG # End signature block
