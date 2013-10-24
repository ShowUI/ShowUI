if($PSVersionTable.PSVersion -lt "3.0") {
    function Script:Get-ReferencedCommand { 
        <#
        .Synopsis
            Gets the commands referred to from within a function or external script
        .Description
            Uses the Tokenizer to get the commands referred to from within a function or external script    
        .Example
            Get-Command New-Button | Get-ReferencedCommand
        #>
        param(
        # The script block to search for command references
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$True,
            ValueFromPipelineByPropertyName=$true)]
        [ScriptBlock]
        $ScriptBlock
        ) 

        begin {
            if($VerbosePreference -gt 0) {
                Write-Verbose "Get-ReferencedCommand begin"
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            }        
            $commandsEncountered = @{}
        }
        process {   
            # $exc = $ExecutionContext.SessionState.PSVariable.Get("ExecutionContext").Value
            # $nsb = $exc.InvokeCommand.NewScriptBlock($scriptBlock) 
            [WPK.GetReferencedCommand]::GetReferencedCommands( $ScriptBlock, $ExecutionContext, $PSCmdlet)
        }
        end {
            if($VerbosePreference -gt 0) {
                $stopwatch.Stop();
                Write-Verbose "Get-ReferencedCommand end ($($stopwatch.Elapsed.TotalSeconds) s)"
            }
        }
    }
} else {
    function Script:ProcessReferencedShowUICommand {
        param (
            [Parameter(Mandatory=$true)]
            [System.Management.Automation.CommandInfo]
            $cmd,

            [string[]]$Exclude = @('%')
        )
        if ($cmd -and !$cachedCommandInfo.Contains($cmd) -and $cmd.Name -notin $Exclude) {
            [void]$cachedCommandInfo.Add(($cmd))
            Write-Output $cmd
            switch ($cmd.CommandType) {
                Alias    { ProcessReferencedShowUICommand $cmd.ResolvedCommand }
                Function { if ($Recurse) { $queue.Enqueue($cmd.ScriptBlock) }}
                Filter   { if ($Recurse) { $queue.Enqueue($cmd.ScriptBlock) }}
                ExternalScript { 
                    if ($Recurse) { 
                        try {
                            $ScriptBlock = $cmd.ScriptBlock
                            if (!$ScriptBlock) { $cmd.ValidateScriptInfo($null) }
                              $queue.Enqueue($ScriptBlock) 
                        } catch [Management.Automation.PSSecurityException] {
                            Write-Warning $_
                        }
                    }
                }
            }
        }
    }

    function Script:Get-ReferencedCommand { 
        <#
        .Synopsis
            Gets the commands referred to from within a ScriptBlock
        .Description
            Uses the ScriptBlock's AST to to get the commands referred to (recursively)     
        .Example
            { Show-Window } | Get-ReferencedCommand
        #>
        param(
            [Parameter(Mandatory=$true,
                ValueFromPipeline=$True,
                ValueFromPipelineByPropertyName=$true)]
            [ScriptBlock] $ScriptBlock, # The script block to search for command references

            [string[]]$Exclude = @('%'),

            [switch]$Recurse = $true
        ) 

        begin {
            Set-StrictMode -Version 3
            if($VerbosePreference -gt 0) {
                Write-Verbose "Get-ReferencedCommand begin"
                $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            }
            $queue = new-object `
                "System.Collections.Generic.Queue[[ScriptBlock]]"
            $cachedCommandName = new-object `
                "System.Collections.Generic.HashSet[[string]]"
            $cachedCommandInfo = new-object `
                "System.Collections.Generic.HashSet[[System.Management.Automation.CommandInfo]]"
        }

        process {   
            $queue.Enqueue($ScriptBlock)
        }

        end {
            while (!$pscmdlet.Stopping -and $queue.Count) {
                $ScriptBlock = $queue.Dequeue()
                $cachedCommandName = new-object "System.Collections.Generic.HashSet[[string]]"
        
                $ScriptBlock.Ast.FindAll( { 
                    !$pscmdlet.Stopping -and 
                        $args[0] -is [Management.Automation.Language.FunctionDefinitionAst] 
                 }, $true ) | % { 
                    [void]$cachedCommandName.Add($_.Name)
                 }
                
                $ScriptBlock.Ast.FindAll( { 
                    !$pscmdlet.Stopping -and 
                        $args[0] -is [Management.Automation.Language.CommandAst] 
                 }, $true ) | % { 
                    $node = $_
                    try {
                        if ($node.InvocationOperator -eq "Unknown") {
                            $name = $node.CommandElements[0].value
                            if (!$cachedCommandName.Contains($name)) {
                                [void]$cachedCommandName.Add($name)
                                $cmd = Get-Command $name -ErrorAction SilentlyContinue -ErrorVariable GetCommandError
                                if ($cmd) {
                                    ProcessReferencedShowUICommand $cmd -Exclude:$Exclude
                                } else { 
                                    $location = if ($_.Extent.File) { $_.Extent.File } else { "<ScriptBlock>" }
                                    $location += ":$($_.Extent.StartLineNumber),$($_.Extent.StartColumnNumber)"
                                    Write-Warning "$GetCommandError`r`n at $location" 
                                }
                            }
                        }
                    } catch { 
                        Write-Warning "Unexpected warning processing command $node : $_"
                    }
                }
            }
            if($VerbosePreference -gt 0) {
                $stopwatch.Stop();
                Write-Verbose "Get-ReferencedCommand end ($($stopwatch.Elapsed.TotalSeconds) s)"
            }
        }
    }
}