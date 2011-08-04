## Works in OldBoots\ShowUI
Show { 
    ListView -ItemsSource {ls "$Env:Public\Pictures" -r} -ItemTemplate {
        DataTemplate {
            Image -Width 200 -Source {Binding -Path FullName}
        }
    }
}

## I want this to work, because (as a WPF developer?) I find it intuitive:
ListView -ItemsSource {ls "$Env:Public\Pictures" -r} -ItemTemplate {
    Image -Width 200 -Source {Binding -Path FullName}
} -Show

## This works in ShowUI:
ListView -ItemsSource {ls "$Env:Public\Pictures" -r} -ItemTemplate {
    Image -Name Image -Width 200 |
        ConvertTo-DataTemplate -Binding @{ 'Image.Source'='FullName' }
} -Show


Notice two differences: 
1) I have to call ConvertTo-DataTemplate
2) I have to specify the binding on the convert call

My proposed solution:
1) Add a parameterset to ConvertTo-DataTemplate which takes a ScriptBlock 
2) Set an alias "DataTemplate" for it
3) Add a CodeGeneration rule for FrameworkTemplate parameters to automatically call it if the input is not already a template



$Binding = New-Object System.Windows.Data.Binding -Property @{ Path = "FullName" }
$Image = New-Object System.Windows.Controls.Image
$Image.SetBinding( $Image.GetType()::"SourceProperty", $Binding ) | Out-Null
$Image | % { [System.Windows.Markup.XamlWriter]::Save($_) }

<Image Source="{Binding Path=FullName}" xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" />

[Attribute[]]$tca = New-Object System.ComponentModel.TypeConverterAttribute([PoshWpf.Converters.BindingConverter])
[System.ComponentModel.TypeDescriptor]::AddAttributes( [System.Windows.Data.BindingExpression], $tca )
[Attribute[]]$tca = New-Object System.ComponentModel.TypeConverterAttribute([PoshWpf.Converters.BindingTypeDescriptionProvider])
[System.ComponentModel.TypeDescriptor]::AddAttributes( [System.Windows.Data.Binding], $tca )



Add-Type -path C:\Users\Joel\Projects\PoshConsole\PoshWpf\bin\AnyCPU\Release\PoshWpf.dll
$k = New-Object PoshWpf.Hooker
$k.Invoke()
