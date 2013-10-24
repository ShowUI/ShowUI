function Start-PowerShellCommand
{
    <#
    .Synopsis
        Starts a PowerShell Command
    .Description
        Starts a PowerShell command that has been Registered with Register-PowerShellCommand

        Once a command has been started, you can use Get-Job and Receive-Job to see if there are errors
    .Parameter name
        The name of the command to start
    .Parameter interval
        If set, will run the command continuously at the specified interval
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
    .LINK
        Register-PowerShellCommand
    .LINK
        Stop-PowerShellCommand
    .LINK
        Unregister-PowerShellCommand        
    #>
    param(
        [Parameter(ValueFromPipeline=$true, 
            ValueFromPipelineByPropertyName=$true,
            Position=0)]
        $name,
        [Parameter(ValueFromPipelineByPropertyName=$true,
            Position=1)]
        [Timespan]$interval = [Timespan]"0"
    )
    
    process {
        if ($window) {
            if ($window.Resources.Scripts.$Name) {
                if (-not $interval.TotalMilliseconds) {
                    if( $window.Resources.Scripts.$name | Get-Member Interval ) {
                        $interval = $window.Resources.Scripts.$name.Interval
                    }
                }
                if (-not $interval.TotalMilliseconds) {
                    & $window.Resources.Scripts.$Name
                } else {           
                    if ($window.Resources.Timers."Run-$name") {
                        $window.Resources.Timers."Run-$name".Stop()
                        $window.Resources.Timers."Run-$name" = $null
                    }
                    $window.Resources.Timers."Run-$name" = (New-Object Windows.Threading.DispatcherTimer).PSObject.BaseObject
                    $window.Resources.Timers."Run-$name".Interval = $interval
                    $window.Resources.Timers."Run-$name".add_Tick($window.Resources.Scripts.$name)
                    $window.Resources.Timers."Run-$name".Start()
                }            
            } else {
                Write-Warning "Named command not found, can't Start-PowerShellCommand"
            }
        } else {
            Write-Warning "Window not found, can't Start-PowerShellCommand"
        }
    }    
}
