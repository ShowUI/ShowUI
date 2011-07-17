function Import-UIStyle
{
    [CmdletBinding(DefaultParameterSetName='EasyName')]
    param(
    [Parameter(ParameterSetName='FileName',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Alias('Fullname')]
    [string]
    $FileName,
    
    [Parameter(ParameterSetName='EasyName',
        Position=0,
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [string]
    $Name
    )
    
    process {
        if ($psCmdlet.ParameterSetName -eq 'FileName') {
            try {
                $imported = Import-Clixml $FileName
                if ($imported.psobject.typenames[0] -ne 'Deserialized.System.Collections.Hashtable') {
                    throw 'Corrupted style file'
                }
                $script:uiStyles = @{} + $imported
            } catch {
                $_ | Write-Error
            } 
        } elseif ($psCmdlet.ParameterSetName -eq 'EasyName') {
            $found = $false
            foreach ($style in (Get-ChildItem -Filter *.style -Path $psScriptRoot\Styles)) {
                if ($Name -eq $style.Name.Replace(".style","")) {
                    Import-UIStyle -FileName $style.Fullname -ErrorVariable failed
                    $found = $failed.Count -eq 0
                }
            }
            if (-not $found) {
                Write-Error "No Style named $Name found"
            }
        }                               
    }
}

Set-Alias Use-UiStyle Import-UIStyle
