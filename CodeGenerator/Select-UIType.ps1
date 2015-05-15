function Select-UIType {
#.Synopsis
#   Selects Types that are likely UI Elements or other types needed with ShowUI
[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [string[]]
    $Path,        
    
    [Parameter()]
    [Alias('AN')]
    [string[]]
    $AssemblyName,    
    
    [Parameter()]
    [Type[]]
    $Type,

    [Parameter()]
    [String[]]
    $TypeNameWhiteList,

    [Parameter()]
    [String[]]
    $TypeNameBlackList,

    [Parameter()]
    [String[]]
    $NamespaceBlackList
)
begin {
    $TypeNameWhiteList = $TypeNameWhiteList + @(
        'System.Windows.Input.ApplicationCommands',
        'System.Windows.Input.ComponentCommands',
        'System.Windows.Input.NavigationCommands',
        'System.Windows.Input.MediaCommands',
        'System.Windows.Documents.EditingCommands',
        'System.Windows.Input.CommandBinding',
        'System.Windows.ResourceDictionary',
        'Windows.Threading.DispatcherTimer' ) | Select -Unique

    $TypeNameBlackList = $TypeNameBlackList + @(
        'System.Windows.Threading.DispatcherFrame', 
        'System.Windows.DispatcherObject',
        'System.Windows.Interop.DocObjHost',
        'System.Windows.Ink.GestureRecognizer',
        'System.Windows.Data.XmlNamespaceMappingCollection',
        'System.Windows.Annotations.ContentLocator',
        'System.Windows.Annotations.ContentLocatorGroup',
        'System.Windows.UIElement',
        'System.Windows.FrameworkElement',
        'System.Windows.FrameworkContentElement',
        'System.Windows.DependencyObject',
        'System.Windows.Threading.DispatcherSynchronizationContext',
        'System.Windows.Application' ) | Select -Unique

    $NamespaceBlackList = $NamespaceBlackList + @(
        "System.Xaml",
        "System.Windows.Media.Imaging",
        "System.Windows.Media.Media3D",
        "System.Windows.Documents.DocumentStructures",
        "System.Windows.Automation.Peers" ) | Select -Unique

}
process {
    if(!(Test-Path Variable:Type) -or ($Type -eq $null)) {
        $Type = New-Object Type[] 0
    }
    if ($Path) 
    {
        foreach($p in $path) {
            Write-Verbose "$($ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($p))"
            $asm = [Reflection.Assembly]::LoadFrom($ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($p))
            if ($asm) {
                $Type += $asm.GetTypes()
            }
        }
    } 
    if ($AssemblyName) {
        foreach($a in $AssemblyName) {
            try {
                $asm = [Reflection.Assembly]::Load($a)
                if ($asm) {
                    $Type += $asm.GetTypes()
                }
            } catch {
                $err = $_
                try {
                    $asm = [Reflection.Assembly]::LoadWithPartialName($a)
                    if ($asm) {
                        $Type += $asm.GetTypes()
                    }
                } catch {
                    Write-Error $err
                    Write-Error $_
                }
            }
        }
    }
}
end {
    $Type | Where-Object {
        $TypeNameWhiteList -contains $_.FullName -or
        (
            $_.IsPublic -and 
            (-not $_.IsGenericType) -and 
            (-not $_.IsAbstract) -and
            (-not $_.IsEnum) -and
            ($_.FullName -notlike "*Internal*") -and
            ($_.FullName -notlike '*KeyFrame') -and
            ($_.FullName -notlike '*Presenter') -and
            (-not $_.IsSubclassOf([EventArgs])) -and
            (-not $_.IsSubclassOf([Exception])) -and
            (-not $_.IsSubclassOf([Attribute])) -and
            (-not $_.IsSubclassOf([Windows.Markup.ValueSerializer])) -and
            (-not $_.IsSubclassOf([MulticastDelegate])) -and
            (-not $_.IsSubclassOf([ComponentModel.TypeConverter])) -and
            (-not $_.GetInterface([Collections.ICollection])) -and
            (-not $_.IsSubClassOf([Windows.SetterBase])) -and
            (-not $_.IsSubclassOf([Security.CodeAccessPermission])) -and
            (-not $_.IsSubclassOf([Windows.Media.ImageSource])) -and
            (-not $_.IsSubclassOf([Windows.TemplateKey])) -and
            (-not $_.IsSubclassOf([Windows.Media.Imaging.BitmapEncoder])) -and
            (-not $_.IsSubclassOf([Windows.Controls.DefinitionBase])) -and
            (-not $_.IsSubclassOf([Windows.Controls.ValidationRule])) -and 
            (-not $_.IsSubclassOf([Windows.UIPropertyMetadata])) -and 
            ($_.BaseType -ne [Object]) -and
            ($_.BaseType -ne [ValueType]) -and
            ($NamespaceBlackList -notcontains $_.Namespace) -and
            ($TypeNameBlackList -notcontains $_.FullName)
        )
    }
}
}
