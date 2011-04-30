# New-UIGadget {
#.Synopsis
#   Create desktop widgets with no window chrom
#.Description
#   Provides a wrapper for generating widget windows with ShowUI. It adds two parameters to the usual Show-UI command: RefreshRate and On_Refresh.
#  
#   Widget windows are created with AllowsTransparency, Background = Transparent, and WindowStyle = None (among other things) and provide an automatic timer for updating the window contents, and support dragging with the mouse anywhere on the window.
#.Param Content
#   The ShowUI content of the widget
#.Param RefreshRate
#   The timespan to wait between refreshes, like "0:0:0.5" for 5 seconds
#.Param On_Refresh
#   The scriptblock to execute for each refresh.
[CmdletBinding(DefaultParameterSetName='DataTemplate')]
param (
   [Parameter(ParameterSetName='DataTemplate', Mandatory=$False, Position=0)]
   [ScriptBlock]
   ${Content},
   
   [Parameter(Mandatory=$True, Position=1)]
   [TimeSpan][Alias("Rate","Interval")]
   ${RefreshRate},
   
   [Parameter(Mandatory=$True, Position=2)]
   [ScriptBlock]
   ${On_Refresh},
  
   [Parameter(ParameterSetName='FileTemplate', Mandatory=$true, Position=0, HelpMessage='XAML template file')]
   [System.IO.FileInfo]
   ${FileTemplate},

   [Parameter(ParameterSetName='SourceTemplate', Mandatory=$true, Position=0, HelpMessage='XAML template XmlDocument')]
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
PROCESS {
   # We need to get rid of these before we pass this on
   $null = $PSBoundParameters.Remove("RefreshRate")
   $null = $PSBoundParameters.Remove("On_Refresh")

   $PSBoundParameters["AllowsTransparency"] = New-Object "Switch" $true
   $PSBoundParameters["Async"] = New-Object "Switch" $true
   $PSBoundParameters["WindowStyle"] = "None"
   $PSBoundParameters["ShowInTaskbar"] = $false
   $PSBoundParameters["IsTabStop"] = $false
   $PSBoundParameters["Background"] = "Transparent"
   $PSBoundParameters["On_MouseLeftButtonDown"] = { $this.DragMove() }
   $PSBoundParameters["On_Closing"] = { $this.Tag["Timer"].Stop() }
   $PSBoundParameters["Tag"] = @{"UpdateBlock"=$On_Refresh; "Interval"= $RefreshRate}
   $PSBoundParameters["On_SourceInitialized"] = {
                        $this.Tag["Temp"] = {
                           $this.Interval = [TimeSpan]$this.Tag.Tag.Interval
                           $this.Remove_Tick( $this.Tag.Tag.Temp ) 
                        }
                        $this.Tag["Timer"] = DispatcherTimer -Interval "0:0:02" -On_Tick $this.Tag.UpdateBlock -Tag $this
                        $this.Tag["Timer"].Add_Tick( $this.Tag.Temp )
                        $this.Tag["Timer"].Start()
                     }
   $PSBoundParameters["ResizeMode"] = "NoResize"
   $PSBoundParameters["Passthru"] = $True
   
   $Window = Show-UI @PSBoundParameters
   if($Window) { [Huddled.Dwm]::RemoveFromAeroPeek( $Window.Handle ) }
   if($Passthru) { Write-Output $Window }
}
BEGIN {
try { 
   $null = [Huddled.DWM]
} catch { 
Add-Type -Type @"
using System;
using System.Runtime.InteropServices;

namespace Huddled {
   public static class Dwm {
      [DllImport("dwmapi.dll", PreserveSig = false)]
      public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);

      [Flags]
      public enum DwmWindowAttribute
      {
         NCRenderingEnabled = 1,
         NCRenderingPolicy,
         TransitionsForceDisabled,
         AllowNCPaint,
         CaptionButtonBounds,
         NonClientRtlLayout,
         ForceIconicRepresentation,
         Flip3DPolicy,
         ExtendedFrameBounds,
         HasIconicBitmap,
         DisallowPeek,
         ExcludedFromPeek,
         Last
      }

      [Flags]
      public enum DwmNCRenderingPolicy
      {
         UseWindowStyle,
         Disabled,
         Enabled,
         Last
      }

      public static void RemoveFromAeroPeek(IntPtr Hwnd) //Hwnd is the handle to your window
      {
         int renderPolicy = (int)DwmNCRenderingPolicy.Enabled;
         DwmSetWindowAttribute(Hwnd, (int)DwmWindowAttribute.ExcludedFromPeek, ref renderPolicy, sizeof(int));
      }
   }
}
"@

[Reflection.Assembly]::Load("UIAutomationClient, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
}
}

# SIG # Begin signature block
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCr1BU8CQqEwjV1reYZncbj5h
# A+igggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQU82fOAEYC
# yK4wxNZroeV7bRfdnYYwDQYJKoZIhvcNAQEBBQAEggEAOnD3Qpk/sYu10hMTgQkF
# FRFExD7LHydoAA9VnUZujHWlIZsDSZIIiFQJ3Tn7Ah57/giA9H+NWOkm3NIug/S7
# OkMUUHxOdbyIJwFQVKjx3s2kWy90Eq8yR7HDnkERWOnuE4jmDPE9XkNp3GBMk/Te
# L4ia/VE3H0/4Jed22ubgiC5Qwq6aG/BjHwQYnGv6EVR/n8PZ6pMTwUV+fsfTv9NI
# KdZ5hmkYTVmDtZC1gjAgoLqKrmkG6LhoMU8fOs3ZNusd2mSx6yLvi32DGTHCCGvV
# NtMcmTx9MAE8snVolnW8lle9nuSaqNpY0PMdwaKODdPVBQhIrrmqpTCCM0GjekGF
# /Q==
# SIG # End signature block
