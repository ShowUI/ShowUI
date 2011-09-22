function Get-UICommand {
    
    [CmdletBinding(DefaultParameterSetName='CmdletSet')]
    param(
        
    [Parameter(ParameterSetName='AllCommandSet', 
        Position=0, 
        ValueFromPipeline=$true, 
        ValueFromPipelineByPropertyName=$true)]
    [ValidateNotNullOrEmpty()]
    [System.String[]]
    $Name,

    [Parameter(ParameterSetName='CmdletSet', ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $Verb,

    [Parameter(ParameterSetName='CmdletSet', ValueFromPipelineByPropertyName=$true)]
    [System.String[]]
    $Noun,

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Alias('PSSnapin')]
    [System.String[]]
    $Module,

    [Parameter(ParameterSetName='AllCommandSet', ValueFromPipelineByPropertyName=$true)]
    [Alias('Type')]
    [System.Management.Automation.CommandTypes]
    $CommandType,

    [Parameter(ValueFromPipelineByPropertyName=$true)]
    [Switch]
    $Syntax
    )
    
    begin {
        $filter = { 
            $_.OutputType | 
                Where-Object { 
                    $_.Type -and
                    $_.Type.IsSubClassOf([Windows.Media.Visual])
                }
        }
    }
    process {
        if (-not $Syntax) {
            Get-Command @psBoundParameters |
                Where-Object $filter
        } else {
            $null = $psBoundParameters.Remove("Syntax")
            Get-Command @psBoundParameters |
                Where-Object $filter |
                ForEach-Object {
                    Get-Command -Name $_.Name -Syntax
                }
                
        }
        
    }
}
