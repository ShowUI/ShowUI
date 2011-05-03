
if( [Array]::BinarySearch(@(Get-UIAssemblies), 'PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) -lt 0 ) {
  $null = [Reflection.Assembly]::Load( 'PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35' ) 
}
if($ExecutionContext.SessionState.Module.Guid -ne (Get-UIModule).Guid) {
	Write-Warning "Grid not invoked in Show-UI context."
   # $scriptParam = $PSBoundParameters
   # return iex "& (Get-UIModule) '$($MyInvocation.MyCommand.Path)' `@PSBoundParameters"
}
Write-Verbose "Grid in module $($executioncontext.sessionstate.module) context!"


function New-System.Windows.Controls.Grid {
<#
.Synopsis
   Create a new Grid object
.Description
   Generates a new System.Windows.Controls.Grid object, and allows setting all of it's properties.
   (From the PresentationFramework assembly v3.0.0.0)
.Notes
 GENERATOR :  v by Joel Bennett http://HuddledMasses.org
 GENERATED : 04/30/2011 01:31:47
 ASSEMBLY  : PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35
 FULLPATH  : C:\Windows\assembly\GAC_MSIL\PresentationFramework\3.0.0.0__31bf3856ad364e35\PresentationFramework.dll
#>
 
[CmdletBinding(DefaultParameterSetName='Default')]
PARAM(
	[Parameter()]
	[Switch]${AllowDrop}
,	[Parameter()]
	[Object[]]${Background}
,	[Parameter()]
	[Object[]]${BindingGroup}
,	[Parameter()]
	[Object[]]${BitmapEffect}
,	[Parameter()]
	[Object[]]${BitmapEffectInput}
,	[Parameter(Position=1,ValueFromPipeline=$true)]
	[Object[]]${Children}
,	[Parameter()]
	[Object[]]${Clip}
,	[Parameter()]
	[Switch]${ClipToBounds}
,	[Parameter(ValueFromPipelineByPropertyName=$true)]
   [Alias("Columns","Cols")]
	[Object[]]${ColumnDefinitions}
,	[Parameter()]
	[Object[]]${CommandBindings}
,	[Parameter()]
	[Object[]]${ContextMenu}
,	[Parameter()]
	[PSObject]${On_ContextMenuClosing}
,	[Parameter()]
	[PSObject]${On_ContextMenuOpening}
,	[Parameter()]
	[Object[]]${Cursor}
,	[Parameter()]
	[Object[]]${DataContext}
,	[Parameter()]
	[PSObject]${On_DataContextChanged}
,	[Parameter()]
	[PSObject]${On_DragEnter}
,	[Parameter()]
	[PSObject]${On_DragLeave}
,	[Parameter()]
	[PSObject]${On_DragOver}
,	[Parameter()]
	[PSObject]${On_Drop}
,	[Parameter()]
	[Object[]]${Effect}
,	[Parameter()]
	[Object[]]${FlowDirection}
,	[Parameter()]
	[Switch]${Focusable}
,	[Parameter()]
	[PSObject]${On_FocusableChanged}
,	[Parameter()]
	[Object[]]${FocusVisualStyle}
,	[Parameter()]
	[Switch]${ForceCursor}
,	[Parameter()]
	[PSObject]${On_GiveFeedback}
,	[Parameter()]
	[PSObject]${On_GotFocus}
,	[Parameter()]
	[PSObject]${On_GotKeyboardFocus}
,	[Parameter()]
	[PSObject]${On_GotMouseCapture}
,	[Parameter()]
	[PSObject]${On_GotStylusCapture}
,	[Parameter()]
	[Object[]]${Height}
,	[Parameter()]
	[Object[]]${HorizontalAlignment}
,	[Parameter()]
	[PSObject]${On_Initialized}
,	[Parameter()]
	[Object[]]${InputBindings}
,	[Parameter()]
	[Object[]]${InputScope}
,	[Parameter()]
	[Switch]${IsEnabled}
,	[Parameter()]
	[PSObject]${On_IsEnabledChanged}
,	[Parameter()]
	[Switch]${IsHitTestVisible}
,	[Parameter()]
	[PSObject]${On_IsHitTestVisibleChanged}
,	[Parameter()]
	[Switch]${IsItemsHost}
,	[Parameter()]
	[PSObject]${On_IsKeyboardFocusedChanged}
,	[Parameter()]
	[PSObject]${On_IsKeyboardFocusWithinChanged}
,	[Parameter()]
	[PSObject]${On_IsMouseCapturedChanged}
,	[Parameter()]
	[PSObject]${On_IsMouseCaptureWithinChanged}
,	[Parameter()]
	[PSObject]${On_IsMouseDirectlyOverChanged}
,	[Parameter()]
	[PSObject]${On_IsStylusCapturedChanged}
,	[Parameter()]
	[PSObject]${On_IsStylusCaptureWithinChanged}
,	[Parameter()]
	[PSObject]${On_IsStylusDirectlyOverChanged}
,	[Parameter()]
	[PSObject]${On_IsVisibleChanged}
,	[Parameter()]
	[PSObject]${On_KeyDown}
,	[Parameter()]
	[PSObject]${On_KeyUp}
,	[Parameter()]
	[Object[]]${Language}
,	[Parameter()]
	[Object[]]${LayoutTransform}
,	[Parameter()]
	[PSObject]${On_LayoutUpdated}
,	[Parameter()]
	[PSObject]${On_Loaded}
,	[Parameter()]
	[PSObject]${On_LostFocus}
,	[Parameter()]
	[PSObject]${On_LostKeyboardFocus}
,	[Parameter()]
	[PSObject]${On_LostMouseCapture}
,	[Parameter()]
	[PSObject]${On_LostStylusCapture}
,	[Parameter()]
	[Object[]]${Margin}
,	[Parameter()]
	[Object[]]${MaxHeight}
,	[Parameter()]
	[Object[]]${MaxWidth}
,	[Parameter()]
	[Object[]]${MinHeight}
,	[Parameter()]
	[Object[]]${MinWidth}
,	[Parameter()]
	[PSObject]${On_MouseDown}
,	[Parameter()]
	[PSObject]${On_MouseEnter}
,	[Parameter()]
	[PSObject]${On_MouseLeave}
,	[Parameter()]
	[PSObject]${On_MouseLeftButtonDown}
,	[Parameter()]
	[PSObject]${On_MouseLeftButtonUp}
,	[Parameter()]
	[PSObject]${On_MouseMove}
,	[Parameter()]
	[PSObject]${On_MouseRightButtonDown}
,	[Parameter()]
	[PSObject]${On_MouseRightButtonUp}
,	[Parameter()]
	[PSObject]${On_MouseUp}
,	[Parameter()]
	[PSObject]${On_MouseWheel}
,	[Parameter()]
	[Object[]]${Name}
,	[Parameter()]
	[Object[]]${Opacity}
,	[Parameter()]
	[Object[]]${OpacityMask}
,	[Parameter()]
	[Switch]${OverridesDefaultStyle}
,	[Parameter()]
	[PSObject]${On_PreviewDragEnter}
,	[Parameter()]
	[PSObject]${On_PreviewDragLeave}
,	[Parameter()]
	[PSObject]${On_PreviewDragOver}
,	[Parameter()]
	[PSObject]${On_PreviewDrop}
,	[Parameter()]
	[PSObject]${On_PreviewGiveFeedback}
,	[Parameter()]
	[PSObject]${On_PreviewGotKeyboardFocus}
,	[Parameter()]
	[PSObject]${On_PreviewKeyDown}
,	[Parameter()]
	[PSObject]${On_PreviewKeyUp}
,	[Parameter()]
	[PSObject]${On_PreviewLostKeyboardFocus}
,	[Parameter()]
	[PSObject]${On_PreviewMouseDown}
,	[Parameter()]
	[PSObject]${On_PreviewMouseLeftButtonDown}
,	[Parameter()]
	[PSObject]${On_PreviewMouseLeftButtonUp}
,	[Parameter()]
	[PSObject]${On_PreviewMouseMove}
,	[Parameter()]
	[PSObject]${On_PreviewMouseRightButtonDown}
,	[Parameter()]
	[PSObject]${On_PreviewMouseRightButtonUp}
,	[Parameter()]
	[PSObject]${On_PreviewMouseUp}
,	[Parameter()]
	[PSObject]${On_PreviewMouseWheel}
,	[Parameter()]
	[PSObject]${On_PreviewQueryContinueDrag}
,	[Parameter()]
	[PSObject]${On_PreviewStylusButtonDown}
,	[Parameter()]
	[PSObject]${On_PreviewStylusButtonUp}
,	[Parameter()]
	[PSObject]${On_PreviewStylusDown}
,	[Parameter()]
	[PSObject]${On_PreviewStylusInAirMove}
,	[Parameter()]
	[PSObject]${On_PreviewStylusInRange}
,	[Parameter()]
	[PSObject]${On_PreviewStylusMove}
,	[Parameter()]
	[PSObject]${On_PreviewStylusOutOfRange}
,	[Parameter()]
	[PSObject]${On_PreviewStylusSystemGesture}
,	[Parameter()]
	[PSObject]${On_PreviewStylusUp}
,	[Parameter()]
	[PSObject]${On_PreviewTextInput}
,	[Parameter()]
	[PSObject]${On_QueryContinueDrag}
,	[Parameter()]
	[PSObject]${On_QueryCursor}
,	[Parameter()]
	[Object[]]${RenderSize}
,	[Parameter()]
	[Object[]]${RenderTransform}
,	[Parameter()]
	[Object[]]${RenderTransformOrigin}
,	[Parameter()]
	[PSObject]${On_RequestBringIntoView}
,	[Parameter()]
	[Object[]]${Resources}
,	[Parameter(ValueFromPipelineByPropertyName=$true)]
   [Alias("Rows")]
	[Object[]]${RowDefinitions}
,	[Parameter()]
	[Switch]${ShowGridLines}
,	[Parameter()]
	[PSObject]${On_SizeChanged}
,	[Parameter()]
	[Switch]${SnapsToDevicePixels}
,	[Parameter()]
	[PSObject]${On_SourceUpdated}
,	[Parameter()]
	[Object[]]${Style}
,	[Parameter()]
	[PSObject]${On_StylusButtonDown}
,	[Parameter()]
	[PSObject]${On_StylusButtonUp}
,	[Parameter()]
	[PSObject]${On_StylusDown}
,	[Parameter()]
	[PSObject]${On_StylusEnter}
,	[Parameter()]
	[PSObject]${On_StylusInAirMove}
,	[Parameter()]
	[PSObject]${On_StylusInRange}
,	[Parameter()]
	[PSObject]${On_StylusLeave}
,	[Parameter()]
	[PSObject]${On_StylusMove}
,	[Parameter()]
	[PSObject]${On_StylusOutOfRange}
,	[Parameter()]
	[PSObject]${On_StylusSystemGesture}
,	[Parameter()]
	[PSObject]${On_StylusUp}
,	[Parameter()]
	[Object[]]${Tag}
,	[Parameter()]
	[PSObject]${On_TargetUpdated}
,	[Parameter()]
	[PSObject]${On_TextInput}
,	[Parameter()]
	[Object[]]${ToolTip}
,	[Parameter()]
	[PSObject]${On_ToolTipClosing}
,	[Parameter()]
	[PSObject]${On_ToolTipOpening}
,	[Parameter()]
	[Object[]]${Triggers}
,	[Parameter()]
	[Object[]]${Uid}
,	[Parameter()]
	[PSObject]${On_Unloaded}
,	[Parameter()]
	[Object[]]${VerticalAlignment}
,	[Parameter()]
	[Object[]]${Visibility}
,	[Parameter()]
	[Object[]]${Width}
,	[Parameter(ValueFromRemainingArguments=$true, Position=10000)]
	[string[]]$DependencyProps
)
BEGIN {
   $DObject = New-Object System.Windows.Controls.Grid
   $All = @('AllowDrop','Background','BindingGroup','BitmapEffect','BitmapEffectInput','Children','Clip','ClipToBounds','ColumnDefinitions','CommandBindings','ContextMenu','ContextMenuClosing','ContextMenuClosing__','ContextMenuOpening','ContextMenuOpening__','Cursor','DataContext','DataContextChanged','DataContextChanged__','DragEnter','DragEnter__','DragLeave','DragLeave__','DragOver','DragOver__','Drop','Drop__','Effect','FlowDirection','Focusable','FocusableChanged','FocusableChanged__','FocusVisualStyle','ForceCursor','GiveFeedback','GiveFeedback__','GotFocus','GotFocus__','GotKeyboardFocus','GotKeyboardFocus__','GotMouseCapture','GotMouseCapture__','GotStylusCapture','GotStylusCapture__','Height','HorizontalAlignment','Initialized','Initialized__','InputBindings','InputScope','IsEnabled','IsEnabledChanged','IsEnabledChanged__','IsHitTestVisible','IsHitTestVisibleChanged','IsHitTestVisibleChanged__','IsItemsHost','IsKeyboardFocusedChanged','IsKeyboardFocusedChanged__','IsKeyboardFocusWithinChanged','IsKeyboardFocusWithinChanged__','IsMouseCapturedChanged','IsMouseCapturedChanged__','IsMouseCaptureWithinChanged','IsMouseCaptureWithinChanged__','IsMouseDirectlyOverChanged','IsMouseDirectlyOverChanged__','IsStylusCapturedChanged','IsStylusCapturedChanged__','IsStylusCaptureWithinChanged','IsStylusCaptureWithinChanged__','IsStylusDirectlyOverChanged','IsStylusDirectlyOverChanged__','IsVisibleChanged','IsVisibleChanged__','KeyDown','KeyDown__','KeyUp','KeyUp__','Language','LayoutTransform','LayoutUpdated','LayoutUpdated__','Loaded','Loaded__','LostFocus','LostFocus__','LostKeyboardFocus','LostKeyboardFocus__','LostMouseCapture','LostMouseCapture__','LostStylusCapture','LostStylusCapture__','Margin','MaxHeight','MaxWidth','MinHeight','MinWidth','MouseDown','MouseDown__','MouseEnter','MouseEnter__','MouseLeave','MouseLeave__','MouseLeftButtonDown','MouseLeftButtonDown__','MouseLeftButtonUp','MouseLeftButtonUp__','MouseMove','MouseMove__','MouseRightButtonDown','MouseRightButtonDown__','MouseRightButtonUp','MouseRightButtonUp__','MouseUp','MouseUp__','MouseWheel','MouseWheel__','Name','Opacity','OpacityMask','OverridesDefaultStyle','PreviewDragEnter','PreviewDragEnter__','PreviewDragLeave','PreviewDragLeave__','PreviewDragOver','PreviewDragOver__','PreviewDrop','PreviewDrop__','PreviewGiveFeedback','PreviewGiveFeedback__','PreviewGotKeyboardFocus','PreviewGotKeyboardFocus__','PreviewKeyDown','PreviewKeyDown__','PreviewKeyUp','PreviewKeyUp__','PreviewLostKeyboardFocus','PreviewLostKeyboardFocus__','PreviewMouseDown','PreviewMouseDown__','PreviewMouseLeftButtonDown','PreviewMouseLeftButtonDown__','PreviewMouseLeftButtonUp','PreviewMouseLeftButtonUp__','PreviewMouseMove','PreviewMouseMove__','PreviewMouseRightButtonDown','PreviewMouseRightButtonDown__','PreviewMouseRightButtonUp','PreviewMouseRightButtonUp__','PreviewMouseUp','PreviewMouseUp__','PreviewMouseWheel','PreviewMouseWheel__','PreviewQueryContinueDrag','PreviewQueryContinueDrag__','PreviewStylusButtonDown','PreviewStylusButtonDown__','PreviewStylusButtonUp','PreviewStylusButtonUp__','PreviewStylusDown','PreviewStylusDown__','PreviewStylusInAirMove','PreviewStylusInAirMove__','PreviewStylusInRange','PreviewStylusInRange__','PreviewStylusMove','PreviewStylusMove__','PreviewStylusOutOfRange','PreviewStylusOutOfRange__','PreviewStylusSystemGesture','PreviewStylusSystemGesture__','PreviewStylusUp','PreviewStylusUp__','PreviewTextInput','PreviewTextInput__','QueryContinueDrag','QueryContinueDrag__','QueryCursor','QueryCursor__','RenderSize','RenderTransform','RenderTransformOrigin','RequestBringIntoView','RequestBringIntoView__','Resources','RowDefinitions','ShowGridLines','SizeChanged','SizeChanged__','SnapsToDevicePixels','SourceUpdated','SourceUpdated__','Style','StylusButtonDown','StylusButtonDown__','StylusButtonUp','StylusButtonUp__','StylusDown','StylusDown__','StylusEnter','StylusEnter__','StylusInAirMove','StylusInAirMove__','StylusInRange','StylusInRange__','StylusLeave','StylusLeave__','StylusMove','StylusMove__','StylusOutOfRange','StylusOutOfRange__','StylusSystemGesture','StylusSystemGesture__','StylusUp','StylusUp__','Tag','TargetUpdated','TargetUpdated__','TextInput','TextInput__','ToolTip','ToolTipClosing','ToolTipClosing__','ToolTipOpening','ToolTipOpening__','Triggers','Uid','Unloaded','Unloaded__','VerticalAlignment','Visibility','Width')
}
PROCESS {

## CUSTOMIZED
if($PsBoundParameters.Keys -contains "RowDefinitions") {
   $PSBoundParameters["RowDefinitions"] = $PSBoundParameters["RowDefinitions"] | Where-Object {$_} | ForEach-Object {
      if($_ -is [System.Windows.Controls.RowDefinition]) { 
         $_ 
      } elseif($_ -is [HashTable]) { 
         ForEach($row in $_.GetEnumerator()) {
            RowDefinition -Height $row.Value -Name $row.Key
         }
      } else {
         RowDefinition -Height $_
      }
   }
}
if($PsBoundParameters.Keys -contains "ColumnDefinitions") {
   $PSBoundParameters["ColumnDefinitions"] = $PSBoundParameters["ColumnDefinitions"] | Where-Object {$_} | ForEach-Object {
      if($_ -is [System.Windows.Controls.ColumnDefinition]) { 
         $_ 
      } elseif($_ -is [HashTable]) { 
         ForEach($col in $_.GetEnumerator()) {
            ColumnDefinition -Width $col.Value -Name $col.Key
         }
      } else {
         ColumnDefinition -Width $_
      }
   }
}

foreach($key in @($PSBoundParameters.Keys) | where { $PSBoundParameters[$_] -is [ScriptBlock] }) {
   $PSBoundParameters[$key] = $PSBoundParameters[$key].GetNewClosure()
}
Set-UIProperties @($PSBoundParameters.GetEnumerator() | Where { [Array]::BinarySearch($All,($_.Key -replace "^On_(.*)",'$1__')) -ge 0 } ) ([ref]$DObject)
} #Process
END {
   Microsoft.PowerShell.Utility\Write-Output $DObject
}
}
                                                                        
## New-System.Windows.Controls.Grid @PSBoundParameters
