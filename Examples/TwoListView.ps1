StackPanel -Orientation Horizontal -DataContext { 
   Get-ChildItem | Sort-Object Extension | Group-Object Extension 
} -Children {
   ListBox -Width 75 -MinHeight 300 -DataBinding @{ ItemsSource = New-Binding -Path "." } -DisplayMemberPath Name -IsSynchronizedWithCurrentItem:$true
   ListBox -MinWidth 350 -DataBinding @{ ItemsSource = New-Binding -Path "CurrentItem.Group" }
} -Show
