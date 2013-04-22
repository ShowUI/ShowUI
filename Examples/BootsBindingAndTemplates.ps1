## I want this to work, because (as a WPF developer?) I find it intuitive:
## And now it works (at least in .Net4), from ShowUI 1.5 (assuming you have a few jpegs in your public pictures)
ListView -ItemsSource {ls "$Env:Public\Pictures"} -ItemTemplate {
    # I no longer have to explicitly call -DataBinding (but there may be edge cases)
    Image -Width 200 -Source {Binding -Path FullName}
} -Show

## This worked in ShowUI 1.3 and onward:
ListView -ItemsSource {ls "$Env:Public\Pictures"} -ItemTemplate {
    # I no longer have to call ConvertTo-DataTemplate on things which are being set to Template properties
    Image -Name Image -Width 200 -DataBinding @{Source = Binding -Path FullName }
} -Show

## This worked in ShowUI 1.2 and onward:
ListView -ItemsSource {ls "$Env:Public\Pictures"} -ItemTemplate {
    Image -Name Image -Width 200 |
        ConvertTo-DataTemplate -Binding @{ 'Image.Source'='FullName' }
} -Show

# ## Works in OldBoots\ShowUI
# Show { 
#     ListView -ItemsSource {ls "$Env:Public\Pictures"} -ItemTemplate {
#         DataTemplate {
#             Image -Width 200 -Source {Binding -Path FullName}
#         }
#     }
# }