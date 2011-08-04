function Invoke-Background
{
    [CmdletBinding(DefaultParameterSetName='ScriptBlock')]
    param(
    # A Script block to run in the background.
    # To pass parameters to this script block, add a param() statement
    [Parameter(Mandatory=$true,ParameterSetName='ScriptBlock',Position=0)]
    [ScriptBlock]$ScriptBlock,
    
    # Invoke a command in the background
    [Parameter(Mandatory=$true,ParameterSetName='Command',Position=0)]
    [string]
    $Command,    
    
    [Hashtable]$Parameter,    
    $control = $this,
    [ValidateScript({
        if ($_.RunspaceStateInfo.State -ne 'Opened') {
            throw 'If a runspace is provided, it must be opened'
        }
        return $true
    })]
    [Management.Automation.Runspaces.Runspace]$InRunspace,
    [Switch]$DoNotAutomaticallyCreate,
    [Switch]$CreateDataContextHere,
    [Switch]$ResetDataSource,
    
    [System.Management.Automation.ScriptBlock[]]
    ${On_PropertyChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_OutputChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ErrorChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_WarningChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_DebugChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_VerboseChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ProgressChanged},
    
    [System.Management.Automation.ScriptBlock[]]
    ${On_IsRunningChanged},
    
    [System.Management.Automation.ScriptBlock[]]
    ${On_IsFinishedChanged},
    
    [System.Management.Automation.ScriptBlock[]]
    ${On_TimeStampedOutputChanged}    
    ) 
    
    process {
        if (-not $control ) { return } 
        $parent = Get-ParentControl -Control $control
        if (-not $parent) { $createDataContextHere = $true}
        if ($createDataContextHere) { 
            $target = $control
        } else {
            $target = $parent
        } 
        

                                           
        
        
        if ($ResetDataSource -or 
            $target.DataContext -isnot [ShowUI.PowerShellDataSource]) {
            
            if ($target.DataContext) {
                Write-Debug "Overwriting existing data context"
            }
              
            
            $target.DataContext = Get-PowerShellDataSource -Parent $target -Script { 
                
            }
            
            if ($target.CommandBindings.Add) {
                if (-not $target.CommandsBindings.Count) { 
                    $cmdBind = New-Object Windows.Input.CommandBinding @(
                        [ShowUI.ShowUICommands]::BackgroundPowerShellCommand,{
                            . Initialize-EventHandler
                            $sb = try { [ScriptBlock]::Create($_.Parameter) } catch { }
                            Invoke-Background -ScriptBlock $sb
                            trap {
                                . Write-WPFError
                                continue
                            }
                        }, {
                            $sb = try { [ScriptBlock]::Create($_.Parameter) } catch { }
                            . Initialize-EventHandler                                                        
                            $_.CanExecute = -not (Get-PowerShellOutput -GetDataSource | Select-Object -ExpandProperty IsRunning)
                            trap {
                                . Write-WPFError
                                continue
                            }
                        }
                    )
                    $target.CommandBindings.Add($cmdBind)
                }                
            }                                     
        }                                         
        
        $eventParameters = @{}
        foreach ($eventName in ($psBoundParameters.Keys -like "On_*")) {
            $eventParameters.$eventName = $psBoundParameters[$eventName]
        } 
        $handlerNames = @($target.DataContext.Resources.EventHandlers.Keys)
        if ($handlerNames) {
            foreach ($handler in $handlerNames) {
                $handlerMethod  = "remove_$($handler.Substring(3))"
                $target.DataContext.$handlerMethod.Invoke($target.DataContext.Resources.EventHandlers[$handler])
                $null = $target.DataContext.Resources.EventHandlers.Remove($handler)
            }
        }
        
        Set-Property -inputObject $target.DataContext -property $eventParameters 
        
        
        $target.DataContext.Parent = $target
        $target.DataContext.Command.Commands.Clear()
        
        if ($InRunspace) {
            $target.DataContext.Command.Runspace = $InRunspace            
        }
        
        if ($target.DataContext.Command.Runspace.RunspaceAvailability -ne 'Available') {
            Write-Error "Runspace was busy.  Will not run $command"
            return
        }        
        
        if ($parameter) {
            $target.DataContext.Command.Runspace.SessionStateProxy.PSVariable.Set('CommandParameters', $parameter)
            if ($debugPreference -ne 'SilentlyContinue') {
                $parameter
            }
            if ($psCmdlet.ParameterSetName -eq 'scriptBlock') {
                $target.DataContext.Script = ". { $ScriptBlock} @commandParameters"
            } else {
                $realCommand = $target.DataContext.Command.Runspace.SessionStateProxy.InvokeCommand.GetCommand($command, "All") 
                $target.DataContext.Script = "$($realCommand.Name) @commandParameters"
            }
            $target.DataContext.Resources.Parameter = $parameter
        } else {
            if ($psCmdlet.ParameterSetName -eq 'scriptBlock') {
                $target.DataContext.Script = "$ScriptBlock"
            } else {
                $target.DataContext.Script = "$Command"
            }
            
        }                
    }
} 
