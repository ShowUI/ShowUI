## The OLD display function
function Out-BootsWindow {
<#
.Synopsis
   Show Boots content in a window using ShowDialog()
.Description
   Will show a Visual Element in a simple WPF Window.  Out-Boots uses ShowDialog() so it is not Async -- execution will not continue until the window is closed.  

   If you need to return anything, you need to just set the $BootsOutput variable from within an event handler.
.Parameter Content
   The content that you want to display in a Wpf Window. 
.Parameter SizeToContent
   Controls the automatic resizing of the window to fit the contents, defaults to "WidthAndHeight"
.Parameter Title
      The Window Title.  Defaults to "Boots"
.Example
   "You need to know this" | Out-Boots
   
   The simplest possible way to do a popup dialog with some text on it.
.Example
   Button -Content "I can count!" -on_click {$BootsOutput += $BootsOutput.Count + 1} | Boots 
 
   Will output a series of numbers for the number of times you click the button. Notice that the output only happens AFTER the window is closed.
.Link
   http://HuddledMasses.org/powerboots-tutorial-walkthrough
.ReturnValue
   The value of the $BootsOutput (which, by default is an array).
.Notes
 AUTHOR:    Joel Bennett http://HuddledMasses.org
 LASTEDIT:  2009-01-07 11:35:23
#>
[CmdletBinding(DefaultParameterSetName='Default')]
PARAM(
	[Parameter(ParameterSetName='Default')]
	[Switch]$AllowDrop
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$AllowsTransparency
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Background
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$BindingGroup
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$BitmapEffect
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$BitmapEffectInput
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$BorderBrush
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$BorderThickness
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Clip
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$ClipToBounds
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$CommandBindings
,
	[Parameter(ParameterSetName='Default',Position=1,ValueFromPipeline=$true, Mandatory=$true)]
	[ScriptBlock]$Content
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ContentStringFormat
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ContentTemplate
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ContentTemplateSelector
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ContextMenu
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Cursor
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$DataContext
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$DialogResult
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Effect
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FlowDirection
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$Focusable
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FocusVisualStyle
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FontFamily
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FontSize
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FontStretch
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FontStyle
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$FontWeight
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$ForceCursor
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Foreground
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Height
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$HorizontalAlignment
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$HorizontalContentAlignment
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Icon
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$InputBindings
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$InputScope
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$IsEnabled
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$IsHitTestVisible
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$IsTabStop
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Language
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$LayoutTransform
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Left
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Margin
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$MaxHeight
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$MaxWidth
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$MinHeight
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$MinWidth
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Name
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Opacity
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$OpacityMask
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$OverridesDefaultStyle
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Owner
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Padding
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$RenderSize
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$RenderTransform
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$RenderTransformOrigin
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ResizeMode
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Resources
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$ShowActivated
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$ShowInTaskbar
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$SizeToContent
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$SnapsToDevicePixels
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Style
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$TabIndex
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Tag
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Template
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Title
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$ToolTip
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Top
,
	[Parameter(ParameterSetName='Default')]
	[Switch]$Topmost
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Triggers
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Uid
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$VerticalAlignment
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$VerticalContentAlignment
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Visibility
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$Width
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$WindowStartupLocation
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$WindowState
,
	[Parameter(ParameterSetName='Default')]
	[Object[]]$WindowStyle
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_SourceInitialized
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Activated
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Deactivated
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StateChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LocationChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Closing
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Closed
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_ContentRendered
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseDoubleClick
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseDoubleClick
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_TargetUpdated
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_SourceUpdated
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_DataContextChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_RequestBringIntoView
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_SizeChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Initialized
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Loaded
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Unloaded
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_ToolTipOpening
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_ToolTipClosing
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_ContextMenuOpening
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_ContextMenuClosing
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseLeftButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseLeftButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseLeftButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseLeftButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseRightButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseRightButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseRightButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseRightButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewMouseWheel
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseWheel
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseEnter
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_MouseLeave
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_GotMouseCapture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LostMouseCapture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_QueryCursor
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusInAirMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusInAirMove
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusEnter
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusLeave
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusInRange
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusInRange
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusOutOfRange
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusOutOfRange
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusSystemGesture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusSystemGesture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_GotStylusCapture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LostStylusCapture
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_StylusButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusButtonDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewStylusButtonUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewKeyDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_KeyDown
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewKeyUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_KeyUp
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewGotKeyboardFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_GotKeyboardFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewLostKeyboardFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LostKeyboardFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewTextInput
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_TextInput
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewQueryContinueDrag
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_QueryContinueDrag
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewGiveFeedback
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_GiveFeedback
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewDragEnter
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_DragEnter
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewDragOver
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_DragOver
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewDragLeave
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_DragLeave
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_PreviewDrop
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_Drop
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsMouseDirectlyOverChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsKeyboardFocusWithinChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsMouseCapturedChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsMouseCaptureWithinChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsStylusDirectlyOverChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsStylusCapturedChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsStylusCaptureWithinChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsKeyboardFocusedChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LayoutUpdated
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_GotFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_LostFocus
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsEnabledChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsHitTestVisibleChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_IsVisibleChanged
,
	[Parameter(ParameterSetName='Default')]
	[ScriptBlock]$On_FocusableChanged
,
	[Parameter(ValueFromRemainingArguments=$true)]
	[string[]]$DependencyProps
)

BEGIN {
   [Object[]]$Global:BootsOutput = @()
   ## Default value for SizeToContent 
   if(!$PSBoundParameters.ContainsKey("SizeToContent")) {
      if(!$PSBoundParameters.ContainsKey("Width") -and !$PSBoundParameters.ContainsKey("Height")) {
         $PSBoundParameters.Add("SizeToContent", "WidthAndHeight")
      } elseif($PSBoundParameters.ContainsKey("Width") -and !$PSBoundParameters.ContainsKey("Height")) { 
         $PSBoundParameters.Add("SizeToContent", "Height")
      } elseif(!$PSBoundParameters.ContainsKey("Width") -and $PSBoundParameters.ContainsKey("Height")) { 
         $PSBoundParameters.Add("SizeToContent", "Width")
      }
   }
   ## Default value for SizeToContent 
   if(!$PSBoundParameters.ContainsKey("Title")) {
      $PSBoundParameters.Add("Title", "Boots")
   }   
}
PROCESS {
   if( $PSBoundParameters.Content -is [System.Windows.Window] ) {
      $Global:BootsWindow = $PSBoundParameters.Content
   } 
   else
   {
      if($PSBoundParameters.Content -is [ScriptBlock]) 
      {
         Write-Host "PowerBoots"
         $bMod = Get-BootsModule
         $PSBoundParameters.Content = & $bMod $PSBoundParameters.Content
      }
      $Global:BootsWindow = Window @PSBoundParameters
   }
   $null = $Global:BootsWindow.ShowDialog()
   return $Global:BootsOutput
}   
}

# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5uv0mcUkJBiRwMUAylrZeyjX
# iLKggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBTK1pqGWwBB
# e1e7dsFKV6mPHbP9IjANBgkqhkiG9w0BAQEFAASCAQBWsVJagW53gQv/UYI1NY4r
# OLCS00L9CMU6aiKuO0rM2MjH5NUmb5WtQTPlGmMfT/NyM0BT9kYmhqjR9P4nWM7n
# bNX1cAh5Vc0tcg09NlPIZr3PiUkQ1fE1xgR3WPxPd7RbkyWxbAStW7rklV6duEYm
# 0xmhAWNer1LvOo8PN8Z48NtupecBs8ZsDos/daSqqHpQJm4X7gjUrY2wjpRuym5O
# 1UvNRPYQUs5gEZKuJnIIUFplqNs0hwO/SSQVCh0gBaaOgU8XH59kGUoSBoVg4xO2
# 94KdMIJpS+9ShraueT8OHvl/sdxNpKNUK3iOJszn/zapCXmN9td7Onwmxu/NDVfg
# SIG # End signature block
