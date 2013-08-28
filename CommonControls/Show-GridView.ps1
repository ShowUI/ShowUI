function Show-GridView {
#.Synopsis
#  Creates a ListView with a GridView
#.Example
#  Get-ChildItem | 
#     Show-GridView -Property Mode, Length, Name -Show
#
#  Description
#  -----------
#  Creates a GridView of Files with the specified properties 
param(
   # The data to be displayed in the GridView
   [Parameter(ValueFromPipeline=$true)]
   $InputObject,
   # The columns desired for the GridVew can be specified 
   # in one of three ways: as an array of property names,
   # as an unordered hashtable of display names to property 
   # names (or binding paths), or as a scriptblock which 
   # contains only assignments of property names (or binding
   # paths) to display names.
   [Parameter(Position=0, Mandatory=$true)]
   $Property,
#### ShowUI Common Parameters ##############################
   # The name of the control
   [string]$Name,
   # If the control is a child element of a Grid control 
   # (see New-Grid), then the Row parameter determines
   # which row the top of this control is in. The -Row 
   # parameter sets the [Windows.Controls.Grid]::RowProperty 
   # dependency property
   [Int]$Row,
   # If the control is a child element of a Grid control 
   # (see New-Grid) then the Column parameter determines
   # which column the left of this control is in.
   # The Column parameter sets the 
   # [Windows.Controls.Grid]::ColumnProperty dependency
   # property
   [Int]$Column,
   # If the control is a child element of a Grid control 
   # (see New-Grid) then the RowSpan parameter determines 
   # how many rows of the grid will be occupied by this
   # control. The RowSpan parameter sets the 
   # [Windows.Controls.Grid]::RowSpanProperty dependency 
   # property 
   [Int]$RowSpan,
   # If the control is a child element of a Grid control 
   # (see New-Grid) then the RowSpan parameter will be used 
   # to determine how many columns in the grid the control 
   # will occupy. The ColumnSpan parameter sets 
   # the [Windows.Controls.Grid]::ColumnSpanProperty
   # dependency property 
   [Int]$ColumnSpan,
   # The -Width parameter sets the width of the control
   [Int]$Width, 
   # The -Height parameter sets the height of the control
   [Int]$Height,
   # If the control is a child element of a Canvas control 
   # (see New-Canvas), the Top parameter controls the Y 
   # coordinate position of the top-left corner of the 
   # control within the canvas. The Top parameter sets the 
   # [Windows.Controls.Canvas]::TopProperty dependency 
   # property 
   [Double]$Top,
   # If the control is a child element of a Canvas control 
   # (see New-Canvas), the Left parameter controls the X
   # coordinate position of the top-left corner of the 
   # control within the canvas. The -Left parameter sets the
   # [Windows.Controls.Canvas]::LeftProperty dependency
   # property
   [Double]$Left,
   # If the control is a child element of a Dock control 
   # (see New-Dock), the Dock parameter controls the dock 
   # style within that panel. The Dock parameter sets the
   # [Windows.Controls.DockPanel]::DockProperty dependency 
   # property
   [Windows.Controls.Dock]$Dock,
   # If Show is set, then the UI will be displayed as a 
   # modal dialog within the current thread.  If the Show 
   # and AsJob parameters are omitted, then the control will
   # be output from the function as an object.
   [Switch]$Show,
   # If AsJob is set, then the UI will displayed using a 
   # WpfJob, creating a new runspace and thread. If the Show 
   # and AsJob parameters are omitted, then the control will
   # be output from the function as an object.
   [Switch]$AsJob,
   # If OutputXaml is set, the command will output the 
   # object as XAML rather than returning the actual object.
   [Switch]$OutputXaml
)
begin {
   # Make a copy of PSBoundParameters to pass to our control
   $Parameters = @{} + $PSBoundParameters
   # Remove parameters that aren't valid for ListView
   $null = $Parameters.Remove('InputObject')
   $null = $Parameters.Remove('Property')
   # Create an ObservableCollection for data binding
   $Items = New-Object `
      Collections.ObjectModel.ObservableCollection[PSObject]
}
process {
   # Add the input object(s) to the ObservableCollection
   foreach($item in @($InputObject)){
      $Items.Add( $item )
   }
}
end {
   # Create a ListView, passing on the PSBoundParameters
   # But specify a GridView View and the ItemsSource
   New-Border @Parameters -ControlName GridView {
      New-ListView -DataContext $Items -View {
         New-GridView -Columns {
            # Then we need to process the $Property into headers:
            if($Property -is [Hashtable]) {
               # Property is a hashtable of Label = Property
               foreach($col in $Property.GetEnumerator()) {
                  New-GridViewColumn -Header $col.Key -DisplayMember { 
                     New-Binding $col.Value 
                  }
               }
            } elseif( $Property -is [Array] ) {
               # We need to turn the $Property array into headers:
               foreach($col in $Property) {
                  # Put spaces in there to pretty it up
                  $header = $col -csplit "(?<=[^ ])(?=[A-Z][a-z])"
                  $header = ($header -join " ").Trim()
                  # Create a column with a header
                  New-GridViewColumn -Header $header -DisplayMember { 
                     New-Binding $col
                  }
               }
            } elseif( $Property -is [ScriptBlock] ) {
               # Property is a scriptblock with assignments
               # like: $DisplayName = "PropertyBinding"
               # Or: ${Display Name} = "PropertyName"
               $ignore = "Newline","StatementSeparator","Operator"
               $e = $null
               $tokens = [PSParser]::Tokenize($Property, [ref]$e) | 
                  Where-Object { $ignore -notcontains $_.Type }
               # We're very optimistic here ...
               while($Label,$Property,$tokens = $tokens) {
                  New-GridViewColumn -Header $Label.Content `
                                 -DisplayMember { 
                     New-Binding $Property.Content
                  }
               }
            }      
         }
      } -On_Loaded {
         # Sort CollectionView when a column header is clicked
         # http://msdn.microsoft.com/en-us/library/ms745786
         Add-EventHandler -Input $this -EventName Click `
                          -SourceType GridViewColumnHeader {
            $Source = $_.OriginalSource
            if($Source -and $Source.Role -ne "Padding") {
               # Use variables for types (because of line wrapping)
               $tCVS = [System.Windows.Data.CollectionViewSource]
               $tSD = "System.ComponentModel.SortDescription"

               # We need to sort by a PROPERTY of the objects 
               # so just use the path that we used for binding!
               $Prop = $Source.Column.DisplayMemberBinding.Path.Path
               
               # Change the sort direction each time they sort
               $Desc = if($Prop -ne $last){ $true } else { !$Desc }      
               $Dir = if($Desc) { "Descending" } else { "Ascending" }
               $last = $Prop

               # Get the view and the filter
               $view = $tCVS::GetDefaultView($this.ItemsSource)
               $filter = $view.Filter

               # And now we actually apply the sort to the View
               $view.SortDescriptions.Clear()
               try { 
                  $view.SortDescriptions.Add((New-Object $tSD $Prop,$Dir))
               } catch {
                  # Handle errors in WPF sorting by using PowerShell sorting!
                  # Reassign the ItemsSource after sorting the data
                  $this.DataContext = $this.DataContext | 
                     Sort-Object $Prop -Descending:$Desc
                  # Put the filter back 
                  # otherwise we'll be sorted but not filtered
                  $view = $tCVS::GetDefaultView($this.ItemsSource)
                  $view.Filter = $filter
               }
            }
         }

         # Set-UIValue so our control has output!
         Set-UIValue -UI $GridView -value $this.Items
      # We'll re-set it whenever the Selection changes
      } -On_SelectionChanged {
         # If there's nothing selected
         if($this.SelectedItems.Count -eq 0) {
            # Output all the items
            Set-UIValue -UI $GridView -Value $this.Items
         } else {
            # Otherwise output the selected items
            Set-UIValue -UI $GridView -value $this.SelectedItems
         } 
      } -DataBinding @{ ItemsSource = "." } # -ItemsSource { Binding -Path "." } 
   }
}
}
