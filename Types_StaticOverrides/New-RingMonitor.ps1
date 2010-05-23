#requires -version 2.0
# ALSO REQUIRES PowerBoots preloaded http://boots.codeplex.com
# ALSO REQUIRES DynamicDataDisplay.dll in PowerBoots path http://dynamicdatadisplay.codeplex.com
[CmdletBinding()]
Param(
   [TimeSpan]$global:Interval = "00:00:02",
   [Int]$global:RingSize = 200
)
## You have to get the DynamicDataDisplay control, and put it's DLLs in the PowerBoots folder...
ls "$PowerBootsPath\DynamicDataDisplay*.dll" | Add-BootsFunction

Add-BootsFunction -Type System.Windows.Media.Pen
Add-BootsFunction -Type System.Windows.Media.SolidColorBrush

## This sets up all the types, and requires the accelerators and the DynamicDataDisplay.dll 
$accelerate = [type]::gettype("System.Management.Automation.TypeAccelerators") 
$accelerate::Add( "TimedDouble", "System.Collections.Generic.KeyValuePair[DateTime,Double]" )
$accelerate::Add( "TimedDoubleRing", "Microsoft.Research.DynamicDataDisplay.Common.RingArray[System.Collections.Generic.KeyValuePair[DateTime,Double]]" )
$accelerate::Add( "EnumerableDataSource", "Microsoft.Research.DynamicDataDisplay.DataSources.EnumerableDataSource``1" )

function Global:Add-Monitor {
#.Synopsis
#  Create a new monitor line
   Param(
      [String]$global:Label="HuddledMasses", 
      [ScriptBlock]$global:Script= { 
         New-Object TimedDouble (Get-Date), ([regex]"time=(\d+)ms").Match( (ping.exe "HuddledMasses.org" -n 1) ).Groups[1].Value 
      },      
      $global:XMapping = $(Get-Delegate "System.Func[TimedDouble, Double]" { param([TimedDouble]$value); $value.Key.TimeOfDay.TotalSeconds }),
      $global:YMapping = $(Get-Delegate "System.Func[TimedDouble, Double]" { param([TimedDouble]$value); $value.Value; write-Host "beep: $($value.Value)" -fore yellow })
   )

   Invoke-BootsWindow $Global:Plotter {
      #  $dataSource = New-Object "EnumerableDataSource[TimedDoubleRing]" (New-Object TimedDoubleRing $global:RingSize)
      $ctor = [EnumerableDataSource[TimedDouble]].GetConstructor( ([System.Collections.Generic.IEnumerable``1]) )
      $Global:dataSource = $ctor.invoke( (,[TimedDoubleRing](New-Object TimedDoubleRing $global:RingSize)) )
      $dataSource.SetXMapping( $global:XMapping )
      $dataSource.SetYMapping( $global:YMapping )
      $Global:Plotter.Children.Add( (
         LineGraph -Description $(New-Object Microsoft.Research.DynamicDataDisplay.PenDescription $global:Label) `
                   -DataSource $Global:dataSource -Filters { InclinationFilter; FrequencyFilter } `
                   -LinePen (Pen -Brush (SolidColorBrush -Color $([Microsoft.Research.DynamicDataDisplay.ColorHelper]::CreateRandomHsbColor())) -Thickness 2.0) `
                   -Tag {$global:Script} -Name $($global:Label -replace "[^\p{L}]")
      ))
   }
}

function Global:Remove-Monitor {
#.Synopsis
#   Remove a monitor line
   Param( [String]$global:Label="HuddledMasses" )

   Invoke-BootsWindow $Global:Plotter {
      $Global:Plotter.Children.Remove( $(
         $Global:Plotter.Children | 
            Where-Object { ($_ -is [Microsoft.Research.DynamicDataDisplay.LineGraph]) -and ($_.Name -eq $Global:Label) } |
            Select -First 1 ) )
   }
}

function Global:Update-Ring {
#.Synopsis
#   Internal function for updating all the data lines
   Write-Host "tick, " -noNewLine -fore cyan
   foreach($graph in $Global:Plotter.Children | ?{$_ -is [Microsoft.Research.DynamicDataDisplay.LineGraph]} ) {
      $graph.DataSource.Data.Add( (&$graph.Tag | %{ Write-Host $_; $_ }) )
      write-host "Data: $($graph.DataSource.Data|out-String)" -fore Yellow
   }
}

Function Global:New-RingMonitor {
#.Synopsis
#  Creates a new Ring Monitor graph window, and sets the update interval for it
[CmdletBinding()]
Param(
   [TimeSpan]$global:Interval = "00:00:02",
   [Int]$global:RingSize = 200
)

   New-BootsWindow {
      Param($global:w)
      $w.Tag = DispatcherTimer -Interval $global:Interval -On_Tick Update-Ring
      $w.Tag.Start()
      $w.Add_Closed( { $this.Tag.Stop() } )

      ChartPlotter | Tee -Var Global:Plotter
   } -Width 800 -Height 600 -Async -Title "Ring Monitor"
} #-WindowStyle None -AllowsTransparency -Background Transparent -On_MouseLeftButtonDown { $this.DragMove() } -ResizeMode CanResizeWithGrip

New-RingMonitor @PSBoundParameters











function Get-Delegate {
#.Synopsis
#   Use Reflection and IL to emit arbitrary delegates for PowerShell 1.0 -> 2.0 CTP3
#.Link
#   http://blogs.msdn.com/powershell/archive/2006/07/25/678259.aspx
#.Link
#   http://poshcode.org/194
###################################################################################################
param([type] $type, [ScriptBlock] $scriptBlock)

if($PSVersionTable.BuildVersion -gt "6.1.7000.0") {
   return $ScriptBlock -as $type
}

# Helper function to emit an IL opcode
function emit($opcode)
{
    if ( ! ($op = [System.Reflection.Emit.OpCodes]::($opcode)))
    {
        throw "new-method: opcode '$opcode' is undefined"
    }

    if ($args.Length -gt 0)
    {
        $ilg.Emit($op, $args[0])
    }
    else
    {
        $ilg.Emit($op)
    }
}

# Get the method info for this delegate invoke...
$delegateInvoke = $type.GetMethod("Invoke")

# Get the argument type signature for the delegate invoke
$parameters = @($delegateInvoke.GetParameters())
$returnType = $delegateInvoke.ReturnParameter.ParameterType

$argList = new-object Collections.ArrayList
[void] $argList.Add([ScriptBlock])
foreach ($p in $parameters)
{
    [void] $argList.Add($p.ParameterType);
}

$dynMethod = new-object reflection.emit.dynamicmethod ("",
    $returnType, $argList.ToArray(), [object], $false)
$ilg = $dynMethod.GetILGenerator()

# Place the scriptblock on the stack for the method call
emit Ldarg_0

emit Ldc_I4 ($argList.Count - 1)  # Create the parameter array
emit Newarr ([object])

for ($opCount = 1; $opCount -lt $argList.Count; $opCount++)
{
    emit Dup                    # Dup the array reference
    emit Ldc_I4 ($opCount - 1); # Load the index
    emit Ldarg $opCount         # Load the argument
    if ($argList[$opCount].IsValueType) # Box if necessary
 {
        emit Box $argList[$opCount]
 }
    emit Stelem ([object])  # Store it in the array
}

# Now emit the call to the ScriptBlock invoke method
emit Call ([ScriptBlock].GetMethod("InvokeReturnAsIs"))

if ($returnType -eq [void])
{
    # If the return type is void, pop the returned object
    emit Pop
}
else
{
    # Otherwise emit code to convert the result type which looks
    # like LanguagePrimitives.ConvertTo(value, type)

    $signature = [object], [type]
    $convertMethod =
        [Management.Automation.LanguagePrimitives].GetMethod(
            "ConvertTo", $signature);
    $GetTypeFromHandle = [Type].GetMethod("GetTypeFromHandle");
    emit Ldtoken $returnType  # And the return type token...
    emit Call $GetTypeFromHandle
    emit Call $convertMethod
}
emit Ret

#
# Now return a delegate from this dynamic method...
#

$dynMethod.CreateDelegate($type, $scriptBlock)
}

####################################################################################################
## Examples: Hopefully you get the idea you can graph anything you like....
####################################################################################################
# New-RingMonitor
#
# Add-Monitor Memory { 
#      New-Object TimedDouble (Get-Date), (gwmi Win32_PerfFormattedData_PerfOS_Memory AvailableBytes).AvailableBytes
# }
#
# Add-Monitor CPU { 
#     New-Object TimedDouble (Get-Date), (gwmi Win32_PerfFormattedData_PerfOS_Processor PercentIdleTime,Name |?{$_.Name -eq "_Total"}).PercentIdleTime
# }
# ## Yuck. those two numbers won't work together, because they're too far apart.
# ## Let's remove the first one and make it percentage based
# Remove-Monitor Memory
#
# Add-Monitor Memory { New-Object TimedDouble (Get-Date), ((gwmi Win32_PerfFormattedData_PerfOS_Memory AvailableBytes).AvailableBytes / (gwmi Win32_ComputerSystem TotalPhysicalMemory).TotalPhysicalMemory * 100) }
#
####################################################################################################
# New-RingMonitor
#
# Add-Monitor Twitter { 
#    New-Object TimedDouble (Get-Date), ([regex]"time=(\d+)ms").Match( (ping.exe "Twitter.com" -n 1) ).Groups[1].Value 
# }

# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZFT/+CGXgE59ouBY/D78KLjt
# zmSggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBTNzzAqT8zC
# /1ExH6Swo3EUuxwURjANBgkqhkiG9w0BAQEFAASCAQCbTngWFILK8S9DVz/Hz+vR
# SzeAe5drUUGy5q1JGuvTugLdNtY7WxVh6MyTSopradbpJXkQHzanPWV/VLNHagOd
# IksbGOrt1aIIoFT77KAXPusDpNKlyk4UoARkgflXz599kXlI9PeuRDq5lWevERmY
# q5fLG36+npdIQqeMvY5pJrQTDgoYkWLjj+dps/HPsVKP2ZohAJxptYrIt4fOjc48
# eDAVxJuVySd5w2QjyVext2lLNAeFgvzyA2BpwnZD4nsYc+GTS1uQZmlaRsdynGtV
# n1VyeetUlNEjG4mt9zKF7jUPG1CDLNbBAx1QZ471MjWGf4vKZtHs+DHygLDnqorl
# SIG # End signature block
