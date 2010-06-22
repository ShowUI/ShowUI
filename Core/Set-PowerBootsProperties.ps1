function Set-BootsProperty {
PARAM([ref]$TheObject, $Name, $Values)
   $DObject = $TheObject.Value
   if($DebugPreference -ne "SilentlyContinue") { Write-Host ([System.Windows.Markup.XamlWriter]::Save( $DObject )) -foreground DarkMagenta }
   if($DebugPreference -ne "SilentlyContinue") { Write-Host ([System.Windows.Markup.XamlWriter]::Save( @($Values)[0] )) -foreground DarkMagenta }

   $PropertyType = $DObject.GetType().GetProperty($Name).PropertyType
   if($PropertyType -eq [System.Windows.FrameworkElementFactory] -and $DObject -is [System.Windows.FrameworkTemplate]) {
      if($DebugPreference -ne "SilentlyContinue") { Write-Host "Loading a FrameworkElementFactory" -foreground Green}
      
      # [Xml]$Template = [PoshWpf.XamlHelper]::ConvertToXaml( $DObject )
      # [Xml]$Content = [PoshWpf.XamlHelper]::ConvertToXaml( (@($Values)[0]) )
      # In .Net 3.5 the recommended way to programmatically create a template is to load XAML from a string or a memory stream using the Load method of the XamlReader class.
      [Xml]$Template = [System.Windows.Markup.XamlWriter]::Save( $DObject )
      [Xml]$Content = [System.Windows.Markup.XamlWriter]::Save( (@($Values)[0]) )

      $Template.DocumentElement.PrependChild( $Template.ImportNode($Content.DocumentElement, $true) ) | Out-Null
     
      $TheObject.Value = [System.Windows.Markup.XamlReader]::Parse( $Template.get_OuterXml() )
   }
   elseif(@($Values)[0] -is [System.Windows.Data.Binding] -and !$PropertyType.IsAssignableFrom([System.Windows.Data.BindingBase])) {
      if($DebugPreference -ne "SilentlyContinue") { Write-Host "$($DObject.GetType())::$Name is $PropertyType and the value is a Binding: $Values" -fore Cyan}

      if($DependencyProperties.ContainsKey($Name)) {
         $field = @($DependencyProperties.$Name.Keys | Where { $DObject -is $_ -and $PropertyType -eq ([type]$DependencyProperties.$Name.$_.PropertyType)})[0] #  -or -like "*$Class" -and ($Param1.Value -as ([type]$_.PropertyType)
         if($field) { 
            if($DebugPreference -ne "SilentlyContinue") { Write-Host "$($field)" -fore Blue}
            if($DebugPreference -ne "SilentlyContinue") { Write-Host "Binding: ($field)::`"$($DependencyProperties.$Name.$field.Name)`" to $(@($Values)[0])" -fore Blue}
            
            # [System.Windows.Data.BindingOperations]::SetBinding( $DObject, ([type]$field.DeclaringType)::"$($field.Name)", @($Values)[0] ) | out-null
            
            $DObject.SetBinding( ([type]$field)::"$($DependencyProperties.$Name.$field.Name)", @($Values)[0] ) | Out-Null
         } else {
            throw "Couldn't figure out $( @($DependencyProperties.$Name.Keys) -join ', ' )"
         }
      }
   }
   elseif($PropertyType -ne [Object] -and $PropertyType.IsAssignableFrom( [System.Collections.IEnumerable] ) -and ($DObject.$($Name) -eq $null)) {
      if($Values -is [System.Collections.IEnumerable]) {
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "$Name is $PropertyType which is IEnumerable, and the value is too!" -fore Cyan }
         $DObject.$($Name) = $Values
      } else { 
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "$Name is $PropertyType which is IEnumerable, but the value is not." -fore Cyan }
         $DObject.$($Name) = new-object "System.Collections.ObjectModel.ObservableCollection[$(@($Values)[0].GetType().FullName)]"
         $DObject.$($Name).Add($Values)
      }
   }
   elseif($DObject.$($Name) -is [System.Collections.IList]) {
      foreach ($value in @($Values)) {
         try {
            $null = $DObject.$($Name).Add($value)
         }
         catch
         {
            # Write-Host "CAUGHT array problem" -fore Red
            if($_.Exception.Message -match "Invalid cast from 'System.String' to 'System.Windows.UIElement'.") {
               $null = $DObject.$($Name).Add( (New-System.Windows.Controls.TextBlock $value) )
            } else { 
               Write-Error $_.Exception
            throw
            }
         }
      }
   }
   else {
      ## If they pass an array of 1 when we only want one, we just use the first value
      if($Values -is [System.Collections.IList] -and $Values.Count -eq 1) {
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "Value is an IList ($($Values.GetType().FullName))" -fore Cyan}
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "But we'll just use the first ($($Values[0].GetType().FullName))" -fore Cyan}
         
         if($DebugPreference -ne "SilentlyContinue") { Write-Host ([System.Windows.Markup.XamlWriter]::Save( $Values[0] )) -foreground White}
         try {
            $DObject.$($Name) = $Values[0]
         }
         catch [Exception]
         {
            # Write-Host "CAUGHT collection value problem" -fore Red
            if($_.Exception.Message -match "Invalid cast from 'System.String' to 'System.Windows.UIElement'.") {
               $null = $DObject.$($Name).Add( (TextBlock $Values[0]) )
            }else { 
               throw
            }
         }
      }
      else ## If they pass an array when we only want one, we try to use it, and failing that, cast it to strings
      {
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "Value is just $Values" -fore Cyan}
         try {
            $DObject.$($Name) = $Values
         } catch [Exception]
         {
            # Write-Host "CAUGHT value problem" -fore Red
            if($_.Exception.Message -match "Invalid cast from 'System.String' to 'System.Windows.UIElement'.") {
               $null = $DObject.$($Name).Add( (TextBlock $values) )
            }else { 
               throw
            }
         }
      }
   }
}


function Set-PowerBootsProperties {
[CmdletBinding()]
param( $Parameters, [ref]$DObject )

   if($DebugPreference -ne "SilentlyContinue") { Write-Host; Write-Host ">>>> $($Dobject.Value.GetType().FullName)" -fore Black -back White }
   foreach ($param in $Parameters) {
      if($DebugPreference -ne "SilentlyContinue") { Write-Host "Processing Param: $($param|Out-String)" }
      ## INGORE DEPENDENCY PROPERTIES FOR NOW :)
      if($param.Key -eq "DependencyProps") {
      ## HANDLE EVENTS ....
      }
      elseif ($param.Key.StartsWith("On_")) {
         $EventName = $param.Key.SubString(3)
         if($DebugPreference -ne "SilentlyContinue") { Write-Host "Event handler $($param.Key) Type: $(@($param.Value)[0].GetType().FullName)" }
         $sb = $param.Value -as [ScriptBlock]
         if(!$sb) {
            $sb = (Get-Command $param.Value -CommandType Function,ExternalScript).ScriptBlock
         }
         $Dobject.Value."Add_$EventName".Invoke( $sb );
         # $Dobject.Value."Add_$EventName".Invoke( ($sb.GetNewClosure()) );
         
         # $Dobject.Value."Add_$EventName".Invoke( $PSCmdlet.MyInvocation.MyCommand.Module.NewBoundScriptBlock( $sb.GetNewClosure() ) );
         
         
      } ## HANDLE PROPERTIES ....
      else { 
         try {
            ## TODO: File a BUG because Write-DEBUG and Write-VERBOSE die here.
            if($DebugPreference -ne "SilentlyContinue") {
               Write-Host "Setting $($param.Key) of $($Dobject.Value.GetType().Name) to $($param.Value.GetType().FullName): $($param.Value)" -fore Gray
            }
            if(@(foreach($sb in $param.Value) { $sb -is [ScriptBlock] }) -contains $true) {
               $Values = @()
               $bMod = Get-BootsModule
               foreach($sb in $param.Value) {
                  $Values += & $bMod $sb
               }
            } else {
               $Values = $param.Value
            }

            if($DebugPreference -ne "SilentlyContinue") { Write-Host ([System.Windows.Markup.XamlWriter]::Save( @($Values)[0] )) -foreground green }
            
            Set-BootsProperty $Dobject $Param.Key $Values

            if($DebugPreference -ne "SilentlyContinue") { Write-Host ([System.Windows.Markup.XamlWriter]::Save( $Dobject.Value )) -foreground magenta }
      
            if($DebugPreference -ne "SilentlyContinue") {
               if( $Dobject.Value.$($param.Key) -ne $null ) {
                  Write-Host $Dobject.Value.$($param.Key).GetType().FullName -fore Green
               }
            }
         }
         catch [Exception]
         {
            Write-Host "COUGHT AN EXCEPTION" -fore Red
            Write-Host $_ -fore Red
            Write-Host $this -fore DarkRed
         }
      }

      while($DependencyProps) {
         $name, $value, $DependencyProps = $DependencyProps
         $name = ([string]@($name)[0]).Trim("-")
         if($name -and $value) {
            Set-DependencyProperty -Element $Dobject.Value -Property $name -Value $Value
         }
      }
   }
   if($DebugPreference -ne "SilentlyContinue") { Write-Host "<<<< $($Dobject.Value.GetType().FullName)" -fore Black -back White; Write-Host }
}
# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUzkWO67nXbLv99yR6+76oW1Jd
# cEyggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBTFmNljCO1E
# 7Jqaum3ZJeLMz/wiMDANBgkqhkiG9w0BAQEFAASCAQCR/AY6/PrvXXcUrB+5j0Mi
# 9voPnPVELuWsg/JI3JeNcARkANSs6meRqqNfxSnYIDv5pVlp3aNtfRXN+PcK/L4X
# qDZbDAcbFI70SrXeEg1Rn0zmN1u2ArvAHBpJvFZvwSQU1GPkn169DuVyKB2cRqOI
# sdlOOw1Q0w204syedh1cdPInRINauy6OVGydLBpDbySjlQ+Ad8K4jgWwi0MNtPVw
# 7WQ9oWKPG/IFnIDwSOqapJfTHK1hDBtkZSiCFp1m0I8/oCnLnfM7d14Lm0wb+G6V
# uJnaVahiisEFWgDzAGaJCMm6X0y0DtG9dBC2SZYbABGOknHcT6b3z17eui2GzTPO
# SIG # End signature block
