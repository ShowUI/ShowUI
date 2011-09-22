function Remove-ChildControl
{
    <#
    .Synopsis
        Removes a Child from a parent control
    .Description
        Disconnects a child control from a parent control.
    .Parameter Control
        The control to remove
    .Parameter Parent
        The container the control is currently in.
    #>
    param(
    [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
    [Windows.UIElement]$Control,

    [Parameter(Position=0, Mandatory=$true)]
    [Windows.Controls.Panel]$Parent    
    )
    
    process {
        if ($control.Parent -eq $parent) {
            $null = $parent.Children.Remove($control)
        }
    }
}
