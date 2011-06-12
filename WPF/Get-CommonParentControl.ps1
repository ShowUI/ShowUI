function Get-CommonParentControl {
    <#
    .Synopsis
        Gets the common parent control between two controls
    .Description
        Given two controls, Get-CommonParentControl will determine
        what the common parent control is.    
    #>
    param(
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Windows.UIElement]
    $control,
    
    [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Windows.UIElement]
    $otherControl
    )
    
    process {
        $control.FindCommonVisualAncestor($otherControl)
    }    
}
