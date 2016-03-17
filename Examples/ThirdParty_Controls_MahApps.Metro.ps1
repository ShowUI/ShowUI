# To fetch MahApps library and generate a ShowUI module for it
# You need only run something like this once:
$MahAppsDll = Import-NugetLibrary MahApps.Metro -Passthru
Import-Module ShowUI -min 2.0
Add-UIModule -Path $MahAppsDll -Name MahApps.Metro

# Now you can just import (or #require) the module:
Import-Module MahApps.Metro

Show-UI -Width 1024 {
    WrapPanel {
        foreach($image in Get-ChildItem "D:\SkyDrive\Shared Pictures\Wallpaper" -Filter *.jpg) {
            Tile -Title $_.Name -Width 126 -Background {
                ImageBrush -ImageSource $_.FullName
            }
        }
    }
} -Show