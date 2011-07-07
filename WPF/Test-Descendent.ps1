function Test-Descendent {
    param(
    [Parameter(Mandatory=$true)]
    [Windows.UIElement]
    $control,
    
    [Parameter(Mandatory=$true)]
    [Windows.UIElement]
    $otherControl
    )
    
    $control.IsDescendentOf($otherControl)
}
