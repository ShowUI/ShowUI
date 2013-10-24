## New in ShowUI 1.5
New-ListBox -ItemsSource { Get-Process } -ItemTemplate {
    New-StackPanel -Orientation Horizontal -Children {
        New-Label -Name ProcessName -FontSize 14 -Content {Binding ProcessName}
        New-Label -Name Id -FontSize 8 -Content {Binding Id}
    } | ConvertTo-DataTemplate
} -show


New-ListBox -ItemsSource { Get-Process } -ItemTemplate {
    New-StackPanel -Orientation Horizontal -Children {
        New-Label -Name ProcessName -FontSize 14 
        New-Label -Name Id -FontSize 8
    } | ConvertTo-DataTemplate -binding @{
        "ProcessName.Content" = "ProcessName"
        "Id.Content" = "Id"
    }    
} -show


