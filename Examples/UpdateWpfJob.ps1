New-ListView -Name People -ItemsSource {
   ## Please excuse the ridiculous PowerShell syntax for constructing generic collections with its casting
   New-Object System.Collections.ObjectModel.ObservableCollection[PSObject](,([PSObject[]](&{
      New-Object PSObject -Prop @{ Name="Laerte";  City="Marilia"; Age=41}
      New-Object PSObject -Prop @{ Name="Joao";    City="Tupa";    Age=35}
      New-Object PSObject -Prop @{ Name="Maria";  City="Marilia";  Age=32}
   })))
} -View {
   New-GridView -Columns {
      New-GridViewColumn -Header Name -DisplayMember { Binding Name }
      New-GridViewColumn -Header City -DisplayMember { Binding City }
      New-GridViewColumn -Header Age -DisplayMember { Binding Age }
   }
} -AsJob

## Adding existing items is easy, we just need to get that ObservableCollection first
Get-Job People | Update-WPFJob { 
   ## Note: When you have an ItemsSource, you can't use .Items.Add anymore!
   $Window.Content.ItemsSource.Add(( New-Object PSobject -Prop @{ Name="Joel"; City="Rochester"; Age=37} ))
}

## Important: ObservableCollection ignores INotifyPropertyChanged, so 
## if you change existing items, you have to remember to refresh the view
Get-Job People | Update-WPFJob {
   $Window.Content.ItemsSource | Where { $_.Name -eq "Laerte" } | %{ $_.Age = 36 }
   
   ## Magic incantation to refresh a view (we should probably stick this somewhere in ShowUI)
   [System.Windows.Data.CollectionViewSource]::GetDefaultView( $Window.Content.ItemsSource ).Refresh()
}

## If you want to set styles on stuff, then you need to get the ListViewItem, not the actual item:
Get-Job People | Update-WPFJob {
   foreach($item in $Window.Content.ItemsSource) { 
      # Don't trust anyone over 35
      if($item.Age -gt 35) {
         $ViewItem = $Window.Content.ItemContainerGenerator.ContainerFromItem( $item )
         $ViewItem.Background = "Pink"
      }
   }
}

## If you want to set styles on stuff, then you need to get the ListViewItem, not the actual item:
$View = Get-Job People | Update-WPFJob {
   foreach($item in $Window.Content.ItemsSource) { 
      # Don't trust anyone over 35
      if($item.Age -gt 35) {
         $Window.Content.ItemContainerGenerator.ContainerFromItem( $item ).Template
      }
   }
}
