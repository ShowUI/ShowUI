function Stop-PowerShellCommand
{
    <#
    .Synopsis
        Stops a PowerShell Command
    .Description
        Stops a PowerShell command that has been Registered with Register-PowerShellCommand
    .Parameter name
        The name of the command to stop
    .Example
        New-Grid -Rows 2 -Columns 2 -On_Loaded {
                Register-PowerShellCommand -name UpdateClock -scriptBlock {
                    $stopWatch = $window | 
                        Get-ChildControl StopWatch
                    $stopWatch.Content = [Datetime]::Now - $stopWatch.Tag
                }
            } {
            New-Label -Name Stopwatch "0:0:0" -ColumnSpan 2
            New-Button -Row 1 -Column 0 Start -On_Click {
                $window | 
                    Get-ChildControl StopWatch | ForEach-Object {
                        $_.Tag = Get-Date
                    }
                Start-PowerShellCommand "UpdateClock" -interval ([Timespan]::FromMilliseconds(25))
            } 
            New-Button -Row 1 -Column 1 Stop -On_Click {
                Stop-PowerShellCommand "UpdateClock"  
            }
        } -show    
    #>    
    param(
    [Parameter(ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
    $name
    )
    process {
        if ($window) {
            if ($window.Resources.Scripts.$Name) {
                if ($window.Resources.Timers."Run-$name") {
                    $window.Resources.Timers."Run-$Name" | ForEach-Object {
                        if ($_) { $_.Stop() } 
                    }
                } 
            }    
        }    
    }
}
