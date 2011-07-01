function Get-PowerShellDataSource {
    <#
    .Synopsis
        Gets a new PowerShell data source
    .Description
        Gets a new PowerShell data source.
        PowerShell data sources are used within a WPF application or WPK script
        to provide data from PowerShell to the UI asynchronously.
        This allows you to see the output of a long-running script within a UI 
        while it is still running.
        You can bind this data source to a listbox or listview in order to see its 
        contents
    .Example
    New-ListBox -MaxHeight 350 -DataContext {
        Get-PowerShellDataSource -Script {
            Get-Process | ForEach-Object { $_ ; Start-Sleep -Milliseconds 100 }
        }
    } -DataBinding @{
        ItemsSource = New-Binding -IsAsync -UpdateSourceTrigger PropertyChanged -Path Output
    } -On_Loaded {
        Register-PowerShellCommand -Run -In "0:0:2.5" -ScriptBlock {
            $window.Content.DataContext.Script = $window.Content.DataContext.Script
        }
    } -asjob  
    #>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [ScriptBlock]$Script,
        
    ${Parent} = $this,

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
        try {
            $Object = New-Object ShowUI.PowerShellDataSource
        } catch {
            throw $_
            return
        }
        if ($parent) {
            $Object.Parent = $parent
            $null = $psBoundParameters.Remove('Parent')
        }
        $psBoundParameters.Script = $psBoundParameters.Script -as [string] 
        Set-Property -property $psBoundParameters -inputObject $Object
        $Object
    }
   
}
