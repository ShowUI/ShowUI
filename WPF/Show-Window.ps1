function Show-Window {
    <#
    .Synopsis
        Show-Window shows a WPF control within a window, 
        and is used by the -Show Parameter of all commands within WPK
    .Description
        Show-Window displays a control within a window and adds several resources to the window
        to make several scenarios (like timed events or reusable scripts) easier to accomplish
        within the WPF control.
    .Parameter Control
        The UI Element to display within the window
    .Parameter Xaml
        The xaml to display within the window
    .Parameter WindowProperty
        Any additional properties the window should have.
        Use the values of this dictionary as you would parameters to New-Window
    .Parameter OutputWindowFirst
        Outputs the window object just before it is displayed.
        This is useful when you need to interact with the window from outside 
        of the thread displaying it.
    .Example
        New-Label "Hello World" | Show-Window
    #>
    [CmdletBinding(DefaultParameterSetName="Window")]
    param(   
    [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        ParameterSetName="Control",        
    Position=0)]      
    [Windows.Media.Visual]
    $Control,     

    [Parameter(Mandatory=$true,ParameterSetName="Xaml",ValueFromPipeline=$true,Position=0)]      
    [xml]
    $Xaml,
       
    [Parameter(ParameterSetName='Window',Mandatory=$true,ValueFromPipeline=$true,Position=0)]
    [Windows.Window]
    $Window,
                      
    [Hashtable]
    $WindowProperty = @{},
    
    [Parameter(Mandatory=$true,ParameterSetName="ScriptBlock",ValueFromPipeline=$true,Position=0)]      
    [ScriptBlock]
    $ScriptBlock,
    
    [Parameter(ParameterSetName="ScriptBlock")]      
    [Hashtable]
    $ScriptParameter = @{},
       
    [Switch]
    $OutputWindowFirst,
    
    [Parameter(ParameterSetName="ScriptBlock")]      
    [Parameter(ParameterSetName="Xaml")]  
    [Alias('Async')]    
    [switch]$AsJob      
    )
   
   process {        
        try {
            $windowProperty += @{
                SizeToContent="WidthAndHeight"   
            }
        } catch {
            Write-Debug ($_ | Out-String)
        }        
        switch ($psCmdlet.ParameterSetName) {
            Control {
                $window = New-Window
                Set-Property -inputObject $window -property $WindowProperty
                $window.Content = $Control
                $instanceName = $control.Name
                $specificWindowTitle = $Control.GetValue([Windows.Window]::TitleProperty)
                if ($specificWindowTitle) {
                    $Window.Title = $specificWindowTitle
                } elseif ($instanceName) {
                    $Window.Title = $instanceName
                } else {
                    $controlName = $Control.GetValue([ShowUI.ShowUISetting]::ControlNameProperty)
                    if ($controlName) {
                        $Window.Title = $controlName
                    }
                }
            }
            Xaml {
                if ($AsJob) {
                    Start-WPFJob -Parameter @{
                        Xaml = $xaml
                        WindowProperty = $windowProperty
                    } -ScriptBlock {
                        param($Xaml, $windowProperty)
                        $window = New-Window
                        Set-Property -inputObject $window -property $WindowProperty
                        $strWrite = New-Object IO.StringWriter
                        $xaml.Save($strWrite)
                        $Control = [windows.Markup.XamlReader]::Parse("$strWrite")
                        $window.Content = $Control
                        Show-Window -Window $window
                    }   
                    return                  
                } else {
                    $window = New-Window
                    Set-Property -inputObject $window -property $WindowProperty
                    $strWrite = New-Object IO.StringWriter
                    $xaml.Save($strWrite)
                    $Control = [windows.Markup.XamlReader]::Parse("$strWrite")
                    $window.Content = $Control
                }                
            }
            ScriptBlock {
                if ($AsJob) {
                    Start-WPFJob -ScriptBlock {
                        param($ScriptBlock, $scriptParameter = @{}, $windowProperty) 
                        
                        $window = New-Window    
                        $exception = $null
                        $results = . $ScriptBlock @scriptParameter 2>&1
                        $errors = $results | Where-Object { $_ -is [Management.Automation.ErrorRecord] } 
                        
                        if ($errors) {
                            $window.Content = $errors | Out-String 
                            try {
                                $windowProperty += @{
                                    FontFamily="Consolas"   
                                    Foreground='Red'
                                }
                            } catch {
                                Write-Debug ($_ | Out-String)
                            }                                                    
                        } else {
                            if ($results -is [Windows.Media.Visual]) {
                                $window.Content = $results
                            } else {
                                $window.Content = $results | Out-String 
                                try {
                                    $windowProperty += @{
                                        FontFamily="Consolas"   
                                    }
                                } catch {
                                    Write-Debug ($_ | Out-String)
                                }                        
                            }
                        }                                                
                        Set-Property -inputObject $window -property $WindowProperty
                        Show-Window -Window $window
                    } -Parameter @{
                        ScriptBlock = $ScriptBlock
                        ScriptBlockParameter = $ScriptBlockParameter
                        WindowProperty = $windowProperty
                    } 
                    return 
                } else {
                
                    $window = New-Window
                    $results = & $ScriptBlock @scriptParameter
                    if ($results -is [Windows.Media.Visual]) {
                        $window.Content = $results
                    } else {
                        $window.Content = $results | Out-String
                     
                    }
                    try {
                        $windowProperty += @{
                            FontFamily="Consolas"   
                        }
                    } catch {
                        Write-Debug ($_ | Out-String)
                    }
                    Set-Property -inputObject $window -property $WindowProperty
                }
                
            }
        }
        $Window.Resources.Timers = 
            New-Object Collections.Generic.Dictionary["string,Windows.Threading.DispatcherTimer"]
        $Window.Resources.TemporaryControls = @{}
        $Window.Resources.Scripts =
            New-Object Collections.Generic.Dictionary["string,ScriptBlock"]
        $Window.add_Closing({
            foreach ($timer in $this.Resources.Timers.Values) {
                if (-not $timer) { continue }
                $null = $timer.Stop()
            }
            $this | 
                Get-ChildControl -PeekIntoNestedControl |
                Where-Object { 
                    $_.Resources.EventHandlers
                } |
                ForEach-Object {
                    $object = $_
                    $handlerNames  = @($_.Resources.EventHandlers.Keys)
                    foreach ($handler in $handlerNames){
                        $object."remove_$($handler.Substring(3))".Invoke($object.Resources.EventHandlers[$handler])
                        $null = $object.Resources.EventHandlers.Remove($handler)
                    }
                    $object.Resources.Remove("EventHandlers")
                }
        })
        if ($outputWindowFirst) {
            $Window
        }
        $null = $Window.ShowDialog()            
        if ($Control.Tag -ne $null) {
            $Control.Tag            
        } elseif ($Window.Tag -ne $null) {
            $Window.Tag
        } else {
            if ($Control.SelectedItems) {
                $Control.SelectedItems
            }
            if ($Control.Text) {
                $Control.Text
            }
            if ($Control.IsChecked) {
                $Control.IsChecked
            }
        }
        return
   }
}


# Set-Alias Show-BootsWindow Show-Window 
# Set-Alias Show-UI Show-Window 
