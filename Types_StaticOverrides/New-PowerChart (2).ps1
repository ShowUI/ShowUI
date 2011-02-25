if(!(Get-Command New-BootsWindow -EA 0)) {
   Import-Module PowerBoots
}                                                                                                                            
if(Get-Command New-System.Windows.VisualState) {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   ForEach { [Reflection.Assembly]::LoadFrom( $_.FullName ) } | Out-Null

   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
} else {
   ls "${Env:ProgramFiles}\WPF Toolkit",
      "${Env:ProgramFiles(x86)}\WPF Toolkit" -recurse -filter *Toolkit.dll -EA 0 -EV err | 
   Add-BootsFunction

   if($err.Count -eq 2){Write-Error "Couldn't find the 'WPF Toolkit' in your Program Files folder..." }
}

Add-BootsTemplate C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\XamlTemplates\PowerCharting.xaml

# . C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\New-PowerChart.ps1
# New-PowerChart Pie { ls | ? {!$_.PSIsContainer} } Name Length
# New-PowerChart Pie { ls | ?{!$_.PSIsContainer} } Name Length -ResizeMode CanResizeWithGrip -Background Transparent

function Ping-Host {
   new-object psobject | 
   add-member NoteProperty   Time $(Get-Date) -Passthru |
   Add-Member NoteProperty   Ping $([int]([regex]"time=(\d+)ms").Match( (ping.exe $args[0] -n 1) ).Groups[1].Value) -Passthru | 
   Add-Member ScriptProperty Ago  { ($(Get-Date) - $this.Time).TotalMinutes } -Passthru
}

#  $global:pings = new-object system.collections.queue 21
#  $global:pings.Enqueue($(Ping-Host "huddledmasses.org"))
#  New-PowerChart Line { 
#     $global:pings.Enqueue( (Ping-Host huddledmasses.org) )
#     if($pings.Count -gt 20) { $pings.Dequeue()|Out-Null } 
#     Write-Output $pings
#  } Ago Ping -Interval "00:00:02"                                      

#  Boots { 
#     $global:timer = DispatcherTimer -Interval "00:00:10" -On_Tick { $series.ItemsSource = ls | ? { !$_.PsIsContainer } }
#     Chart { PieSeries -DependentValuePath Length -IndependentValuePath Name | Tee -var global:series }
#     $timer.Start()
#  } -On_Closed { $timer.Stop() }


function New-PowerChart() {
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
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

   try {

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
         $w.Tag = $PowerChartValues
         Chart {
            for($c=0; $c -lt $w.tag.ChartType.length; $c++) {
               if($w.tag.SizeValuePath) {
                  Write-Host "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -SizeValuePath $($w.Tag.SizeValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])})"
                  $w.Tag.Series += iex "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -SizeValuePath $($w.Tag.SizeValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])})"
               } else {                                                                                                                                                          
                  Write-Host "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])})"
                  $w.Tag.Series += iex "$($w.tag.ChartType[$c])Series -DependentValuePath $($w.Tag.DependentValuePath[$c]) -IndependentValuePath $($w.Tag.IndependentValuePath[$c]) -ItemsSource `$(&{$($w.Tag.ItemsSource[$c])})"
               }                                                                                                                                               
            }
            # Write-Host "Series: $($w.Tag.Series.Count): $($w.Tag.Series)" -Fore Green
            $w.Tag.Series
         } -Background Transparent -BorderThickness 0
         
         if($w.Tag."Interval") {
            Write-Host "Setting Udpate Interval to $Interval"
         
            $w.Tag.Timer = DispatcherTimer -Interval $w.Tag.Interval -Tag $w -On_Tick {
                              Write-Host "tick. " -nonewline -fore cyan
                              $i=0
                              $this.Tag.Tag.Series | ForEach{ $_.ItemsSource = &$($this.Tag.Tag.ItemsSource[$i++]) }
                           }
            $w.Add_Loaded( { $this.Tag.Timer.Start() } )
            $w.Add_Closed( { $this.Tag.Timer.Stop() } )
         }
      }
      Write-Verbose "six"

      #  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('New-BootsWindow', [System.Management.Automation.CommandTypes]::Cmdlet)
      #  $scriptCmd = {& $wrappedCmd @PSBoundParameters }
      #  $steppablePipeline = $scriptCmd.GetSteppablePipeline()
      #  $steppablePipeline.Begin($PSCmdlet)
      
   } catch {
      Write-Error $($_|Out-String) -Fore Red
   }
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
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUvGP7IIKXuLMjf3JnNnX38o7D
# Xh+gggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
# AQUFADCBlTELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAlVUMRcwFQYDVQQHEw5TYWx0
# IExha2UgQ2l0eTEeMBwGA1UEChMVVGhlIFVTRVJUUlVTVCBOZXR3b3JrMSEwHwYD
# VQQLExhodHRwOi8vd3d3LnVzZXJ0cnVzdC5jb20xHTAbBgNVBAMTFFVUTi1VU0VS
# Rmlyc3QtT2JqZWN0MB4XDTEwMDUxNDAwMDAwMFoXDTExMDUxNDIzNTk1OVowgZUx
# CzAJBgNVBAYTAlVTMQ4wDAYDVQQRDAUwNjg1MDEUMBIGA1UECAwLQ29ubmVjdGlj
# dXQxEDAOBgNVBAcMB05vcndhbGsxFjAUBgNVBAkMDTQ1IEdsb3ZlciBBdmUxGjAY
# BgNVBAoMEVhlcm94IENvcnBvcmF0aW9uMRowGAYDVQQDDBFYZXJveCBDb3Jwb3Jh
# dGlvbjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMfUdxwiuWDb8zId
# KuMg/jw0HndEcIsP5Mebw56t3+Rb5g4QGMBoa8a/N8EKbj3BnBQDJiY5Z2DGjf1P
# n27g2shrDaNT1MygjYfLDntYzNKMJk4EjbBOlR5QBXPM0ODJDROg53yHcvVaXSMl
# 498SBhXVSzPmgprBJ8FDL00o1IIAAhYUN3vNCKPBXsPETsKtnezfzBg7lOjzmljC
# mEOoBGT1g2NrYTq3XqNo8UbbDR8KYq5G101Vl0jZEnLGdQFyh8EWpeEeksv7V+YD
# /i/iXMSG8HiHY7vl+x8mtBCf0MYxd8u1IWif0kGgkaJeTCVwh1isMrjiUnpWX2NX
# +3PeTmsCAwEAAaOCAW8wggFrMB8GA1UdIwQYMBaAFNrtZHQUnBQ8q92Zqb1bKE2L
# PMnYMB0GA1UdDgQWBBTK0OAaUIi5wvnE8JonXlTXKWENvTAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwRgYDVR0gBD8wPTA7BgwrBgEEAbIxAQIBAwIwKzApBggrBgEFBQcC
# ARYdaHR0cHM6Ly9zZWN1cmUuY29tb2RvLm5ldC9DUFMwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC51c2VydHJ1c3QuY29tL1VUTi1VU0VSRmlyc3QtT2JqZWN0
# LmNybDA0BggrBgEFBQcBAQQoMCYwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmNv
# bW9kb2NhLmNvbTAhBgNVHREEGjAYgRZKb2VsLkJlbm5ldHRAWGVyb3guY29tMA0G
# CSqGSIb3DQEBBQUAA4IBAQAEss8yuj+rZvx2UFAgkz/DueB8gwqUTzFbw2prxqee
# zdCEbnrsGQMNdPMJ6v9g36MRdvAOXqAYnf1RdjNp5L4NlUvEZkcvQUTF90Gh7OA4
# rC4+BjH8BA++qTfg8fgNx0T+MnQuWrMcoLR5ttJaWOGpcppcptdWwMNJ0X6R2WY7
# bBPwa/CdV0CIGRRjtASbGQEadlWoc1wOfR+d3rENDg5FPTAIdeRVIeA6a1ZYDCYb
# 32UxoNGArb70TCpV/mTWeJhZmrPFoJvT+Lx8ttp1bH2/nq6BDAIvu0VGgKGxN4bA
# T3WE6MuMS2fTc1F8PCGO3DAeA9Onks3Ufuy16RhHqeNcMYICTDCCAkgCAQEwgaow
# gZUxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJVVDEXMBUGA1UEBxMOU2FsdCBMYWtl
# IENpdHkxHjAcBgNVBAoTFVRoZSBVU0VSVFJVU1QgTmV0d29yazEhMB8GA1UECxMY
# aHR0cDovL3d3dy51c2VydHJ1c3QuY29tMR0wGwYDVQQDExRVVE4tVVNFUkZpcnN0
# LU9iamVjdAIQKQm90jYWUDdv7EgFkuELajAJBgUrDgMCGgUAoHgwGAYKKwYBBAGC
# NwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgor
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUkMTECMaz
# bwXBB3+OmftiWpUCw3IwDQYJKoZIhvcNAQEBBQAEggEAOB7X8CFAjutnAucQJZIr
# zAQ7HKjRlezBjVrlSURmM56Y62iNM1Y2IiveVdJC+F+wjkoUmoGFCvn/DF/nkDka
# qDZNsoxLS245QsVfZVMjS24eWGnGnaBo1pPGqtK6nUCmH1HTlH1gGm+qf7BxKFIX
# 1+O5gl/jfReZe4JBJ9jKrdUUQHBk7W4ngj3Mi8FPLfKjQ8GI7azi08rqtSNET7Vg
# sWa6YVVVqTblv5gnvdGYVkd3Wwp8E9GCEJ66aLIxV9eS1gNdeLbk+Vm5gZb1eXrx
# siwAlYy6B4gDl0Ba8dGSKEEk/Gbxkc57Y4Lmx0y9Ik41jUp6K1EY+YS+7o/+7IMw
# zw==
# SIG # End signature block
