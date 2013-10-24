function Register-PowerShellCommand {
    <#
    .Synopsis
        Registers a PowerShell scriptblock command for use within a window
    .Description
        Registers a PowerShell scriptblock for use within a window.
        The command can be run registered for one time use, or it can register anonymously, or it can register for use at a regular interval.

        Once a command has been started (by using the -Run parameter, or Start-PowerShellCommand), you can use Get-Job and Receive-Job to see if there are errors
    .Parameter Name
        The name of the PowerShell command
    .Parameter ScriptBlock
        The script block to run
    .Parameter Interval
        The repeat interval of the command.
    .Parameter Run
        If set, will start running the command as soon as it is registered
    .Parameter Once
        If set, will only run the command once
    .Example
New-Label "$($d = Get-Date ;$d.ToLongDateString() + ' ' + $d.ToLongTimeString())" `
    -FontSize 24 -SizeToContent WidthAndHeight `
    -On_Loaded {
        Register-PowerShellCommand -scriptBlock {     
            $d = Get-Date
            $content = $d.ToLongDateString() + " " + $d.ToLongTimeString()       
            $window.Content.Content = $content
        } -Run -Interval "0:0:0.5"
    } -AsJob
    .LINK
        Start-PowerShellCommand
    .LINK
        Stop-PowerShellCommand
    .LINK
        Unregister-PowerShellCommand
    #>
    param(
    [Parameter(Position=0, Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('Definition')]
    [ScriptBlock]
    $ScriptBlock,
    
    [Parameter(Position=1, Mandatory=$false, ValueFromPipelineByPropertyName=$true)]
    [Timespan]$Interval = ([Timespan]0),
    
    [Parameter(ValueFromPipelineByPropertyName=$true)]
    $Name,
    
    [switch]$Run,
    
    [switch]$Once    
    )
    process {        
        $visual = $this
        if ($window) {
            if (-not $name) { $name = [GUID]::NewGuid().ToString() } 
            if ($once) {
                $window.Resources.Scripts.$name = [ScriptBlock]::Create(
                    ". Initialize-EventHandler`n${scriptBlock}`n" + { Unregister-PowerShellCommand } + " '$name'" 
                )
            } else {
                $window.Resources.Scripts.$name = [ScriptBlock]::Create(
                    ". Initialize-EventHandler`n${scriptBlock}" 
                )
            }
            if ($interval) {
                $window.Resources.Scripts.$name | Add-Member Interval $interval
            }
            if ($run) {                
                Start-PowerShellCommand $name -interval $interval
            }
        } else {
            Write-Warning "Window not found, can't Register-PowerShellCommand"
        }
    }
}
