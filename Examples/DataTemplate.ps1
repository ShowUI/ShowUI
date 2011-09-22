New-ListBox -ItemsSource { Get-Process } -ItemTemplate {
    New-StackPanel -Orientation Horizontal -Children {
        New-Label -Name ProcessName -FontSize 14 
        New-Label -Name Id -FontSize 8
    } | ConvertTo-DataTemplate -binding @{
        "ProcessName.Content" = "ProcessName"
        "Id.Content" = "Id"
    }    
} -show
