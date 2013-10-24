function ConvertTo-ParameterMetaData {
    <#
    .Synopsis
        Turns reflection information on a type into parameter metadata
    .Description
        Turns reflection information on a type into parameter metadata.
        Parameter metadata can be used to rapidly generate functions.
        
        The script caches properties and events it has converted into
        parameters so that generation works more quickly as similar types
        are discovered.
    .Example
        [Windows.Window] | ConvertTo-ParameterMetaData
    #>
    [CmdletBinding()]
    param(
        # The Type that will be converted into parameter metadata
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [Type]$Type
    )
    
    begin {
        if (-not $script:CachedParameters) {
            $script:CachedParameters = @{}
        }
    }
    process {
        $params = @()
        $constructors = $type.GetConstructors() | Where { !$_.GetParameters() }
        if (-not $constructors)
        {
            Write-Warning "$($type.FullName) has no suitable constructor."
            return
        }
        foreach ($p in $type.GetProperties("Instance,Public")) {
            Write-Verbose "$($p.DeclaringType).$($p.Name)"

            switch ($p.PropertyType) {
                {$script:CachedParameters."$($p.DeclaringType).$($p.Name)"} {
                    $params+=($script:CachedParameters."$($p.DeclaringType).$($p.Name)")
                    break
                }
                {$_.GetInterface("IList")} {
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param
                    $params += $param                        
                    break
                }
                {($_ -eq [Double]) -and $p.CanWrite} {
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name, ([Double]) |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param
                    $params += $param
                    break                
                }                
                {($_ -eq [Int]) -and $p.CanWrite} {
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name, ([Int]) |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param
                    $params += $param
                    break                
                }                
                {($_ -eq [UInt32]) -and $p.CanWrite} {
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name, ([UInt32]) |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param
                    $params += $param
                    break                
                }                
                {($_ -eq [Boolean]) -and $p.CanWrite} {
                    # Turn Booleans into switch parameters
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name, ([switch]) |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param
                    $params += $param
                    break
                }
                {$_.IsSubclassOf([Enum]) -and $p.CanWrite} {
                    # Primitives or enums will be strongly typed
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name, $p.PropertyType |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $params += $param
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param    
                    break
                }
                
                {$p.CanWrite} {
                    Write-Verbose "But at least it's writable: $($p.DeclaringType).$($p.Name)"
                    $param = New-Object Management.Automation.ParameterMetaData $p.Name |
                        Add-Member NoteProperty PropertyType $_ -Passthru
                    $script:CachedParameters."$($p.DeclaringType).$($p.Name)" = $param 
                    $params += $param
                }
            }
        }
        foreach ($e in $type.GetEvents("Instance, Public")) {
            if ($script:CachedParameters."$($e.DeclaringType).On_$($e.Name)") {
                $params += $script:CachedParameters."$($e.DeclaringType).On_$($e.Name)" 
            } else {
                $p = New-Object Management.Automation.ParameterMetaData "On_$($e.Name)", ([ScriptBlock[]])
                $params += $p
                $script:CachedParameters."$($e.DeclaringType).On_$($e.Name)"  = $p
            }
        }
        $params
    }
}
