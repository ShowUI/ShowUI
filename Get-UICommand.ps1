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
        $Syntax,

        # If set, recurse aliases to find an actual command
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [Switch]
        $Recurse
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
        $null = $psBoundParameters.Remove("Syntax")
        do {
            $command = Get-Command @psBoundParameters | Where-Object $filter
            if($Recurse -and $Command -is [System.Management.Automation.AliasInfo]) {
                $psBoundParameters.Name = $Name = $Command.Definition
            }
        } while($Recurse -and $Command -is [System.Management.Automation.AliasInfo])

        if ($Syntax) {
            $Command | Get-Command -Syntax
        } else {
            $Command
        }
    }
}
