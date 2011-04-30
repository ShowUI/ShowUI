#requires -version 2.0
# ALSO REQUIRES ShowUI preloaded http://ShowUI.codeplex.com
# ALSO REQUIRES DynamicDataDisplay.dll in ShowUI\BinaryAssemblies path http://dynamicdatadisplay.codeplex.com
[CmdletBinding()]
Param(
   [TimeSpan]$global:Interval = "00:00:02",
   [Int]$global:RingSize = 200
)
## You have to get the DynamicDataDisplay control, and put it's DLLs in the ShowUI folder...
ls "$($ShowUI.InstallPath)\BinaryAssemblies\DynamicDataDisplay*.dll" | Add-UIFunction

Add-UIFunction -Type System.Windows.Media.Pen
Add-UIFunction -Type System.Windows.Media.SolidColorBrush

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

   Invoke-UIWindow $Global:Plotter {
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

   Invoke-UIWindow $Global:Plotter {
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

   Show-UI {
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
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUZFT/+CGXgE59ouBY/D78KLjt
# zmSgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUzc8wKk/M
# wv9RMR+ksKNxFLscFEYwDQYJKoZIhvcNAQEBBQAEggEAVHOuNe9zaHkmO1PdqKqb
# 9OiOz5gJU66YnGhPoB5Yui5+ILBemIRd/cfp2oDo5f61T+SfEOi0dRVj0jhc2jxq
# 7vyBN+FTl+1cCjb8i+o2SNZCLKF35C06zleJo0B/Nij0U05JNGuJctcLfiMoPO9x
# NNLujMYD2R/yogogp1QtGpLbo/zKfq71/s57fvxoMg57qJVXGiMlZzEHnt8Mc4LD
# qdnumz9ZhA3L3+t8hQFq04IFl9nq8gFgABCjXZVvOCJC4NxWhKYt1BpnKi2tQTDq
# EH/btwHfa/DnNdnvh1XPNmkRoMksErV4Fwn9Mw2GqBkXEIpVHW4wUWCkE9zHvtm9
# fg==
# SIG # End signature block
