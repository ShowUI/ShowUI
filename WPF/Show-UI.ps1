function Show-UI {
    <#
    .Synopsis
        Show-UI shows a WPF control within a window, allowing full control of the window, but with several setting presets
    .Description
        Show-UI displays a control within a window and adds several resources to the window
        to make several scenarios (like timed events or reusable scripts) easier to accomplish
        within the WPF control.
    .Parameter Content
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
        New-Label "Hello World" | Show-UI
    #>
    [CmdletBinding(DefaultParameterSetName="ScriptBlock")]
    param(
    # The Content of the window (usually a UI element, but could also be any object)
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, ParameterSetName="Content", Position=0)]
    [Alias("Control")]
    [System.Windows.Media.Visual]
    ${Content},

    [Parameter(ParameterSetName='Window',Mandatory=$true,ValueFromPipeline=$true,Position=0)]
    [Windows.Window]
    $Window,
                      
    [Hashtable]
    $WindowProperty = @{},

    [Parameter(Mandatory=$true,ParameterSetName="ScriptBlock",ValueFromPipeline=$true,Position=0)]
    [ScriptBlock]
    $ScriptBlock,

    [Parameter(ParameterSetName="ScriptBlock")]      
    [Hashtable][Alias("Args","Arguments")]
    $ScriptParameter = @{},
       
    [Parameter(Mandatory=$true,ParameterSetName="Xaml",ValueFromPipeline=$true,Position=0)]
    $Xaml,

    [Switch]
    $OutputWindowFirst,

    ${TaskbarItemInfo},

    [Switch]
    ${AllowsTransparency},

    [System.String]
    ${Title} = "Show UI",

    ${Icon},

    [System.Windows.SizeToContent]
    ${SizeToContent},

    [System.Double]
    ${Top},

    [System.Double]
    ${Left},

    [System.Windows.WindowStartupLocation]
    ${WindowStartupLocation},

    [Switch]
    ${ShowInTaskbar},

    ${Owner},

    ${DialogResult},

    [System.Windows.WindowStyle]
    ${WindowStyle},

    [System.Windows.WindowState]
    ${WindowState},

    [System.Windows.ResizeMode]
    ${ResizeMode},

    [Switch]
    ${Topmost},

    [Switch]
    ${ShowActivated},

    ${ContentTemplate},

    ${ContentTemplateSelector},

    [System.String]
    ${ContentStringFormat},

    ${BorderBrush},

    ${BorderThickness},

    ${Background},

    ${Foreground},

    ${FontFamily},

    [System.Double]
    ${FontSize},

    ${FontStretch},

    ${FontStyle},

    ${FontWeight},

    [System.Windows.HorizontalAlignment]
    ${HorizontalContentAlignment},

    [System.Windows.VerticalAlignment]
    ${VerticalContentAlignment},

    [System.Int32]
    ${TabIndex},

    [Switch]
    ${IsTabStop},

    ${Padding},

    ${Template},

    ${Style},

    [Switch]
    ${OverridesDefaultStyle},

    [Switch]
    ${UseLayoutRounding},

    ${Triggers},

    ${DataContext},

    ${BindingGroup},

    ${Language},

    [System.String]
    ${Name},

    ${Tag},

    ${InputScope},

    ${LayoutTransform},

    [System.Double]
    ${Width},

    [System.Double]
    ${MinWidth},

    [System.Double]
    ${MaxWidth},

    [System.Double]
    ${Height},

    [System.Double]
    ${MinHeight},

    [System.Double]
    ${MaxHeight},

    [System.Windows.FlowDirection]
    ${FlowDirection},

    ${Margin},

    [System.Windows.HorizontalAlignment]
    ${HorizontalAlignment},

    [System.Windows.VerticalAlignment]
    ${VerticalAlignment},

    ${FocusVisualStyle},

    ${Cursor},

    [Switch]
    ${ForceCursor},

    ${ToolTip},

    ${ContextMenu},

    ${InputBindings},

    ${CommandBindings},

    [Switch]
    ${AllowDrop},

    ${RenderSize},

    ${RenderTransform},

    ${RenderTransformOrigin},

    [System.Double]
    ${Opacity},

    ${OpacityMask},

    ${BitmapEffect},

    ${Effect},

    ${BitmapEffectInput},

    ${CacheMode},

    [System.String]
    ${Uid},

    [System.Windows.Visibility]
    ${Visibility},

    [Switch]
    ${ClipToBounds},

    ${Clip},

    [Switch]
    ${SnapsToDevicePixels},

    [Switch]
    ${IsEnabled},

    [Switch]
    ${IsHitTestVisible},

    [Switch]
    ${Focusable},

    [Switch]
    ${IsManipulationEnabled},

    [System.Management.Automation.ScriptBlock[]]
    ${On_SourceInitialized},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Activated},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Deactivated},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StateChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LocationChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Closing},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Closed},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ContentRendered},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseDoubleClick},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseDoubleClick},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TargetUpdated},

    [System.Management.Automation.ScriptBlock[]]
    ${On_SourceUpdated},

    [System.Management.Automation.ScriptBlock[]]
    ${On_DataContextChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_RequestBringIntoView},

    [System.Management.Automation.ScriptBlock[]]
    ${On_SizeChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Initialized},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Loaded},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Unloaded},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ToolTipOpening},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ToolTipClosing},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ContextMenuOpening},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ContextMenuClosing},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseLeftButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseLeftButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseLeftButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseLeftButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseRightButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseRightButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseRightButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseRightButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewMouseWheel},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseWheel},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseEnter},

    [System.Management.Automation.ScriptBlock[]]
    ${On_MouseLeave},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GotMouseCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LostMouseCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_QueryCursor},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusInAirMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusInAirMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusEnter},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusLeave},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusInRange},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusInRange},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusOutOfRange},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusOutOfRange},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusSystemGesture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusSystemGesture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GotStylusCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LostStylusCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_StylusButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusButtonDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewStylusButtonUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewKeyDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_KeyDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewKeyUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_KeyUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewGotKeyboardFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GotKeyboardFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewLostKeyboardFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LostKeyboardFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewTextInput},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TextInput},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewQueryContinueDrag},

    [System.Management.Automation.ScriptBlock[]]
    ${On_QueryContinueDrag},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewGiveFeedback},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GiveFeedback},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewDragEnter},

    [System.Management.Automation.ScriptBlock[]]
    ${On_DragEnter},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewDragOver},

    [System.Management.Automation.ScriptBlock[]]
    ${On_DragOver},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewDragLeave},

    [System.Management.Automation.ScriptBlock[]]
    ${On_DragLeave},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewDrop},

    [System.Management.Automation.ScriptBlock[]]
    ${On_Drop},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewTouchDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TouchDown},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewTouchMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TouchMove},

    [System.Management.Automation.ScriptBlock[]]
    ${On_PreviewTouchUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TouchUp},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GotTouchCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LostTouchCapture},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TouchEnter},

    [System.Management.Automation.ScriptBlock[]]
    ${On_TouchLeave},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsMouseDirectlyOverChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsKeyboardFocusWithinChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsMouseCapturedChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsMouseCaptureWithinChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsStylusDirectlyOverChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsStylusCapturedChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsStylusCaptureWithinChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsKeyboardFocusedChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LayoutUpdated},

    [System.Management.Automation.ScriptBlock[]]
    ${On_GotFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_LostFocus},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsEnabledChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsHitTestVisibleChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_IsVisibleChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_FocusableChanged},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationStarting},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationStarted},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationDelta},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationInertiaStarting},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationBoundaryFeedback},

    [System.Management.Automation.ScriptBlock[]]
    ${On_ManipulationCompleted},

    [Switch]
    ${OutputXaml},

    [System.Collections.Hashtable]
    ${Resource},

    [System.Collections.Hashtable]
    ${DataBinding},

    [System.Collections.Hashtable]
    ${RoutedEvent},

    [System.Collections.Hashtable]
    ${DependencyProperty},

    [System.String]
    ${ControlName},

    [System.String]
    ${VisualStyle},

    [Switch]
    ${Show},

    [Switch]
    ${ShowUI},

    [System.Int32]
    ${Row},

    [System.Int32]
    ${Column},

    [System.Int32]
    ${RowSpan},

    [System.Int32]
    ${ColumnSpan},

    [System.Int32]
    ${ZIndex},

    [System.Windows.Controls.Dock]
    ${Dock},

    [Parameter(ParameterSetName="ScriptBlock")]
    [Parameter(ParameterSetName="Xaml")]
    [Alias('Async')]
    [Switch]$AsJob   
    )
    begin {
        function Update-WindowTitle {
            param($Window)
            $instanceName = $control.Name
            $specificWindowTitle = $window.Content.GetValue([Windows.Window]::TitleProperty)
            if ($specificWindowTitle) {
                $Window.Title = $specificWindowTitle
            } elseif ($instanceName) {
                $Window.Title = $instanceName
            } else {
                $controlName = $window.Content.GetValue([ShowUI.ShowUISetting]::ControlNameProperty)
                if ($controlName) {
                    $Window.Title = $controlName
                }
            }
        }
        function Update-WindowSize {
            param($Content, [Hashtable]$WindowProperty)
            $Margins = $Content.GetValue([Windows.FrameworkElement]::MarginProperty)
            $Paddings = $Content.GetValue([Windows.Controls.Control]::PaddingProperty)
            if(!$WindowProperty.ContainsKey("MinWidth")) {
                if($MinWidth = $Content.GetValue([Windows.FrameworkElement]::MinWidthProperty)) {
                    $WindowProperty.MinWidth = $MinWidth
                    if($Margins) {
                        $WindowProperty.MinWidth = $MinWidth + $Margins.Left + $Margins.Right
                    }
                    if($Paddings) {
                        $WindowProperty.MinWidth = $MinWidth + $Paddings.Left + $Paddings.Right
                    }
                }
            }
            if(!$WindowProperty.ContainsKey("MinHeight")) {
                if($MinHeight = $Content.GetValue([Windows.FrameworkElement]::MinHeightProperty)) {
                    $WindowProperty.MinHeight = $MinHeight
                    if($Margins) {
                        $WindowProperty.MinHeight = $MinWidth + $Margins.Top + $Margins.Bottom
                    }
                    if($Paddings) {
                        $WindowProperty.MinHeight = $MinWidth + $Paddings.Top + $Paddings.Top
                    }                    
                }
            }            
        }
    }
    process {        
        try {
            foreach($key in "Content", "Xaml", "Window", "WindowProperty", "ScriptBlock", "ScriptParameter", "OutputWindowFirst", "AsJob") {
                if($PSBoundParameters.ContainsKey($key)){
                    $null = $PSBoundParameters.Remove($key)
                }
            }
            $WindowProperty += $PSBoundParameters
            if(!$PSBoundParameters.ContainsKey("SizeToContent") -and !$WindowProperty.ContainsKey("WidthAndHeight")) {
                $WindowProperty += @{
                    SizeToContent="WidthAndHeight"   
                }
            }
            Write-Verbose "Set Window Properties`n$($WindowProperty | Out-String)"
        } catch {
            Write-Debug ($_ | Out-String)
        }
        switch ($psCmdlet.ParameterSetName) {
            Content {
                $window = New-Window
                Update-WindowSize $Content $WindowProperty
                Set-WpfProperty -inputObject $window -property $WindowProperty
                $window.Content = $Content
                Update-WindowTitle $Window
            }
            Xaml {
                if($Xaml -is [Xml.XmlDocument]) {
                    $Xaml = $Xaml.OuterXml
                } elseif("Xml.Linq.XDocument" -as [Type] -and ($Xaml -is [Xml.Linq.XDocument])) {
                    $Xaml = $Xaml.ToString()
                } elseif(Test-Path $Xaml) {
                    $Xaml = @(Get-Content $Xaml) -join "`n"
                } else {
                    $Xaml = [string]$Xaml
                }
                if ($AsJob) {
                    Start-WPFJob -Parameter @{
                        Xaml = $xaml
                        WindowProperty = $windowProperty
                    } -ScriptBlock {
                        param($Xaml, $windowProperty)
                        # Set-WpfProperty -inputObject $window -property $WindowProperty
                        $Content = [windows.Markup.XamlReader]::Parse($Xaml)
                        if($Content -is [System.Windows.Window]) {
                            Show-UI -Window $Content @WindowProperty
                        } else {
                            Show-UI -Content $Content @WindowProperty
                        }
                    }   
                    return                  
                } else {
                    $Content = [windows.Markup.XamlReader]::Parse($Xaml)
                    if($Content -is [System.Windows.Window]) {
                        $window = $Content
                        Set-WpfProperty -inputObject $window -property $WindowProperty
                    } else {
                        $window = New-Window
                        Update-WindowSize $Content $WindowProperty
                        Set-WpfProperty -inputObject $window -property $WindowProperty
                        $window.Content = $Content
                        Update-WindowTitle $Window                      
                    }
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
                        Update-WindowSize $Window.Content $WindowProperty                        
                        Set-WpfProperty -inputObject $Window -property $WindowProperty
                        Show-UI -Window $Window
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
                    Update-WindowSize $Window.Content $WindowProperty                    
                    Set-WpfProperty -inputObject $window -property $WindowProperty
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

        # if(!${global:ShowUI Application Context}) {
        #     ${global:ShowUI Application Context} = [Windows.Application]::new()
        # }
        # $null = ${global:ShowUI Application Context}.Run($window)

        Get-UIValue -UI $Window
    }
}


Set-Alias Show-BootsWindow Show-UI
# Set-Alias Show-Window Show-UI 