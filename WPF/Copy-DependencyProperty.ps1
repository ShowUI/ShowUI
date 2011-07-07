function Copy-DependencyProperty
{
    <#
    .Synopsis
        Copies dependency properties from one object to another.
    .Description
        Reads the dependency properties from one object and writes 
        them to another.  If a particular property could not be set,
        then the error encountered while trying to set the propery will
        be in the debug stream.
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Windows.DependencyObject]$from,
    [Parameter(Position=0)]
    [Windows.DependencyObject[]]$to,  
    [Parameter(Position=1)]
    [string[]]
    $property = "*"         
    )
    
    process {
        if (-not $from) { return } 
        $from.GetLocalValueEnumerator() | Where-Object {
            foreach ($p in $property) {
                if ($_.Property.Name -like $p) {
                    return $true
                }
            }
        } | ForEach-Object {
            foreach ($t in $to) {
                if (-not $t) { continue } 
                try {
                    $t.SetValue($_.Property, $_.Value)
                }
                catch {
                    if ($debugPreference -eq "continue") {
                        Write-Debug ($_ | Out-String)
                    }
                }
            }
        }
    }
}
