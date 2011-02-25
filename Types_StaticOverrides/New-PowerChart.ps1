####  Before this will work, YOU MUST HAVE:
####   INSTALLED the JUNE WPF Toolkit http://wpf.codeplex.com 
####   INSTALLED, and IMPORTED in your current session, the PowerBoots Module
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
param(
   [Parameter(Position=0, Mandatory=$true)]
   [ValidateSet("Area","Bar","Bubble","Column","Line","Pie","Scatter")]
   [String[]]
   ${ChartType},
    
    [Parameter(Position=1, Mandatory=$true, HelpMessage='The data for the chart ...')]
    [System.Management.Automation.ScriptBlock[]]
    ${ItemsSource},

    [Parameter(Position=2, HelpMessage='The property name for the independent values ...')]
    [String[]]
    ${IndependentValuePath},
    
    [Parameter(Position=3, HelpMessage='The property name for the dependent values ...')]
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

    [PSObject]
    ${FontSize},

    [PSObject]
    ${Height},

    [PSObject]
    ${Left},

    [PSObject]
    ${MaxHeight},

    [PSObject]
    ${MaxWidth},

    [PSObject]
    ${MinHeight},

    [PSObject]
    ${MinWidth},

    [PSObject]
    ${Opacity},

    [PSObject]
    ${Top},

    [PSObject]
    ${Width},

    [PSObject]
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

    [PSObject]
    ${ContextMenu},

    [PSObject]
    ${Template},

    [PSObject]
    ${ContentTemplateSelector},

    [PSObject]
    ${BindingGroup},

    [PSObject]
    ${ContentTemplate},

    [PSObject]
    ${FlowDirection},

    [PSObject]
    ${FontStretch},

    [PSObject]
    ${FontStyle},

    [PSObject]
    ${FontWeight},

    [PSObject]
    ${HorizontalAlignment},

    [PSObject]
    ${HorizontalContentAlignment},

    [PSObject]
    ${CommandBindings},

    [PSObject]
    ${Cursor},

    [PSObject[]]
    ${InputBindings},

    [PSObject]
    ${InputScope},

    [PSObject]
    ${Language},

    [PSObject]
    ${Background},

    [PSObject]
    ${BorderBrush},

    [PSObject]
    ${Foreground},

    [PSObject]
    ${OpacityMask},

    [PSObject]
    ${BitmapEffect},

    [PSObject]
    ${BitmapEffectInput},

    [PSObject]
    ${Effect},

    [PSObject]
    ${FontFamily},

    [PSObject]
    ${Clip},

    [PSObject]
    ${Icon},

    [PSObject]
    ${LayoutTransform},

    [PSObject]
    ${RenderTransform},

    [PSObject]
    ${RenderTransformOrigin},

    [PSObject]
    ${ResizeMode},

    [PSObject]
    ${Resources},

    [PSObject]
    ${RenderSize},

    [PSObject]
    ${SizeToContent},

    [PSObject]
    ${FocusVisualStyle},

    [PSObject]
    ${Style},

    [PSObject]
    ${BorderThickness},

    [PSObject]
    ${Margin},

    [PSObject]
    ${Padding},

    [PSObject]
    ${Triggers},

    [PSObject]
    ${VerticalAlignment},

    [PSObject]
    ${VerticalContentAlignment},

    [PSObject]
    ${Visibility},

    [PSObject]
    ${Owner},

    [PSObject]
    ${WindowStartupLocation},

    [PSObject]
    ${WindowState},

    [PSObject]
    ${WindowStyle},

    [PSObject]
    ${On_Closing},

    [PSObject]
    ${On_Activated},

    [PSObject]
    ${On_Closed},

    [PSObject]
    ${On_ContentRendered},

    [PSObject]
    ${On_Deactivated},

    [PSObject]
    ${On_Initialized},

    [PSObject]
    ${On_LayoutUpdated},

    [PSObject]
    ${On_LocationChanged},

    [PSObject]
    ${On_SourceInitialized},

    [PSObject]
    ${On_StateChanged},

    [PSObject]
    ${On_SourceUpdated},

    [PSObject]
    ${On_TargetUpdated},

    [PSObject]
    ${On_ContextMenuClosing},

    [PSObject]
    ${On_ContextMenuOpening},

    [PSObject]
    ${On_ToolTipClosing},

    [PSObject]
    ${On_ToolTipOpening},

    [PSObject]
    ${On_DataContextChanged},

    [PSObject]
    ${On_FocusableChanged},

    [PSObject]
    ${On_IsEnabledChanged},

    [PSObject]
    ${On_IsHitTestVisibleChanged},

    [PSObject]
    ${On_IsKeyboardFocusedChanged},

    [PSObject]
    ${On_IsKeyboardFocusWithinChanged},

    [PSObject]
    ${On_IsMouseCapturedChanged},

    [PSObject]
    ${On_IsMouseCaptureWithinChanged},

    [PSObject]
    ${On_IsMouseDirectlyOverChanged},

    [PSObject]
    ${On_IsStylusCapturedChanged},

    [PSObject]
    ${On_IsStylusCaptureWithinChanged},

    [PSObject]
    ${On_IsStylusDirectlyOverChanged},

    [PSObject]
    ${On_IsVisibleChanged},

    [PSObject]
    ${On_DragEnter},

    [PSObject]
    ${On_DragLeave},

    [PSObject]
    ${On_DragOver},

    [PSObject]
    ${On_Drop},

    [PSObject]
    ${On_PreviewDragEnter},

    [PSObject]
    ${On_PreviewDragLeave},

    [PSObject]
    ${On_PreviewDragOver},

    [PSObject]
    ${On_PreviewDrop},

    [PSObject]
    ${On_GiveFeedback},

    [PSObject]
    ${On_PreviewGiveFeedback},

    [PSObject]
    ${On_GotKeyboardFocus},

    [PSObject]
    ${On_LostKeyboardFocus},

    [PSObject]
    ${On_PreviewGotKeyboardFocus},

    [PSObject]
    ${On_PreviewLostKeyboardFocus},

    [PSObject]
    ${On_KeyDown},

    [PSObject]
    ${On_KeyUp},

    [PSObject]
    ${On_PreviewKeyDown},

    [PSObject]
    ${On_PreviewKeyUp},

    [PSObject]
    ${On_MouseDoubleClick},

    [PSObject]
    ${On_MouseDown},

    [PSObject]
    ${On_MouseLeftButtonDown},

    [PSObject]
    ${On_MouseLeftButtonUp},

    [PSObject]
    ${On_MouseRightButtonDown},

    [PSObject]
    ${On_MouseRightButtonUp},

    [PSObject]
    ${On_MouseUp},

    [PSObject]
    ${On_PreviewMouseDoubleClick},

    [PSObject]
    ${On_PreviewMouseDown},

    [PSObject]
    ${On_PreviewMouseLeftButtonDown},

    [PSObject]
    ${On_PreviewMouseLeftButtonUp},

    [PSObject]
    ${On_PreviewMouseRightButtonDown},

    [PSObject]
    ${On_PreviewMouseRightButtonUp},

    [PSObject]
    ${On_PreviewMouseUp},

    [PSObject]
    ${On_GotMouseCapture},

    [PSObject]
    ${On_LostMouseCapture},

    [PSObject]
    ${On_MouseEnter},

    [PSObject]
    ${On_MouseLeave},

    [PSObject]
    ${On_MouseMove},

    [PSObject]
    ${On_PreviewMouseMove},

    [PSObject]
    ${On_MouseWheel},

    [PSObject]
    ${On_PreviewMouseWheel},

    [PSObject]
    ${On_QueryCursor},

    [PSObject]
    ${On_PreviewStylusButtonDown},

    [PSObject]
    ${On_PreviewStylusButtonUp},

    [PSObject]
    ${On_StylusButtonDown},

    [PSObject]
    ${On_StylusButtonUp},

    [PSObject]
    ${On_PreviewStylusDown},

    [PSObject]
    ${On_StylusDown},

    [PSObject]
    ${On_GotStylusCapture},

    [PSObject]
    ${On_LostStylusCapture},

    [PSObject]
    ${On_PreviewStylusInAirMove},

    [PSObject]
    ${On_PreviewStylusInRange},

    [PSObject]
    ${On_PreviewStylusMove},

    [PSObject]
    ${On_PreviewStylusOutOfRange},

    [PSObject]
    ${On_PreviewStylusUp},

    [PSObject]
    ${On_StylusEnter},

    [PSObject]
    ${On_StylusInAirMove},

    [PSObject]
    ${On_StylusInRange},

    [PSObject]
    ${On_StylusLeave},

    [PSObject]
    ${On_StylusMove},

    [PSObject]
    ${On_StylusOutOfRange},

    [PSObject]
    ${On_StylusUp},

    [PSObject]
    ${On_PreviewStylusSystemGesture},

    [PSObject]
    ${On_StylusSystemGesture},

    [PSObject]
    ${On_PreviewTextInput},

    [PSObject]
    ${On_TextInput},

    [PSObject]
    ${On_PreviewQueryContinueDrag},

    [PSObject]
    ${On_QueryContinueDrag},

    [PSObject]
    ${On_RequestBringIntoView},

    [PSObject]
    ${On_GotFocus},

    [PSObject]
    ${On_Loaded},

    [PSObject]
    ${On_LostFocus},

    [PSObject]
    ${On_Unloaded},

    [PSObject]
    ${On_SizeChanged}
)

if( -not (@(Get-BootsAssemblies) -match "DataVisualization\.Toolkit, Version=3\.5\..*") ) {
   if(Get-Command New-System.Windows.VisualState) {
      "${Env:ProgramFiles}\WPF Toolkit", "${Env:ProgramFiles(x86)}\WPF Toolkit" |
      Where { Test-Path $_ } |
      Get-ChildItem -recurse -filter *Toolkit.dll |
      ForEach { [Reflection.Assembly]::LoadFrom( $_.FullName ) } | Out-Null
   } else {
      "${Env:ProgramFiles}\WPF Toolkit", "${Env:ProgramFiles(x86)}\WPF Toolkit" |
      Where { Test-Path $_ } |
      Get-ChildItem -recurse -filter *Toolkit.dll |
      Add-BootsFunction
   }
}

if($ExecutionContext.SessionState.Module.Guid -ne (Get-BootsModule).Guid) {
	Write-Warning "PowerChart not invoked in PowerBoots context. Attempting to reinvoke."
   $scriptParam = $PSBoundParameters
   return iex "& (Get-BootsModule) '$($MyInvocation.MyCommand.Path)' `@PSBoundParameters"
}
# Write-Host "Condition in module $($executioncontext.sessionstate.module) context!" -fore Green


Add-BootsTemplate $PSScriptRoot\XamlTemplates\PowerCharting.xaml


# . C:\Users\Joel\Documents\WindowsPowershell\Modules\PowerBoots\New-PowerChart.ps1
# PowerChart Area { ls | ? {!$_.PSIsContainer} } Name Length -Background White
# PowerChart Pie { ls | ?{!$_.PSIsContainer} } Name Length
# PowerChart Column { ls | ?{!$_.PSIsContainer} } Name Length
# PowerChart Pie { ls | ?{!$_.PSIsContainer} } Name Length

function Global:Ping-Host {
   new-object psobject | 
   add-member NoteProperty   Time $(Get-Date) -Passthru |
   Add-Member NoteProperty   Ping $([int]([regex]"time=(\d+)ms").Match( (ping.exe $args[0] -n 1) ).Groups[1].Value) -Passthru | 
   Add-Member ScriptProperty Age  { ($(Get-Date) - $this.Time).TotalMinutes } -Passthru
}

function Global:Ping-Monitor {
Param([string[]]$Hosts)

  $global:pings = @{}
  [ScriptBlock[]]$scripts = @()
  foreach($h in $Hosts) {
   $global:pings."$h" = new-object system.collections.queue 21
   $global:pings."$h".Enqueue($(Ping-Host $h))
   $scripts += iex "{ 
        `$global:pings.'$h'.Enqueue((Ping-Host '$h'))
        if(`$pings.'$h'.Count -gt 20) { `$pings.'$h'.Dequeue()|Out-Null } 
        Write-Output `$pings.'$h'
     }"
  }
  New-PowerChart $(@("Line")*$Hosts.Count) -Items $scripts $(@("Age")*$Hosts.Count) $(@("Ping")*$Hosts.Count) -Interval "00:00:02"                                      
}

#  Boots { 
#     $global:timer = DispatcherTimer -Interval "00:00:10" -On_Tick { $series.ItemsSource = ls | ? { !$_.PsIsContainer } }
#     Chart { PieSeries -DependentValuePath Length -IndependentValuePath Name | Tee -var global:series }
#     $timer.Start()
#  } -On_Closed { $timer.Stop() }


function Global:New-PowerChart() {
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
param(
   [Parameter(Position=0, Mandatory=$true)]
   [ValidateSet("Area","Bar","Bubble","Column","Line","Pie","Scatter")]
   [String[]]
   ${ChartType},
    
    [Parameter(Position=1, HelpMessage='The data for the chart ...')]
    [System.Management.Automation.ScriptBlock[]]
    ${ItemsSource},

    [Parameter(Position=2, HelpMessage='The property name for the independent values ...')]
    [String[]]
    ${IndependentValuePath},
    
    [Parameter(Position=3, HelpMessage='The property name for the dependent values ...')]
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

    [PSObject]
    ${FontSize},

    [PSObject]
    ${Height},

    [PSObject]
    ${Left},

    [PSObject]
    ${MaxHeight},

    [PSObject]
    ${MaxWidth},

    [PSObject]
    ${MinHeight},

    [PSObject]
    ${MinWidth},

    [PSObject]
    ${Opacity},

    [PSObject]
    ${Top},

    [PSObject]
    ${Width},

    [PSObject]
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

    [PSObject]
    ${ContextMenu},

    [PSObject]
    ${Template},

    [PSObject]
    ${ContentTemplateSelector},

    [PSObject]
    ${BindingGroup},

    [PSObject]
    ${ContentTemplate},

    [PSObject]
    ${FlowDirection},

    [PSObject]
    ${FontStretch},

    [PSObject]
    ${FontStyle},

    [PSObject]
    ${FontWeight},

    [PSObject]
    ${HorizontalAlignment},

    [PSObject]
    ${HorizontalContentAlignment},

    [PSObject]
    ${CommandBindings},

    [PSObject]
    ${Cursor},

    [PSObject[]]
    ${InputBindings},

    [PSObject]
    ${InputScope},

    [PSObject]
    ${Language},

    [PSObject]
    ${Background},

    [PSObject]
    ${BorderBrush},

    [PSObject]
    ${Foreground},

    [PSObject]
    ${OpacityMask},

    [PSObject]
    ${BitmapEffect},

    [PSObject]
    ${BitmapEffectInput},

    [PSObject]
    ${Effect},

    [PSObject]
    ${FontFamily},

    [PSObject]
    ${Clip},

    [PSObject]
    ${Icon},

    [PSObject]
    ${LayoutTransform},

    [PSObject]
    ${RenderTransform},

    [PSObject]
    ${RenderTransformOrigin},

    [PSObject]
    ${ResizeMode},

    [PSObject]
    ${Resources},

    [PSObject]
    ${RenderSize},

    [PSObject]
    ${SizeToContent},

    [PSObject]
    ${FocusVisualStyle},

    [PSObject]
    ${Style},

    [PSObject]
    ${BorderThickness},

    [PSObject]
    ${Margin},

    [PSObject]
    ${Padding},

    [PSObject]
    ${Triggers},

    [PSObject]
    ${VerticalAlignment},

    [PSObject]
    ${VerticalContentAlignment},

    [PSObject]
    ${Visibility},

    [PSObject]
    ${Owner},

    [PSObject]
    ${WindowStartupLocation},

    [PSObject]
    ${WindowState},

    [PSObject]
    ${WindowStyle},

    [PSObject]
    ${On_Closing},

    [PSObject]
    ${On_Activated},

    [PSObject]
    ${On_Closed},

    [PSObject]
    ${On_ContentRendered},

    [PSObject]
    ${On_Deactivated},

    [PSObject]
    ${On_Initialized},

    [PSObject]
    ${On_LayoutUpdated},

    [PSObject]
    ${On_LocationChanged},

    [PSObject]
    ${On_SourceInitialized},

    [PSObject]
    ${On_StateChanged},

    [PSObject]
    ${On_SourceUpdated},

    [PSObject]
    ${On_TargetUpdated},

    [PSObject]
    ${On_ContextMenuClosing},

    [PSObject]
    ${On_ContextMenuOpening},

    [PSObject]
    ${On_ToolTipClosing},

    [PSObject]
    ${On_ToolTipOpening},

    [PSObject]
    ${On_DataContextChanged},

    [PSObject]
    ${On_FocusableChanged},

    [PSObject]
    ${On_IsEnabledChanged},

    [PSObject]
    ${On_IsHitTestVisibleChanged},

    [PSObject]
    ${On_IsKeyboardFocusedChanged},

    [PSObject]
    ${On_IsKeyboardFocusWithinChanged},

    [PSObject]
    ${On_IsMouseCapturedChanged},

    [PSObject]
    ${On_IsMouseCaptureWithinChanged},

    [PSObject]
    ${On_IsMouseDirectlyOverChanged},

    [PSObject]
    ${On_IsStylusCapturedChanged},

    [PSObject]
    ${On_IsStylusCaptureWithinChanged},

    [PSObject]
    ${On_IsStylusDirectlyOverChanged},

    [PSObject]
    ${On_IsVisibleChanged},

    [PSObject]
    ${On_DragEnter},

    [PSObject]
    ${On_DragLeave},

    [PSObject]
    ${On_DragOver},

    [PSObject]
    ${On_Drop},

    [PSObject]
    ${On_PreviewDragEnter},

    [PSObject]
    ${On_PreviewDragLeave},

    [PSObject]
    ${On_PreviewDragOver},

    [PSObject]
    ${On_PreviewDrop},

    [PSObject]
    ${On_GiveFeedback},

    [PSObject]
    ${On_PreviewGiveFeedback},

    [PSObject]
    ${On_GotKeyboardFocus},

    [PSObject]
    ${On_LostKeyboardFocus},

    [PSObject]
    ${On_PreviewGotKeyboardFocus},

    [PSObject]
    ${On_PreviewLostKeyboardFocus},

    [PSObject]
    ${On_KeyDown},

    [PSObject]
    ${On_KeyUp},

    [PSObject]
    ${On_PreviewKeyDown},

    [PSObject]
    ${On_PreviewKeyUp},

    [PSObject]
    ${On_MouseDoubleClick},

    [PSObject]
    ${On_MouseDown},

    [PSObject]
    ${On_MouseLeftButtonDown},

    [PSObject]
    ${On_MouseLeftButtonUp},

    [PSObject]
    ${On_MouseRightButtonDown},

    [PSObject]
    ${On_MouseRightButtonUp},

    [PSObject]
    ${On_MouseUp},

    [PSObject]
    ${On_PreviewMouseDoubleClick},

    [PSObject]
    ${On_PreviewMouseDown},

    [PSObject]
    ${On_PreviewMouseLeftButtonDown},

    [PSObject]
    ${On_PreviewMouseLeftButtonUp},

    [PSObject]
    ${On_PreviewMouseRightButtonDown},

    [PSObject]
    ${On_PreviewMouseRightButtonUp},

    [PSObject]
    ${On_PreviewMouseUp},

    [PSObject]
    ${On_GotMouseCapture},

    [PSObject]
    ${On_LostMouseCapture},

    [PSObject]
    ${On_MouseEnter},

    [PSObject]
    ${On_MouseLeave},

    [PSObject]
    ${On_MouseMove},

    [PSObject]
    ${On_PreviewMouseMove},

    [PSObject]
    ${On_MouseWheel},

    [PSObject]
    ${On_PreviewMouseWheel},

    [PSObject]
    ${On_QueryCursor},

    [PSObject]
    ${On_PreviewStylusButtonDown},

    [PSObject]
    ${On_PreviewStylusButtonUp},

    [PSObject]
    ${On_StylusButtonDown},

    [PSObject]
    ${On_StylusButtonUp},

    [PSObject]
    ${On_PreviewStylusDown},

    [PSObject]
    ${On_StylusDown},

    [PSObject]
    ${On_GotStylusCapture},

    [PSObject]
    ${On_LostStylusCapture},

    [PSObject]
    ${On_PreviewStylusInAirMove},

    [PSObject]
    ${On_PreviewStylusInRange},

    [PSObject]
    ${On_PreviewStylusMove},

    [PSObject]
    ${On_PreviewStylusOutOfRange},

    [PSObject]
    ${On_PreviewStylusUp},

    [PSObject]
    ${On_StylusEnter},

    [PSObject]
    ${On_StylusInAirMove},

    [PSObject]
    ${On_StylusInRange},

    [PSObject]
    ${On_StylusLeave},

    [PSObject]
    ${On_StylusMove},

    [PSObject]
    ${On_StylusOutOfRange},

    [PSObject]
    ${On_StylusUp},

    [PSObject]
    ${On_PreviewStylusSystemGesture},

    [PSObject]
    ${On_StylusSystemGesture},

    [PSObject]
    ${On_PreviewTextInput},

    [PSObject]
    ${On_TextInput},

    [PSObject]
    ${On_PreviewQueryContinueDrag},

    [PSObject]
    ${On_QueryContinueDrag},

    [PSObject]
    ${On_RequestBringIntoView},

    [PSObject]
    ${On_GotFocus},

    [PSObject]
    ${On_Loaded},

    [PSObject]
    ${On_LostFocus},

    [PSObject]
    ${On_Unloaded},

    [PSObject]
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
}
process {
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
         # $PSBoundParameters = Set-Param Background -Default ([System.Windows.Media.Brush]"#33FFFFFF") -PSBoundParameters $PSBoundParameters
      }

      $global:PowerChartValues = @{ 
         "ChartType" = $ChartType
         "ItemsSource" = $ItemsSource
         "DependentValuePath" = $DependentValuePath
         "IndependentValuePath" = $IndependentValuePath
         "SizeValuePath" = $SizeValuePath
         "Interval" = $Interval
         "Series" = @()
      }

      Write-Debug "Bound Parameters: $( $PSBoundParameters | fl | Out-string )"

      # Write-Host "One" -Fore Green
      New-BootsWindow @PSBoundParameters { 
         # Param($global:w)
         if($PowerChartValues."Interval") {
            # Write-Host "Setting Udpate Interval to $($PowerChartValues.Interval)" -Fore Cyan
         
            $PowerChartValues.Timer = DispatcherTimer -Interval $PowerChartValues.Interval -Tag $this -On_Tick {
                              # Write-Host "tick. " -nonewline -fore cyan
                              $i=0
                              $this.Tag.Tag.Series | ForEach{ $_.ItemsSource = &$($this.Tag.Tag.ItemsSource[$i++]) }
                           }
            $this.Add_Loaded( { $this.Tag.Timer.Start() } )
            $this.Add_Closed( { $this.Tag.Timer.Stop() } )
         }
         # Write-Host "Two" -Fore Green
         Chart {
            # Write-Host "Three" -Fore Cyan
            for($c=0; $c -lt $PowerChartValues.ChartType.length; $c++) {
               $chartType = $PowerChartValues.ChartType[$c].ToLower()
               $cmd = "$($chartType)Series -ItemsSource `$(&{$($PowerChartValues.ItemsSource[$c])})"
               if($PowerChartValues.SizeValuePath -and $PowerChartValues.ChartType[$c] -eq "Bubble") {
                  $cmd += " -SizeValuePath $($PowerChartValues.SizeValuePath[$c])"
               }
               if($PowerChartValues.DependentValuePath) {
                  $cmd += " -DependentValuePath $($PowerChartValues.DependentValuePath[$c])"
               }
               if($PowerChartValues.IndependentValuePath) {
                  $cmd += " -IndependentValuePath $($PowerChartValues.IndependentValuePath[$c])"
               }
               # Write-Host "$cmd"
                  
               if($PowerChartValues.ChartType[$c] -eq "Pie") {                                                                                                                                                          
                  $cmd += " -StylePalette `$this.FindResource(""$($chartType)StylePalletTooltipsFix"")"
               } else {
                  # $PowerChartValues.Series[-1].DataPointStyle = $PowerChartValues.Series[-1].FindResource("$($chartType)DataPointTooltipsFix")
               }
               
               $PowerChartValues.Series += iex $cmd
            }
            # Write-Host "Series: $($this.Tag.Series.Count): $($this.Tag.Series)" -Fore Green
            $PowerChartValues.Series
            # Write-Host "Four" -Fore Cyan
         }
         # Write-Host "Five" -Fore Green
         ## Store the $PowerChartValues so we can reuse the variable...
      } -Tag $PowerChartValues
      # Write-Host "Six" -Fore Magenta

      #  $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('New-BootsWindow', [System.Management.Automation.CommandTypes]::Cmdlet)
      #  $scriptCmd = {& $wrappedCmd @PSBoundParameters }
      #  $steppablePipeline = $scriptCmd.GetSteppablePipeline()
      #  $steppablePipeline.Begin($PSCmdlet)

}
}
New-PowerChart @PSBoundParameters

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSu/jexQSgbPOy2sIvNTy8gos
# mNygggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUZ87kHxSK
# WvDdcl3Ox62KNdkOKzIwDQYJKoZIhvcNAQEBBQAEggEAkix7m3cT5bmS+WqNXwpm
# TmySFHqfaggJ0mGrD3JaXDXha0wwpkS2G5stRufBI9ClDJYDYIDaCcC8dOJS2StE
# /vM3lqaz9+6zAgFUwcvbgniRfbYDgAmT9CAYeEFQv0Zh9wQxl64iInrD3O+lLVEK
# +3BsRqwwGLLvNkhYH12WbHbG3w60Gw63Wm6dunZHOrxBPSO+deWKEvVj5sS+sb7+
# zwCso1VdaQXBdS5eQjfSwIUUGflzZYlVxeFTGC5OzkX+0JeNELqilrkOTirrEPOP
# 161chTKYLANwCaPGspAUvTW+CkE7wkOBsAhDSLzNa61vd2YzCmFtOuH4hgGBjZrg
# 1w==
# SIG # End signature block
