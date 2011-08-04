function Get-Resource
{
    <#
    .Synopsis
        Finds a Resource in a visual control or the controls parents
    .Description
        Retrieves a resource stored in the Resources property of a UIElement.
        If the UIElement does not contain the resource, the parent will be checked.
        If no more parents exist, then nothing will be returned.
    .Parameter Visual
        The UI element to start looking for resources.
    .Parameter Name
        The name of the resource to find
    .Example
        New-Grid -Rows '1*', 'Auto' {
            New-ListBox -On_Loaded {
                Set-Resource "List" $this -1
            }
            New-Button -Row 1 "_Add" -On_Click {
                $list = Get-Resource "List"
                $list.ItemsSource += @(Get-Random)
            } 
        } -Show
    #>
    param(
    [String]
    $Name,
    
    $Visual = $this
    )
    
    process {
        if ($name) {
            $item = $Visual
            while ($item) {
                foreach ($k in $item.Resources.Keys) {
                    if ($k -ieq $Name) {
                        return $item.Resources.$k
                    }
                }
                $item = [Windows.Media.VisualTreeHelper]::GetParent($item)
            }
        } else {
            $outputObject = @{}
            $item = $Visual
            while ($item) {
                foreach ($k in $item.Resources.Keys) {
                    if (-not $k) { continue }
                    if (-not $outputObject.$k) { $outputObject.$k = $item.Resources.$k }
                }
                $item = [Windows.Media.VisualTreeHelper]::GetParent($item)
            }
            $outputObject
        }
    }
}
