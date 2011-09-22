function Test-Ancestor {
    param(
    [Parameter(Mandatory=$true)]
    [Windows.UIElement]
    $control,
    
    [Parameter(Mandatory=$true)]
    [Windows.UIElement]
    $otherControl
    )
    
    $control.IsAncestorOf($otherControl)
}
