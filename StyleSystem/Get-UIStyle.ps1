function Get-UIStyle {
    <#
    .Synopsis
        Get-UIStyle
    .Description

    .Example

    #>
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
    [Parameter(ParameterSetName='Name',Mandatory=$true,Position=0)]
    [string]
    $Name = "default"
    )
    
    process {
        if ($pscmdlet.ParameterSetName -eq 'Name') {
            if ($uiStyles.$Name) {
                # Return a copy of the style, not the exact style
                # this way little changes the next function makes to the hashtable won't
                # change the overall style
                return (@{} + $uiStyles.$name)
            }
        } elseif ($pscmdlet.ParameterSetName -eq 'All') {
        }

    }    
}
