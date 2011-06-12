function Get-ParentControl
{
    param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
    [Alias('Tree')]
    [Windows.DependencyObject]
    $Control = $this
    )
    
    process {
        if (-not $Control) { return }         
        $parent = $control
        while ($parent) {
            if ($parent -is [Windows.Window]) { return $parent } 
            if ('ShowUI.ShowUISetting' -as [type]) {
                $controlName = $parent.GetValue([ShowUI.ShowUISetting]::ControlNameProperty)
                if ($controlName) { return $parent }
            }
            $newparent = [Windows.Media.VisualTreeHelper]::GetParent($parent)
            if (-not $newParent) { $parent } 
            $parent = $newParent
        }                    
    }
}
