function Start-WPFJob
{
    <#
    .Synopsis
        Starts a WPF Job to display a UI in the background
    .Description
        Starts a WPF Job to display a UI in the background.
        You can stop the job with the Stop-Job cmdlet, or by closing the window.
        You can run scripts within the window with the Update-WPFJob cmdlet
        Start-WPFJob is used implicitly whenever you use the -AsJob parameter.
    .Example
        New-Label "Hello World" -AsJob 
    .Example
        Start-WPFJob { New-Object Windows.Window -Property @{Content="foo"}}
    #>
    param(
    # The Script Block to run in the Job 
    [Parameter(Position=0,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [ScriptBlock]
    $ScriptBlock,
    
    # A dictionary of parameters to pass to the job
    [Hashtable]
    $Parameter,
    
    # The Command that the Job will display in Get-Job (by default, Start-WPFJob)
    [String]
    $Command = "Start-WPFJob",
    
    # Additional Context script blocks will be parsed to get the commands 
    # the script block uses, but will not be run.
    # AdditionalContext is used so that commands referenced in parameters 
    # work in background jobs.
    [ScriptBlock[]]
    $AdditionalContext,
    
    # The name of the job
    [String]
    $Name
    )

    process {            
        $src= @($ScriptBlock) + {
            Show-Window 
            Get-ChildControl
            Move-Control
            Start-Animation
            Get-Resource
            Set-Resource
        } 
        if ($AdditionalContext) { $src += $AdditionalContext }
        $cmds = $src | 
            Get-ReferencedCommand |
            Select-Object -Unique
        if (-not $name) {$name = [GUID]::NewGuid() } 
        $iss = [ShowUI.WPFJob]::GetSessionStateForCommands($cmds)       
        if ($psBoundParameters.ContainsKey("Parameter") -and $Parameter.Count) {
            $wpfJob = New-Object ShowUI.WPFJob ($name, $Command,
                $ScriptBlock, $Iss, $Parameter)
        } else {
            $wpfJob = New-Object ShowUI.WPFJob ($name, $Command,
                $ScriptBlock, $Iss)
        }
        if ($wpfJob) {
            $null = $PSCmdlet.JobRepository.Add($wpfJob)
            $wpfJob
        }
    }
} 
