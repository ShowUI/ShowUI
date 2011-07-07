function Unregister-PowerShellCommand
{
    <#
    .Synopsis
        Unregisters a PowerShell command registered to a Window
    .Description
        Unregisters a PowerShell command registered to a window, and stops and running instances of isolated commands    
    .Parameter name
        The name of the command to unregister   
    .Example
        # Create a stop watch in PowerShell
        New-Grid -Rows 2 -Columns 2 {
            New-Label -Name Stopwatch "0:0:0" -ColumnSpan 2
            New-Button -Row 1 -Column 0 Start -On_Click {
                $window | 
                    Get-ChildControl StopWatch | ForEach-Object {
                        $_.Tag = Get-Date
                    }
                Register-PowerShellCommand -name "UpdateClock" -scriptBlock {
                    $stopWatch = $window | 
                        Get-ChildControl StopWatch
                    $stopWatch.Content = [Datetime]::Now - $stopWatch.Tag
                } -in ([Timespan]::FromMilliseconds(25)) -run
            } 
            New-Button -Row 1 -Column 1 Stop -On_Click {
                Unregister-PowerShellCommand -name "UpdateClock"  
            }
        } -show            
    #>
    param(
    [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    $name    
    )
    process {        
        if ($window) {
            if ($name) {
                Stop-PowerShellCommand $name
            }
            if ($window.Resources.Scripts.$name) {
                $null = $window.Resources.Scripts.Remove($name) 
            }
        }
    }
}
