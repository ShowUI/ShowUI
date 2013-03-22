function Get-ParentControl
{
    param(
    [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
    [Alias('Tree')]
    $Control = $this
    )
    
    process {
        if (-not $Control) { return }         
        $parent = $control
        while ($parent) {
            if ($parent -is [Windows.Window]) { return $parent } 
            if ('ShowUI.ShowUISetting' -as [type]) {
                $controlName = try {
                    $parent.GetValue([ShowUI.ShowUISetting]::ControlNameProperty)
                } catch {
                    Write-Debug $_
                }
                if ($controlName) { return $parent }
            }
            $newparent = try {
                [Windows.Media.VisualTreeHelper]::GetParent($parent)
            } catch {
                Write-Debug $_
            } 
            if (-not $newParent) { $parent } 
            $parent = $newParent
        }                    
    }
}
