function Get-DependencyProperty {
    <#
    .Synopsis
        Gets the Dependency Properties that have been set on a control
    .Description
        Gets the Dependency Properties that have been set on a control.
    .Example
        New-Label "Hello World" -Row 1 | Get-DependencyProperty
    #>
    param(
    [Parameter(Mandatory=$true, 
        ValueFromPipeline=$true)]
    [Windows.UIElement]
    $control)
    
    process {
        foreach ($_ in $control.GetLocalValueEnumerator()) {
            $_
        }
    }
}
