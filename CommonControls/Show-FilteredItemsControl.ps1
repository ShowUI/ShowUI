function Show-FilteredItemsControl {
#.Synopsis
#  Wrap a ListView in a filtering control
#.Example
#  Show-FilteredItemsControl {
#  >> Get-ChildItem | Show-GridView -Property Mode, Length, LastWriteTime, Name
#  >> } ?Show
param (
   # The ItemsControl you want to filter.
   [Parameter(Position=0)]
   [PSObject]$ItemsControl,
   # True to put the filter box on the top (otherwise it's
   # placed below the collection control)
   [Switch]$FilterOnBottom,
#### ShowUI Common Parameters ##############################
   [string]$Name, [Int]$Row, [Int]$Column, [Int]$RowSpan,
   [Int]$ColumnSpan, [Int]$Width, [Int]$Height, 
   [Double]$Top, [Double]$Left, 
   [Windows.Controls.Dock]$Dock,
   [Switch]$Show, [Switch]$AsJob, [Switch]$OutputXaml

)
# Clean up a copy of the PSBoundParameters 
$Parameters = @{} + $PSBoundParameters
# We might add all the ListView parameters later, so we
# need to remove anything that's not a ListView parameter
$null = $Parameters.Remove('ItemsControl')
$null = $Parameters.Remove('FilterOnBottom')

# Create a StackPanel
$Stack = New-StackPanel -Name Panel

# Add the CollectionView if they want that on the top
if($FilterOnBottom) {
   Set-WpfProperty -InputObject $Stack -Property @{
      Children = $ItemsControl
   }
}

# Add the filter control(s)
Set-WpfProperty -InputObject $Stack -Property @{
   Children = { New-Grid -Columns *,Auto -Name SearchBox {
      ## Create a Filter Function 
      $Filter = {
         $Text = $SearchText.Text
         # This filter works on any ItemsControl
         # As long as the CollectionView supports filtering
         $ItemsCtrl = foreach($child in $Panel.Children) {
            if($child -is [System.Windows.Controls.ItemsControl]) {
               $child 
            } elseif($child.Content -and $child.Content -is [System.Windows.Controls.ItemsControl]) {
               $child.Content
            } elseif($child.Child -and $child.Child -is [System.Windows.Controls.ItemsControl]) {
               $child.Child
            }
         }
   
         # We'll use the CollectionView filter feature
         $t = [System.Windows.Data.CollectionViewSource]
         if($ItemsCtrl.ItemsSource) {
            $View = $t::GetDefaultView( $ItemsCtrl.ItemsSource )
         } else {
            $View = $t::GetDefaultView( $ItemsCtrl.Items )
         }
   
         # Set the filter (depending on the checkbox)
         if($RegEx.IsChecked) {
            $View.Filter = [Predicate[Object]]{ 
               param($item)
               trap { return $true } 
               "$item" -match $Text
            }
         } else {
            $View.Filter = [Predicate[Object]]{ 
               param($item)
               trap { return $true } 
               "$item" -match [RegEx]::Escape( $Text )
            }
         }
      }

      # Create the textbox for typing filter text
      New-TextBox -Margin 5 -Name SearchText -On_Loaded {
         $this.Focus()
      } -On_TextChanged $Filter
      # And the checkbox to enable regex
      New-CheckBox _RegEx -Column 1 -Margin "0,7,5,5" `
         -Name RegEx -On_Checked $Filter `
         -On_UnChecked $Filter
   }}
}

# Add the CollectionView if they want that on the bottom
if(!$FilterOnBottom) {
   Set-WpfProperty -InputObject $Stack -Property @{
      Children = $ItemsControl
   }
}

# In order to make sure we get the right output, we need to 
# update the UIValue every time the list is filtered, and 
# every time the selection is changed ...
New-Border -Child $Stack -ControlName FilteredList -On_Loaded {
   $tCVS,$tNCC = [System.Windows.Data.CollectionViewSource],
   [System.Collections.Specialized.INotifyCollectionChanged]
   $ItemsCtrl = foreach($child in $Panel.Children) {
      if($child -is [System.Windows.Controls.ItemsControl]) {
         $child -as $child.GetType()
      } elseif($child.Content -and $child.Content -is [System.Windows.Controls.ItemsControl]) {
         $child.Content -as $child.Content.GetType()
      } elseif($child.Child -and $child.Child -is [System.Windows.Controls.ItemsControl]) {
         $child.Child -as $child.Child.GetType()
      }
   }

   # We'll use the CollectionView filter feature
   $t = [System.Windows.Data.CollectionViewSource]
   if($ItemsCtrl.ItemsSource) {
      $View = $t::GetDefaultView( $ItemsCtrl.ItemsSource )
   } else {
      $View = $t::GetDefaultView( $ItemsCtrl.Items )
   }

   # Create the event handler which alters the output
   $UpdateOutput = {
      Set-UIValue -UI $FilteredList -Value $(
         # If there's nothing selected
         if($ItemsCtrl.SelectedItems.Count -eq 0) {
            # Output all the items
            $ItemsCtrl.Items
         } else {
            # Otherwise output the selected items
            $ItemsCtrl.SelectedItems
         } 
      )
   }

   # Hook up the events
   Add-EventHandler -Input $View -SourceType $tNCC `
         -EventName CollectionChanged $UpdateOutput
   Add-EventHandler -Input $ItemsCtrl `
         -EventName SelectionChanged $UpdateOutput

} @Parameters
}
