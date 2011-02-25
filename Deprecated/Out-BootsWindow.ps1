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
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU5uv0mcUkJBiRwMUAylrZeyjX
# iLKgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUytaahlsA
# QXtXu3bBSlepjx2z/SIwDQYJKoZIhvcNAQEBBQAEggEAPRl1lc1E7ryOaqNvJD/7
# njo4EnjvDXmjWCWX8E8TqkaB2Fvs5cWIFXHD7Sj2FDyZcZjPtGbmHE2XQm3PRdv5
# j/30OVq4pno709N9x+8rlfN9xjbNn5BcFw2GlXd9534WZlblTVRXklTpez2TTZ+t
# S8whDYexJiZKxI5n8lFosqA/Uh50eKIA546O0bWIh6ZJktAhkCCmaraaTzFFTUFg
# AWYzwZoJBHWWnayPooJFMd8k27T5UqOIagg04sB0YWUmW8hM5kJ6ZojFkdTFJETr
# DxGYY2vKy85NVzDrIivPWmJyVM1hN7wrLeOzxCvyIh9AsC7iGiW1tzuZuFCsyToI
# hA==
# SIG # End signature block
