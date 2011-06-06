function Get-ControlPosition {
    <#
    .Synopsis
        Gets the screen position of the control
    .Description
        Retrieves the position of one or more UI Elements relative to another UI Element.  
        By default, the position is relative to the Window
    .Example
        New-Canvas -Width 600 -Height 600 {
            New-Button "Click me" `
                -ToolTip "Click me to see where I am relative to the window"  `
                -FontSize 40 `
                -left (Get-Random -Maximum 500) `
                -top (Get-Random -Maximum 500) `
                -On_Click {
                    $this | 
                        Get-ControlPosition | 
                        Out-GridView
                    } 
                
        } -show
    .Parameter control
        The UI Element whose position is being retrieved
    .Parameter relativeTo
        The UI Element the position is relative to, by default, this is $window
    .Parameter pointInControl
        The point within the control to get the position of.
        By default, this is the upper left corner of the UI Element
    #>
    param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [Windows.UIElement]
    $control,
    
    [Parameter()]
    [Windows.UIElement]
    $relativeTo = $window,
    
    [Windows.Point]
    $pointInControl = (New-Object Windows.Point)
    )
    
    process {
        if (-not $PointInControl) { $PointInControl = New-Object Windows.Point } 
        $control.TranslatePoint($pointInControl, $relativeTo)
    }
}
