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
# MIIIDQYJKoZIhvcNAQcCoIIH/jCCB/oCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU7K/GaWosRkguZreyopgvBO/E
# HxmgggUrMIIFJzCCBA+gAwIBAgIQKQm90jYWUDdv7EgFkuELajANBgkqhkiG9w0B
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
# BgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUBt4mxQbz
# QYU8HtMfKokjFWQeR60wDQYJKoZIhvcNAQEBBQAEggEAh/f0daV0m8axoJPD+C/c
# oY+1RwiMX9h36ZlaT5luSSxVH39SIjsiNKZdQDgTLI3oDoRkG0FN/rOjfdLKxDXP
# TNFaOh5g3HUhriGu4WQhNjQ7wX1Liv1bi2t/i+JCaaP3daSDlD6/+aTdKQwkMANR
# GnysUSgC62WAJan1ZnIflOF9c+g2Q5QGi0ftBy4etmf0qsz8o5zpubNpTWDDlAgM
# 914O80DTQKZapBEh0zaIiJ0YxOREQcgBdutfrlgmu1tcZu0ZpGboT54Z2loUQS8e
# ZwK80K+bYc6IwMCLVe1o4kSiIVsqd6c21L5D7N1vU/0JeBHf4m3YIW6YeaHCaTkV
# DA==
# SIG # End signature block
