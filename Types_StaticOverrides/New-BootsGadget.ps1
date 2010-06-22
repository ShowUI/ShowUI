# New-BootsGadget {
#.Synopsis
#   Create desktop widgets with no window chrom
#.Description
#   Provides a wrapper for generating widget windows with PowerBoots. It adds two parameters to the usual New-PowerBoots command: RefreshRate and On_Refresh.
#  
#   Widget windows are created with AllowsTransparency, Background = Transparent, and WindowStyle = None (among other things) and provide an automatic timer for updating the window contents, and support dragging with the mouse anywhere on the window.
#.Param Content
#   The PowerBoots content of the widget
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
   
   $Window = New-BootsWindow @PSBoundParameters
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
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUCr1BU8CQqEwjV1reYZncbj5h
# A+iggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBTzZ84ARgLI
# rjDE1muh5XttF92dhjANBgkqhkiG9w0BAQEFAASCAQA70riAGdMgxTPr4HMqvBt6
# ubhj+iO9kFdzikEktlTuMzYy7JQn4h4UUUeriKTumpicqYPELU1WeIPwVLvs9KX4
# 6PB13SjVWEOXqqs0ZCgNJOBPeKUF6UV3Z5j9IapazlQj0gqprRexveSTlP3xF8XS
# tiZpqjUnRqDTSsVZV/MAIr0ulMxgdL7wYAQs89Nn61uKy97U8Z63XXTKnF67UbaS
# 7L6npt5VkfXAQ0PI085AgmUgMp2Vn0wjF0xWx7uoabo4FEzb9DwXetTmy6MZ2HTp
# whRBsCghO1YzYrSuGvUlk1uuB4/Jndd8/CZIo7gR2kE+69naDJSz0FqNFeAaDt3y
# SIG # End signature block