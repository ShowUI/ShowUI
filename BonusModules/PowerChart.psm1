####  Before this will work, YOU MUST HAVE:
####   INSTALLED the JUNE WPF Toolkit http://wpf.codeplex.com 
####   INSTALLED, and IMPORTED in your current session, the PowerBoots Module

if(Get-Command New-System.Windows.VisualState) {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   ForEach { [Reflection.Assembly]::LoadFrom( $_.FullName ) } | Out-Null
   
   $Error.Clear()
   
   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
} else {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   Add-BootsFunction

   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
}

Add-BootsTemplate C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\XamlTemplates\PowerCharting.xaml

# . C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\New-PowerChart.ps1
# New-PowerChart Area { ls | ? {!$_.PSIsContainer} } Name Length -Background White
# New-PowerChart Pie { ls | ?{!$_.PSIsContainer} } Name Length

function Ping-Host {
   New-Object PSObject | 
   Add-Member NoteProperty   Time $(Get-Date) -Passthru |
   Add-Member NoteProperty   Ping $([int]([regex]"time=(\d+)ms").Match( (ping.exe $args[0] -n 1) ).Groups[1].Value) -Passthru | 
   Add-Member ScriptProperty Age  { ($(Get-Date) - $this.Time).TotalMinutes } -Passthru
}

#  $global:pings = new-object system.collections.queue 21
#  $global:pings.Enqueue($(Ping-Host "huddledmasses.org"))
#  New-PowerChart Line { 
#     $global:pings.Enqueue( (Ping-Host huddledmasses.org) )
#     if($pings.Count -gt 20) { $pings.Dequeue()|Out-Null } 
#     Write-Output $pings
#  } Age Ping -Interval "00:00:02"                                      

#  Boots { 
#     $global:timer = DispatcherTimer -Interval "00:00:10" -On_Tick { $series.ItemsSource = ls | ? { !$_.PsIsContainer } }
#     Chart { PieSeries -DependentValuePath Length -IndependentValuePath Name | Tee -var global:series }
#     $timer.Start()
#  } -On_Closed { $timer.Stop() }


function New-PowerChart() {
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
# #region Params
param(
   [Parameter(Position=0, Mandatory=$true)]
   [ValidateSet("Area","Bar","Bubble","Column","Line","Pie","Scatter")]
   [String[]]
   ${ChartType},
    
    [Parameter(Position=1, Mandatory=$true, HelpMessage='The data for the chart ...')]
    [System.Management.Automation.ScriptBlock[]]
    ${ItemsSource},

    [Parameter(Position=2, Mandatory=$true, HelpMessage='The property name for the independent values ...')]
    [String[]]
    ${IndependentValuePath},
    
    [Parameter(Position=3, Mandatory=$true, HelpMessage='The property name for the dependent values ...')]
    [String[]]
    ${DependentValuePath},

    [Parameter(Position=4, HelpMessage='The property name for the size values ...')]
    [String[]]
    ${SizeValuePath},
    
    [TimeSpan]    
    ${Interval},
    
    [Alias('Threaded')]
    [Switch]
    ${Async},

    [Parameter(ParameterSetName='FileTemplate', Mandatory=$true, Position=10, HelpMessage='XAML template file')]
    [System.IO.FileInfo]
    ${FileTemplate},

    [Parameter(ParameterSetName='SourceTemplate', Mandatory=$true, Position=10, HelpMessage='XAML template XmlDocument')]
    [System.Xml.XmlDocument]
    ${SourceTemplate},

    [Parameter(HelpMessage='Do not show in a popup Window (currently only works on PoshConsole)')]
    [Switch]
    ${Inline},

    [Parameter(HelpMessage='Write out the window')]
    [Switch]
    ${Passthru},

    [Switch]
    ${AllowDrop},

    [Switch]
    ${NoTransparency},

    [Switch]
    ${ClipToBounds},

    [Switch]
    ${Focusable},

    [Switch]
    ${ForceCursor},

    [Switch]
    ${IsEnabled},

    [Switch]
    ${IsHitTestVisible},

    [Switch]
    ${IsTabStop},

    [Switch]
    ${OverridesDefaultStyle},

    [Switch]
    ${ShowActivated},

    [Switch]
    ${ShowInTaskbar},

    [Switch]
    ${SnapsToDevicePixels},

    [Switch]
    ${Topmost},

    [Switch]
    ${DialogResult},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${FontSize},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Height},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Left},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${MaxHeight},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${MaxWidth},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${MinHeight},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${MinWidth},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Opacity},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Top},

    [System.Nullable``1[[System.Double, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Width},

    [System.Nullable``1[[System.Int32, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${TabIndex},

    [System.Object]
    ${DataContext},

    [System.Object]
    ${Tag},

    [System.Object]
    ${ToolTip},

    [System.String]
    ${ContentStringFormat},

    [System.String]
    ${Name},

    [System.String]
    ${Title},

    [System.String]
    ${Uid},

    [System.Windows.Controls.ContextMenu]
    ${ContextMenu},

    [System.Windows.Controls.ControlTemplate]
    ${Template},

    [System.Windows.Controls.DataTemplateSelector]
    ${ContentTemplateSelector},

    [System.Windows.Data.BindingGroup]
    ${BindingGroup},

    [System.Windows.DataTemplate]
    ${ContentTemplate},

    [System.Nullable``1[[System.Windows.FlowDirection, PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${FlowDirection},

    [System.Windows.FontStretch]
    ${FontStretch},

    [System.Windows.FontStyle]
    ${FontStyle},

    [System.Windows.FontWeight]
    ${FontWeight},

    [System.Nullable``1[[System.Windows.HorizontalAlignment, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${HorizontalAlignment},

    [System.Nullable``1[[System.Windows.HorizontalAlignment, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${HorizontalContentAlignment},

    [System.Windows.Input.CommandBinding[]]
    ${CommandBindings},

    [System.Windows.Input.Cursor]
    ${Cursor},

    [System.Windows.Input.InputBinding[]]
    ${InputBindings},

    [System.Windows.Input.InputScope]
    ${InputScope},

    [System.Windows.Markup.XmlLanguage]
    ${Language},

    [System.Windows.Media.Brush]
    ${Background},

    [System.Windows.Media.Brush]
    ${BorderBrush},

    [System.Windows.Media.Brush]
    ${Foreground},

    [System.Windows.Media.Brush]
    ${OpacityMask},

    [System.Windows.Media.Effects.BitmapEffect]
    ${BitmapEffect},

    [System.Windows.Media.Effects.BitmapEffectInput]
    ${BitmapEffectInput},

    [System.Windows.Media.Effects.Effect]
    ${Effect},

    [System.Windows.Media.FontFamily]
    ${FontFamily},

    [System.Windows.Media.Geometry]
    ${Clip},

    [System.Windows.Media.ImageSource]
    ${Icon},

    [System.Windows.Media.Transform]
    ${LayoutTransform},

    [System.Windows.Media.Transform]
    ${RenderTransform},

    [System.Windows.Point]
    ${RenderTransformOrigin},

    [System.Nullable``1[[System.Windows.ResizeMode, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${ResizeMode},

    [System.Windows.ResourceDictionary]
    ${Resources},

    [System.Windows.Size]
    ${RenderSize},

    [System.Nullable``1[[System.Windows.SizeToContent, PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${SizeToContent},

    [System.Windows.Style]
    ${FocusVisualStyle},

    [System.Windows.Style]
    ${Style},

    [System.Windows.Thickness]
    ${BorderThickness},

    [System.Windows.Thickness]
    ${Margin},

    [System.Windows.Thickness]
    ${Padding},

    [System.Windows.TriggerCollection]
    ${Triggers},

    [System.Nullable``1[[System.Windows.VerticalAlignment, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${VerticalAlignment},

    [System.Nullable``1[[System.Windows.VerticalAlignment, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${VerticalContentAlignment},

    [System.Nullable``1[[System.Windows.Visibility, PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${Visibility},

    [System.Windows.Window]
    ${Owner},

    [System.Nullable``1[[System.Windows.WindowStartupLocation, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${WindowStartupLocation},

    [System.Nullable``1[[System.Windows.WindowState, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${WindowState},

    [System.Nullable``1[[System.Windows.WindowStyle, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${WindowStyle},

    [System.ComponentModel.CancelEventHandler]
    ${On_Closing},

    [System.EventHandler]
    ${On_Activated},

    [System.EventHandler]
    ${On_Closed},

    [System.EventHandler]
    ${On_ContentRendered},

    [System.EventHandler]
    ${On_Deactivated},

    [System.EventHandler]
    ${On_Initialized},

    [System.EventHandler]
    ${On_LayoutUpdated},

    [System.EventHandler]
    ${On_LocationChanged},

    [System.EventHandler]
    ${On_SourceInitialized},

    [System.EventHandler]
    ${On_StateChanged},

    [System.EventHandler``1[[System.Windows.Data.DataTransferEventArgs, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${On_SourceUpdated},

    [System.EventHandler``1[[System.Windows.Data.DataTransferEventArgs, PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35]], mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]
    ${On_TargetUpdated},

    [System.Windows.Controls.ContextMenuEventHandler]
    ${On_ContextMenuClosing},

    [System.Windows.Controls.ContextMenuEventHandler]
    ${On_ContextMenuOpening},

    [System.Windows.Controls.ToolTipEventHandler]
    ${On_ToolTipClosing},

    [System.Windows.Controls.ToolTipEventHandler]
    ${On_ToolTipOpening},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_DataContextChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_FocusableChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsEnabledChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsHitTestVisibleChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsKeyboardFocusedChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsKeyboardFocusWithinChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsMouseCapturedChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsMouseCaptureWithinChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsMouseDirectlyOverChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsStylusCapturedChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsStylusCaptureWithinChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsStylusDirectlyOverChanged},

    [System.Windows.DependencyPropertyChangedEventHandler]
    ${On_IsVisibleChanged},

    [System.Windows.DragEventHandler]
    ${On_DragEnter},

    [System.Windows.DragEventHandler]
    ${On_DragLeave},

    [System.Windows.DragEventHandler]
    ${On_DragOver},

    [System.Windows.DragEventHandler]
    ${On_Drop},

    [System.Windows.DragEventHandler]
    ${On_PreviewDragEnter},

    [System.Windows.DragEventHandler]
    ${On_PreviewDragLeave},

    [System.Windows.DragEventHandler]
    ${On_PreviewDragOver},

    [System.Windows.DragEventHandler]
    ${On_PreviewDrop},

    [System.Windows.GiveFeedbackEventHandler]
    ${On_GiveFeedback},

    [System.Windows.GiveFeedbackEventHandler]
    ${On_PreviewGiveFeedback},

    [System.Windows.Input.KeyboardFocusChangedEventHandler]
    ${On_GotKeyboardFocus},

    [System.Windows.Input.KeyboardFocusChangedEventHandler]
    ${On_LostKeyboardFocus},

    [System.Windows.Input.KeyboardFocusChangedEventHandler]
    ${On_PreviewGotKeyboardFocus},

    [System.Windows.Input.KeyboardFocusChangedEventHandler]
    ${On_PreviewLostKeyboardFocus},

    [System.Windows.Input.KeyEventHandler]
    ${On_KeyDown},

    [System.Windows.Input.KeyEventHandler]
    ${On_KeyUp},

    [System.Windows.Input.KeyEventHandler]
    ${On_PreviewKeyDown},

    [System.Windows.Input.KeyEventHandler]
    ${On_PreviewKeyUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseDoubleClick},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseLeftButtonDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseLeftButtonUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseRightButtonDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseRightButtonUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_MouseUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseDoubleClick},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseLeftButtonDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseLeftButtonUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseRightButtonDown},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseRightButtonUp},

    [System.Windows.Input.MouseButtonEventHandler]
    ${On_PreviewMouseUp},

    [System.Windows.Input.MouseEventHandler]
    ${On_GotMouseCapture},

    [System.Windows.Input.MouseEventHandler]
    ${On_LostMouseCapture},

    [System.Windows.Input.MouseEventHandler]
    ${On_MouseEnter},

    [System.Windows.Input.MouseEventHandler]
    ${On_MouseLeave},

    [System.Windows.Input.MouseEventHandler]
    ${On_MouseMove},

    [System.Windows.Input.MouseEventHandler]
    ${On_PreviewMouseMove},

    [System.Windows.Input.MouseWheelEventHandler]
    ${On_MouseWheel},

    [System.Windows.Input.MouseWheelEventHandler]
    ${On_PreviewMouseWheel},

    [System.Windows.Input.QueryCursorEventHandler]
    ${On_QueryCursor},

    [System.Windows.Input.StylusButtonEventHandler]
    ${On_PreviewStylusButtonDown},

    [System.Windows.Input.StylusButtonEventHandler]
    ${On_PreviewStylusButtonUp},

    [System.Windows.Input.StylusButtonEventHandler]
    ${On_StylusButtonDown},

    [System.Windows.Input.StylusButtonEventHandler]
    ${On_StylusButtonUp},

    [System.Windows.Input.StylusDownEventHandler]
    ${On_PreviewStylusDown},

    [System.Windows.Input.StylusDownEventHandler]
    ${On_StylusDown},

    [System.Windows.Input.StylusEventHandler]
    ${On_GotStylusCapture},

    [System.Windows.Input.StylusEventHandler]
    ${On_LostStylusCapture},

    [System.Windows.Input.StylusEventHandler]
    ${On_PreviewStylusInAirMove},

    [System.Windows.Input.StylusEventHandler]
    ${On_PreviewStylusInRange},

    [System.Windows.Input.StylusEventHandler]
    ${On_PreviewStylusMove},

    [System.Windows.Input.StylusEventHandler]
    ${On_PreviewStylusOutOfRange},

    [System.Windows.Input.StylusEventHandler]
    ${On_PreviewStylusUp},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusEnter},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusInAirMove},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusInRange},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusLeave},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusMove},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusOutOfRange},

    [System.Windows.Input.StylusEventHandler]
    ${On_StylusUp},

    [System.Windows.Input.StylusSystemGestureEventHandler]
    ${On_PreviewStylusSystemGesture},

    [System.Windows.Input.StylusSystemGestureEventHandler]
    ${On_StylusSystemGesture},

    [System.Windows.Input.TextCompositionEventHandler]
    ${On_PreviewTextInput},

    [System.Windows.Input.TextCompositionEventHandler]
    ${On_TextInput},

    [System.Windows.QueryContinueDragEventHandler]
    ${On_PreviewQueryContinueDrag},

    [System.Windows.QueryContinueDragEventHandler]
    ${On_QueryContinueDrag},

    [System.Windows.RequestBringIntoViewEventHandler]
    ${On_RequestBringIntoView},

    [System.Windows.RoutedEventHandler]
    ${On_GotFocus},

    [System.Windows.RoutedEventHandler]
    ${On_Loaded},

    [System.Windows.RoutedEventHandler]
    ${On_LostFocus},

    [System.Windows.RoutedEventHandler]
    ${On_Unloaded},

    [System.Windows.SizeChangedEventHandler]
    ${On_SizeChanged}   
)
# #endregion

begin
{
   # And we need to set these ...
   function Set-Param { 
      Param(
         [Parameter(Mandatory=$true, Position=0)]
         [String]$Name,
         $Default,$Min,$Max,
         [Parameter(Mandatory=$true, Position=99)]
         $PSBoundParameters=$PSBoundParameters
      )
      $outBuffer = $null
      if($Max) {
         if ($PSBoundParameters.TryGetValue($Name, [ref]$outBuffer) -and $outBuffer -gt $Max)
         {
            $PSBoundParameters[$Name] = $Max
         }
      }

      if($Min) {
         if ($PSBoundParameters.TryGetValue($Name, [ref]$outBuffer) -and $outBuffer -lt $Min)
         {
            $PSBoundParameters[$Name] = $Min
         }
      }
      if($Default) {
         if (!$PSBoundParameters.TryGetValue($Name, [ref]$outBuffer))
         {
            $PSBoundParameters[$Name] = $Default
         }
      }
      $PSBoundParameters
   }

      # We need to get rid of these before we pass this on
      $null = $PSBoundParameters.Remove("ChartType")
      $null = $PSBoundParameters.Remove("ItemsSource")
      $null = $PSBoundParameters.Remove("DependentValuePath")
      $null = $PSBoundParameters.Remove("IndependentValuePath")
      $null = $PSBoundParameters.Remove("SizeValuePath")
      $null = $PSBoundParameters.Remove("Interval")

      # We want to change the defaults for some of the values to "cooler" settings ...
      $PSBoundParameters = Set-Param Async -Default $(New-Object System.Management.Automation.SwitchParameter $true) -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param Height -Default 400 -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param Width -Default 600 -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param MinWidth -Default 150 -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param MinHeight -Default 150 -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param MinHeight -Default 150 -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param ResizeMode -Default "CanResizeWithGrip" -PSBoundParameters $PSBoundParameters
      $PSBoundParameters = Set-Param On_MouseLeftButtonDown -Default { $this.DragMove() } -PSBoundParameters $PSBoundParameters
      
      
      if(!$NoTransparency) {
         $PSBoundParameters["AllowsTransparency"] = New-Object System.Management.Automation.SwitchParameter $true
         $PSBoundParameters["WindowStyle"] = "None"
         $PSBoundParameters = Set-Param Background -Default Transparent -PSBoundParameters $PSBoundParameters
      }

      $global:PowerChartValues = @{ 
         "ChartType" = $ChartType
         "ItemsSource" = $ItemsSource
         "DependentValuePath" = $DependentValuePath
         "IndependentValuePath" = $IndependentValuePath
         "Interval" = $Interval
         "Series" = @()
      }

      Write-Debug "Bound Parameters: $( $PSBoundParameters | fl | Out-string )"

      New-BootsWindow @PSBoundParameters { 
         Param($w)
         if($PowerChartValues."Interval") {
            # Write-Host "Setting Udpate Interval to $($PowerChartValues.Interval)" -Fore Cyan
         
            $PowerChartValues.Timer = DispatcherTimer -Interval $PowerChartValues.Interval -Tag $w -On_Tick {
                              # Write-Host "tick. " -nonewline -fore cyan
                              $i=0
                              $this.Tag.Tag.Series | ForEach{ $_.ItemsSource = &$($this.Tag.Tag.ItemsSource[$i++]) }
                           }
            $w.Add_Loaded( { $this.Tag.Timer.Start() } )
            $w.Add_Closed( { $this.Tag.Timer.Stop() } )
         }
         ## Store the $PowerChartValues so we can reuse the variable...
         # Write-Host "One" -Fore Green
         $w.Tag = $PowerChartValues
         # Write-Host "Two" -Fore Green
         Chart {
            # Write-Host "Three" -Fore Cyan
            for($c=0; $c -lt $PowerChartValues.ChartType.length; $c++) {
               $chartType = $PowerChartValues.ChartType[$c].ToLower()
               if($PowerChartValues.SizeValuePath -and $PowerChartValues.ChartType[$c] -eq "Bubble") {
                  # Write-Host "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -SizeValuePath $($w.Tag.SizeValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])}) -DataPointStyle `$w.FindResource('$($w.tag.ChartType[$c])DataPointTooltipsFix')"
                  $PowerChartValues.Series += iex "$($chartType)Series -DependentValuePath $($PowerChartValues.DependentValuePath[$c]) -IndependentValuePath $($PowerChartValues.IndependentValuePath[$c]) -SizeValuePath $($PowerChartValues.SizeValuePath[$c]) -ItemsSource `$(&{$($PowerChartValues.ItemsSource[$c])})" # -DataPointStyle `$w.FindResource('$($PowerChartValues.ChartType[$c])DataPointTooltipsFix')"
                  $PowerChartValues.Series[-1].DataPointStyle = $w.FindResource("$($chartType)DataPointTooltipsFix")
               } elseif($PowerChartValues.ChartType[$c] -eq "Pie") {                                                                                                                                                          
                  # Write-Host "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])}) -StylePalette =  `$w.FindResource('$($w.tag.ChartType[$c])StylePalletTooltipsFix')"
                  $PowerChartValues.Series += iex "$($chartType)Series -DependentValuePath $($PowerChartValues.DependentValuePath[$c]) -IndependentValuePath $($PowerChartValues.IndependentValuePath[$c]) -ItemsSource `$(&{$($PowerChartValues.ItemsSource[$c])})"# -StylePalette `$w.FindResource('$($chartType)StylePalletTooltipsFix')"
                  $PowerChartValues.Series[-1].StylePalette = $w.FindResource("$($chartType)StylePalletTooltipsFix")
               } else {                                                                                                                                                          
                  # Write-Host "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])}) -DataPointStyle `$w.FindResource('$($w.tag.ChartType[$c])DataPointTooltipsFix')"
                  $PowerChartValues.Series += iex "$($chartType)Series -DependentValuePath $($PowerChartValues.DependentValuePath[$c]) -IndependentValuePath $($PowerChartValues.IndependentValuePath[$c]) -ItemsSource `$(&{$($PowerChartValues.ItemsSource[$c])})" #-DataPointStyle `$w.FindResource('$($chartType)DataPointTooltipsFix')"
                  #$global:bind = $PowerChartValues.Series[-1].SetResourceReference( ($PowerChartValues.Series[-1].GetType()::DataPointStyleProperty), "$($chartType)DataPointTooltipsFix")
                  $PowerChartValues.Series[-1].DataPointStyle = $w.FindResource("$($chartType)DataPointTooltipsFix")
               }       
            }
            # Write-Host "Series: $($w.Tag.Series.Count): $($w.Tag.Series)" -Fore Green
            $PowerChartValues.Series
            # Write-Host "Four" -Fore Cyan
         } -Background Transparent -BorderThickness 0
         # Write-Host "Five" -Fore Green
      }
      # Write-Host "Six" -Fore Magenta

      #  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('New-BootsWindow', [System.Management.Automation.CommandTypes]::Cmdlet)
      #  $scriptCmd = {& $wrappedCmd @PSBoundParameters }
      #  $steppablePipeline = $scriptCmd.GetSteppablePipeline()
      #  $steppablePipeline.Begin($PSCmdlet)

}

#  process
#  {
   #  try {
      #  $steppablePipeline.Process($_)
   #  } catch {
      #  throw
   #  }
#  }

#  end
#  {
   #  try {
      #  $steppablePipeline.End()
   #  } catch {
      #  throw
   #  }
#  }
<#

.ForwardHelpTargetName New-BootsWindow
.ForwardHelpCategory Cmdlet

#>
}

# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUENa7llmlMKiRDLYU0SFmEX14
# HY2ggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
# EwJJTDEWMBQGA1UEChMNU3RhcnRDb20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERp
# Z2l0YWwgQ2VydGlmaWNhdGUgU2lnbmluZzEpMCcGA1UEAxMgU3RhcnRDb20gQ2Vy
# dGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMDcxMDI0MjIwMTQ1WhcNMTIxMDI0MjIw
# MTQ1WjCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0YXJ0Q29tIEx0ZC4xKzAp
# BgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRlIFNpZ25pbmcxODA2BgNV
# BAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJbnRlcm1lZGlhdGUgT2JqZWN0
# IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyiOLIjUemqAbPJ1J
# 0D8MlzgWKbr4fYlbRVjvhHDtfhFN6RQxq0PjTQxRgWzwFQNKJCdU5ftKoM5N4YSj
# Id6ZNavcSa6/McVnhDAQm+8H3HWoD030NVOxbjgD/Ih3HaV3/z9159nnvyxQEckR
# ZfpJB2Kfk6aHqW3JnSvRe+XVZSufDVCe/vtxGSEwKCaNrsLc9pboUoYIC3oyzWoU
# TZ65+c0H4paR8c8eK/mC914mBo6N0dQ512/bkSdaeY9YaQpGtW/h/W/FkbQRT3sC
# pttLVlIjnkuY4r9+zvqhToPjxcfDYEf+XD8VGkAqle8Aa8hQ+M1qGdQjAye8OzbV
# uUOw7wIDAQABo4ICfzCCAnswDAYDVR0TBAUwAwEB/zALBgNVHQ8EBAMCAQYwHQYD
# VR0OBBYEFNBOD0CZbLhLGW87KLjg44gHNKq3MIGoBgNVHSMEgaAwgZ2AFE4L7xqk
# QFulF2mHMMo0aEPQQa7yoYGBpH8wfTELMAkGA1UEBhMCSUwxFjAUBgNVBAoTDVN0
# YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmljYXRl
# IFNpZ25pbmcxKTAnBgNVBAMTIFN0YXJ0Q29tIENlcnRpZmljYXRpb24gQXV0aG9y
# aXR5ggEBMAkGA1UdEgQCMAAwPQYIKwYBBQUHAQEEMTAvMC0GCCsGAQUFBzAChiFo
# dHRwOi8vd3d3LnN0YXJ0c3NsLmNvbS9zZnNjYS5jcnQwYAYDVR0fBFkwVzAsoCqg
# KIYmaHR0cDovL2NlcnQuc3RhcnRjb20ub3JnL3Nmc2NhLWNybC5jcmwwJ6AloCOG
# IWh0dHA6Ly9jcmwuc3RhcnRzc2wuY29tL3Nmc2NhLmNybDCBggYDVR0gBHsweTB3
# BgsrBgEEAYG1NwEBBTBoMC8GCCsGAQUFBwIBFiNodHRwOi8vY2VydC5zdGFydGNv
# bS5vcmcvcG9saWN5LnBkZjA1BggrBgEFBQcCARYpaHR0cDovL2NlcnQuc3RhcnRj
# b20ub3JnL2ludGVybWVkaWF0ZS5wZGYwEQYJYIZIAYb4QgEBBAQDAgABMFAGCWCG
# SAGG+EIBDQRDFkFTdGFydENvbSBDbGFzcyAyIFByaW1hcnkgSW50ZXJtZWRpYXRl
# IE9iamVjdCBTaWduaW5nIENlcnRpZmljYXRlczANBgkqhkiG9w0BAQUFAAOCAgEA
# UKLQmPRwQHAAtm7slo01fXugNxp/gTJY3+aIhhs8Gog+IwIsT75Q1kLsnnfUQfbF
# pl/UrlB02FQSOZ+4Dn2S9l7ewXQhIXwtuwKiQg3NdD9tuA8Ohu3eY1cPl7eOaY4Q
# qvqSj8+Ol7f0Zp6qTGiRZxCv/aNPIbp0v3rD9GdhGtPvKLRS0CqKgsH2nweovk4h
# fXjRQjp5N5PnfBW1X2DCSTqmjweWhlleQ2KDg93W61Tw6M6yGJAGG3GnzbwadF9B
# UW88WcRsnOWHIu1473bNKBnf1OKxxAQ1/3WwJGZWJ5UxhCpA+wr+l+NbHP5x5XZ5
# 8xhhxu7WQ7rwIDj8d/lGU9A6EaeXv3NwwcbIo/aou5v9y94+leAYqr8bbBNAFTX1
# pTxQJylfsKrkB8EOIx+Zrlwa0WE32AgxaKhWAGho/Ph7d6UXUSn5bw2+usvhdkW4
# npUoxAk3RhT3+nupi1fic4NG7iQG84PZ2bbS5YxOmaIIsIAxclf25FwssWjieMwV
# 0k91nlzUFB1HQMuE6TurAakS7tnIKTJ+ZWJBDduUbcD1094X38OvMO/++H5S45Ki
# 3r/13YTm0AWGOvMFkEAF8LbuEyecKTaJMTiNRfBGMgnqGBfqiOnzxxRVNOw2hSQp
# 0B+C9Ij/q375z3iAIYCbKUd/5SSELcmlLl+BuNknXE0wggc0MIIGHKADAgECAgFR
# MA0GCSqGSIb3DQEBBQUAMIGMMQswCQYDVQQGEwJJTDEWMBQGA1UEChMNU3RhcnRD
# b20gTHRkLjErMCkGA1UECxMiU2VjdXJlIERpZ2l0YWwgQ2VydGlmaWNhdGUgU2ln
# bmluZzE4MDYGA1UEAxMvU3RhcnRDb20gQ2xhc3MgMiBQcmltYXJ5IEludGVybWVk
# aWF0ZSBPYmplY3QgQ0EwHhcNMDkxMTExMDAwMDAxWhcNMTExMTExMDYyODQzWjCB
# qDELMAkGA1UEBhMCVVMxETAPBgNVBAgTCE5ldyBZb3JrMRcwFQYDVQQHEw5XZXN0
# IEhlbnJpZXR0YTEtMCsGA1UECxMkU3RhcnRDb20gVmVyaWZpZWQgQ2VydGlmaWNh
# dGUgTWVtYmVyMRUwEwYDVQQDEwxKb2VsIEJlbm5ldHQxJzAlBgkqhkiG9w0BCQEW
# GEpheWt1bEBIdWRkbGVkTWFzc2VzLm9yZzCCASIwDQYJKoZIhvcNAQEBBQADggEP
# ADCCAQoCggEBAMfjItJjMWVaQTECvnV/swHQP0FTYUvRizKzUubGNDNaj7v2dAWC
# rAA+XE0lt9JBNFtCCcweDzphbWU/AAY0sEPuKobV5UGOLJvW/DcHAWdNB/wRrrUD
# dpcsapQ0IxxKqpRTrbu5UGt442+6hJReGTnHzQbX8FoGMjt7sLrHc3a4wTH3nMc0
# U/TznE13azfdtPOfrGzhyBFJw2H1g5Ag2cmWkwsQrOBU+kFbD4UjxIyus/Z9UQT2
# R7bI2R4L/vWM3UiNj4M8LIuN6UaIrh5SA8q/UvDumvMzjkxGHNpPZsAPaOS+RNmU
# Go6X83jijjbL39PJtMX+doCjS/lnclws5lUCAwEAAaOCA4EwggN9MAkGA1UdEwQC
# MAAwDgYDVR0PAQH/BAQDAgeAMDoGA1UdJQEB/wQwMC4GCCsGAQUFBwMDBgorBgEE
# AYI3AgEVBgorBgEEAYI3AgEWBgorBgEEAYI3CgMNMB0GA1UdDgQWBBR5tWPGCLNQ
# yCXI5fY5ViayKj6xATCBqAYDVR0jBIGgMIGdgBTQTg9AmWy4SxlvOyi44OOIBzSq
# t6GBgaR/MH0xCzAJBgNVBAYTAklMMRYwFAYDVQQKEw1TdGFydENvbSBMdGQuMSsw
# KQYDVQQLEyJTZWN1cmUgRGlnaXRhbCBDZXJ0aWZpY2F0ZSBTaWduaW5nMSkwJwYD
# VQQDEyBTdGFydENvbSBDZXJ0aWZpY2F0aW9uIEF1dGhvcml0eYIBFTCCAUIGA1Ud
# IASCATkwggE1MIIBMQYLKwYBBAGBtTcBAgEwggEgMC4GCCsGAQUFBwIBFiJodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMDQGCCsGAQUFBwIBFihodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9pbnRlcm1lZGlhdGUucGRmMIG3BggrBgEFBQcC
# AjCBqjAUFg1TdGFydENvbSBMdGQuMAMCAQEagZFMaW1pdGVkIExpYWJpbGl0eSwg
# c2VlIHNlY3Rpb24gKkxlZ2FsIExpbWl0YXRpb25zKiBvZiB0aGUgU3RhcnRDb20g
# Q2VydGlmaWNhdGlvbiBBdXRob3JpdHkgUG9saWN5IGF2YWlsYWJsZSBhdCBodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS9wb2xpY3kucGRmMGMGA1UdHwRcMFowK6ApoCeG
# JWh0dHA6Ly93d3cuc3RhcnRzc2wuY29tL2NydGMyLWNybC5jcmwwK6ApoCeGJWh0
# dHA6Ly9jcmwuc3RhcnRzc2wuY29tL2NydGMyLWNybC5jcmwwgYkGCCsGAQUFBwEB
# BH0wezA3BggrBgEFBQcwAYYraHR0cDovL29jc3Auc3RhcnRzc2wuY29tL3N1Yi9j
# bGFzczIvY29kZS9jYTBABggrBgEFBQcwAoY0aHR0cDovL3d3dy5zdGFydHNzbC5j
# b20vY2VydHMvc3ViLmNsYXNzMi5jb2RlLmNhLmNydDAjBgNVHRIEHDAahhhodHRw
# Oi8vd3d3LnN0YXJ0c3NsLmNvbS8wDQYJKoZIhvcNAQEFBQADggEBACY+J88ZYr5A
# 6lYz/L4OGILS7b6VQQYn2w9Wl0OEQEwlTq3bMYinNoExqCxXhFCHOi58X6r8wdHb
# E6mU8h40vNYBI9KpvLjAn6Dy1nQEwfvAfYAL8WMwyZykPYIS/y2Dq3SB2XvzFy27
# zpIdla8qIShuNlX22FQL6/FKBriy96jcdGEYF9rbsuWku04NqSLjNM47wCAzLs/n
# FXpdcBL1R6QEK4MRhcEL9Ho4hGbVvmJES64IY+P3xlV2vlEJkk3etB/FpNDOQf8j
# RTXrrBUYFvOCv20uHsRpc3kFduXt3HRV2QnAlRpG26YpZN4xvgqSGXUeqRceef7D
# dm4iTdHK5tIxggI0MIICMAIBATCBkjCBjDELMAkGA1UEBhMCSUwxFjAUBgNVBAoT
# DVN0YXJ0Q29tIEx0ZC4xKzApBgNVBAsTIlNlY3VyZSBEaWdpdGFsIENlcnRpZmlj
# YXRlIFNpZ25pbmcxODA2BgNVBAMTL1N0YXJ0Q29tIENsYXNzIDIgUHJpbWFyeSBJ
# bnRlcm1lZGlhdGUgT2JqZWN0IENBAgFRMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3
# AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisG
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBQmouinyY/o
# kor4J9EkfuY0/g2zNzANBgkqhkiG9w0BAQEFAASCAQCFUxrdshzjPx+Lcf4Q3Qmi
# J1wS/jyIt1sw2XRg5eUDm4IrBYdYCAanNWULFv7WilA43GUpAygBWUzvDhqe4Sav
# ezKabIxDOs/ixH1gRH8M0MR3QrUz9tEAmT5+DZOPWKAoYzXsIpetFhrOdmQwT+ma
# kXGOr68jaNYFq3uEkh0uswp2udyEQnxr0HcjvDteG4DfDvxAGakM+bSC0CtPA8ps
# OKWSK0tB+9ONssIYXNOBFLdKLISNGpfNdDQjHnAPuZVXfXnxtXtaYJMURFW17ZpY
# uq25B+1h/O+d/twgnxaNP8mNL2M8JMFziWx21LAWWlFR6LJsf7yQlCMI4ZCMntak
# SIG # End signature block
