function Get-AssemblyName {
    param(
        $RequiredAssemblies,
        [Type[]]$Types,
        [String[]]$ExcludedAssemblies
    )
    $Assemblies = @($Types | Select-Object -ExpandProperty Assembly -Unique)
    $ReferencedAssemblies = @(foreach($Asm in $Assemblies){ $asm.GetReferencedAssemblies() })

    $ReferencedAssemblyNames = $(
        foreach($Asm in @($RequiredAssemblies) + $Assemblies + $ReferencedAssemblied) {
            if ($ExcludedAssemblies -contains $Asm.Name) { }
            elseif ($ExcludedAssemblies -contains $Asm.FullName) { }
            elseif ($Asm.FullName -and ($ExcludedAssemblies -contains $Asm.FullName.Split(",")[0])) { }
            elseif ($Asm.Location) { $Asm.Location }
            elseif ($Asm.FullName) { $Asm.Fullname }
            else { "$Asm" }
        }
    )

    $ReferencedAssemblyNames | Where-Object {
        $_ -and $(
            foreach($exclusion in $ExcludedAssemblies) {
                ($_ -ne $exclusion) -and ($_ -NotLike $exclusion)
            }
        ) -NotContains $False
    } | Select -Unique

}
