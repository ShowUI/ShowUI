#requires -version 2.0
### Import the WPF assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore

## Select-Grid
##   Displays objects in a grid view and returns (only) the selected ones when closed.
########################################################################################################################
## Usage:
##   ls | Select-Grid Name, Length, Mode, LastWriteTime
##   ps | Select-Grid ProcessName, Id, VM, WS, PM, Product, Path
##   Select-Grid Name, Length, Mode, LastWriteTime -Input (ls)
##  
## Take advantage of the graphing:
##   ls | Select-Grid Name, Length, LastWriteTime, Mode -Title $pwd -Sort Length -Graph Length
##   ps | Select-Grid ProcessName, Id, VM, WS, PM -Title Processes -Graph WS -Sort WS
## Kill the selected processes:
##   ps | Select-Grid ProcessName, Id, VM, WS, PM, Product, Path -Title "Processes" -Sort WS -Graph VM, WS, PM | kill
########################################################################################################################
## History:
## v4.0 - Rewrite for PowerShell 2.0 (March 15, 2010)
## v3.2 - Fixed a bug with duplicate columns
##     -- (re)fixed the column order to preserve the command-line order (if specified)
##     -- Changed default sort order to descending (when you click a new column, the big values are on top)
## v3.1 - Fixed a bug with not passing the graph parameter
## v3.0 - Added CellTemplate for graphing (first release to PowerShellCentral.com/scripts)
## v2.5 - Added Multi-select and made it output the selected items
## v2.3 - Added Title and made columns dragable
## v2.2 - Fixed pipeline problems
## v2.1 - Added "Get-Default" to populate blank rows
## v2.0 - Added clickable headers and sorting 
##     -- broken on columns with blanks?
## v1.0 - Basic grid with data-binding 
##     -- broken on pipeline
########################################################################################################################
Function Select-Grid {
   Param (
      [Parameter(Position=0)][string[]]$Properties,
      [Parameter(Position=1)][string[]]$Title,
      [Parameter(Position=2)][string[]]$Sort,
      [Parameter(Position=3)][string[]]$Graph,
      [Parameter(Mandatory=$true, ValueFromPipeline=$true)] $InputObjects
   )
   BEGIN {   
      if ($PSBoundParameters.ContainsKey("InputObjects")) {
         $outputObjects = @(,$InputObjects)
      } else {
         $outputObjects = @()
      }      
   }
   PROCESS {
      ### Collect together all input objects
      $outputObjects += $InputObjects
   }
   END {
      ### Create our window and listview
      $window = New-Object System.Windows.Window
      $window.SizeToContent = "WidthAndHeight"
      $window.SnapsToDevicePixels = $true
      $window.Content = New-Object System.Windows.Controls.ListView
      if($Title) {
         $window.Title = $Title
      } else { 
         $window.Title = $outputObjects[-1].GetType().Name
      }
      ### The ListView takes ViewBase object which controls the layout and appearance
      ### We'll use a GridView
      $window.Content.View = New-Object System.Windows.Controls.GridView
      $window.Content.View.AllowsColumnReorder = $true

      $columns = Get-PropertyTypes $outputObjects ([ref]$Properties)
      
      ### Make columns (use Properties instead of Columns.Keys to preserve order)
      foreach($Name in $Properties) {
         ### Try to ensure that every object has _some_ value for each column (so sorting works)
         $outputObjects | add-member -Type NoteProperty -Name $Name -value (Get-DefaultValue($columns[$name])) -ea SilentlyContinue

         ## For each property, make a column         
         $gvc = New-Object System.Windows.Controls.GridViewColumn
         ## And bind the data ... 
         $gvc.DisplayMemberBinding = New-Object System.Windows.Data.Binding $Name
         ## In order to add sorting, we need to create the header ourselves
         $gvc.Header = New-Object System.Windows.Controls.GridViewColumnHeader
         $gvc.Header.Content = $Name
   
         ## Add a click handler to enable sorting ...
         $gvc.Header.add_click({
            $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $outputObjects )
            $sd = new-object System.ComponentModel.SortDescription $this.Content, $(
               if($view.SortDescriptions[0].PropertyName -eq $this.Content)  {
                  switch($view.SortDescriptions[0].Direction) {
                     "Ascending"  { "Descending" } "Descending" { "Ascending"  }
                  } } else { "Descending" } )
            $view.SortDescriptions.Clear()
            $view.SortDescriptions.Add($sd)
            # if($view.SortDescriptions.Count -gt 2) { $view.SortDescriptions.RemoveAt(2) }
            $view.Refresh()
         } )
         # Format-Column-Conditionally $obj, $Name, $gvc
         ## Use that column in the view
         $window.Content.View.Columns.Insert($window.Content.View.Columns.Count,$gvc)
      }

      $Graph = @($Graph | Where-Object { $Properties -contains $_ })
      if( $Graph.Count -gt 0 ) { 
         Format-ColumnPercent $outputObjects $window.Content.View $Graph
      }
      
      ## Databind the argument
      $window.Content.ItemsSource = $outputObjects
      
      ## Add an initial sort ...
      $sd = new-object System.ComponentModel.SortDescription
      $sd.PropertyName = &{ if($Sort) { $Sort }else{ $Properties[0] } }
      $sd.Direction = "Descending"
      [System.Windows.Data.CollectionViewSource]::GetDefaultView( $outputObjects ).SortDescriptions.Add($sd)

      ## Show the window
      $Null = $window.ShowDialog()
      $window.Content.SelectedItems
   }
}

## return a hash of property names and maximum values for each
function Get-Max {
Param($collection,$properties)
   $max = @{}
   $collection | Measure-Object $properties -Max | ForEach-Object { $max[$($_.Property)] = $($_.Maximum)}
   return $max
}

## a quick and easy function to create default-value instances of any type
function Get-DefaultValue {
Param([type]$type)
   if( $type -and $type.IsValueType) { 
      [Activator]::CreateInstance($type)
   } else { 
      $null 
   }
}

## Determine which properties are actually present in the objects and what type they are
function Get-PropertyTypes {
Param($outputObjects, [ref]$Properties)
   ### Collect the columns we're going to use 
   $columns = @{}
   
   ### if we have a list, use all the items on the list that are defined
   ### but take great pains to preserve the OriginalOrder
   if($Properties.Value) {
      $Properties.Value = $outputObjects | 
                           get-member $Properties.Value | 
                           add-member ScriptProperty OriginalOrder {[array]::indexof($Properties.Value,$this.Name)} -passthru | 
                           Sort OriginalOrder -unique | 
                           ForEach-Object { $_.Name }
   } else {
      ### if we don't have a list, make one, from all the items...
      $Properties.Value = $outputObjects | Get-Member -type Properties | Sort Name -Unique | ForEach-Object { $_.Name }
   }
   ### Figure out the types
   ## I'm going to be testing properties by accessing them instead of using get-member
   Set-StrictMode -Version 1 
   ForEach($Name in $Properties.Value) {
      $columns[$name] = $Null
      ForEach($obj in $outputObjects) {
         if( $obj.($Name) ) {
            $columns[$name] = $obj.($Name).GetType()
            break
         }
      }
   }
   Set-StrictMode -Version Latest
   return $columns
}

#############################################################
## Conditionally format the columns for a GridView ...
## Currently only adds a Cell Template for the specified columns
## Note: the $properties should only contain the names of numerical properties!
function Format-ColumnPercent {
Param( $outputObjects, $gridview,  $properties)
   # Calculate the max values 
   $max = Get-Max $outputObjects $properties
   # And finally, set the CellTemplate on those columns...
   foreach($property in $properties) {
      # And then calculate the percentages, based on that...
      # $outputObjects.Value | Add-Member ScriptProperty "$($property)Percent" {(`$this.${property} -as [int]) / $($max.($property))}
      # $outputObjects | Add-Member ScriptProperty "$($property)Percent" $executioncontext.InvokeCommand.NewScriptBlock(
                                                                       # "(`$this.$($property) -as [double]) / $($max.($property))")
      foreach($obj in $outputObjects) {
         Add-Member NoteProperty "$($property)Percent" (($($obj.$($property)) -as [double]) / $($max.($property))) -input $obj
      }

      $column = @($gridview.Columns | ? { $_.Header.Content -eq $property })[0];
      ## dump the binding and use a template instead... (this shouldn't be necessary)...
      $column.DisplayMemberBinding = $null
      $column.CellTemplate = `
      [Windows.Markup.XamlReader]::Load( 
         (New-Object System.Xml.XmlNodeReader (
         [Xml]"<DataTemplate xmlns='http://schemas.microsoft.com/winfx/2006/xaml/presentation'>
                  <Grid>
                     <Rectangle Margin='-6,0' VerticalAlignment='Stretch' RenderTransformOrigin='0,1' >
                        <Rectangle.Fill>
                           <LinearGradientBrush StartPoint='0,0' EndPoint='1,0'>
                              <GradientStop Color='#FFFF4500' Offset='0' />
                              <GradientStop Color='#FFFF8585' Offset='1' />
                           </LinearGradientBrush>
                        </Rectangle.Fill>
               			<Rectangle.RenderTransform>
                           <ScaleTransform ScaleX='{Binding $($property)Percent}' ScaleY='1' />
                   		</Rectangle.RenderTransform>              
                     </Rectangle>              
                     <TextBlock Width='100' Margin='-6,0' TextAlignment='Right' Text='{Binding $property}' />
                  </Grid>
               </DataTemplate>")))
   }
}

# SIG # Begin signature block
# MIIRDAYJKoZIhvcNAQcCoIIQ/TCCEPkCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7K/GaWosRkguZreyopgvBO/E
# Hxmggg5CMIIHBjCCBO6gAwIBAgIBFTANBgkqhkiG9w0BAQUFADB9MQswCQYDVQQG
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
# AQQBgjcCAQsxDjAMBgorBgEEAYI3AgEWMCMGCSqGSIb3DQEJBDEWBBQG3ibFBvNB
# hTwe0x8qiSMVZB5HrTANBgkqhkiG9w0BAQEFAASCAQBLxL/iyyFN36ACjnRvzpKA
# P/19LO6LfC5JGkRGqRMxiDCk7P1Y08+AAR9mc/+C22/JCadrdXakRbkxA2B+UEwm
# HlpjMQuchQ9eNckeAN5FJxj6OjiCtTT07uDRgbKNmO5Nd4KkQTkU09FlNjISnmey
# PJfi/jFQQtn4RdgFiFuMqwei/C3Q/N6r4pKsOLvPk6MpiogxezvfpzItSA+lc62d
# STRFiK4OxMWr+oWL9Lq2hYVPVcO+c1M6WhFdqO5AiyQqEHxyqe9bsrYQ06VXdC8/
# mggnx2jZmOBb9sAlEZL4FHS5ypSFmVMxRXoUWpk3nZV+5W+rt9CXbWU0CWNjqTLT
# SIG # End signature block
