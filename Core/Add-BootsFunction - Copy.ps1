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
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUnkaadEyNxxrbWHgL44+PLHU6
# J22gggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUq7+oyZjs
# 0VwI5kT7IYXHniPx7gEwDQYJKoZIhvcNAQEBBQAEggEAALcrN9MZSFEPe8o6xuTC
# AEvg9f2+/hhGUOat/rX7bUZf2V8Y06PTZA1EOHH7i5PEOegil4r0324tHoLjDC/d
# fyTpL5ZwrmgELOGkIwhx0WjKqYVqMpr+nBXlGXA7g4ZTElBzC+0VRTSDal3BwYw2
# qicg09H/VKavKEsrH/2v6GJ89mgUgdguiMYkJckSGuTkKw9jtHMt++i9Ej8/cGV1
# MsXBXzLpeFZ8B7/HCOgE6JZw1YZ8u24nT8YO4nsJCtMSqvQll8kwMc7JEhae+U9Y
# lhvVfBjOibqfP0Zx70GdASKyj2ID7k42g3UNTAzlUuAoJNufgtHvwIEWuRUhSKaW
# Qg==
# SIG # End signature block
