function Add-UIModule {
    #.Synopsis
    #   Generate a Module with commands for creating UI Elements
    #.Description
    #   Generate a PowerShell Module from one or more assemblies (or types)
    #   If you specify a simple name, the module will be generated in your Documents\WindowsPowerShell\Modules\ folder
    #   If you want the module in another location, specify a full path...
    #.Example
    #   Add-UIModule -Path .\MahApps.Metro.dll -Name MahApps.Metro
    #
    #   The simplest way to use Add-UIModule is to specify the path (or assembly name, if it's in the GAC) to a dll with WPF controls in it, and the name of the module that you want to create.
    #   
    #.Example
    #   Add-UIModule -Path .\MahApps.Metro.dll -Name ~\Documents\WindowsPowerShell\MahApps\MahApps.psm1
    #
    #   This example shows how you can specify a full path as the name, in order to generate a module in a specific location
    #.Example
    #   cd ~\Documents\WindowsPowerShell\Modules
    #   nuget install MahApps.Metro -x
    #   Add-UIModule -Path .\MahApps.Metro\lib\net45\MahApps.Metro.dll -Name MahApps.Metro
    #
    #   This more complete example shows one way to use nuget.exe to install an assembly, and then generate the module to go with it.
    #   When you install a module with nuget using the -x parameter, the version number is left off the folder name, and you can usually find the .dll somewhere inside a "lib" subfolder.
    [CmdletBinding()]
    param(
        # The Path to an assembly to generate a UIModule for
        [Parameter(ParameterSetName='Path', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('PSPath')]
        [string[]]
        $Path,

        # The name of a GAC assembly to generate a UI module for
        [Parameter(ParameterSetName='Assembly', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
        [Alias('AN')]
        [string[]]
        $AssemblyName,

        # The full name(s) of one or more types to generate into a UI module
        [Parameter(ParameterSetName='Type', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
        [Type[]]
        $Type,

        # A whitelist for types that you want to generate cmdlets for *in addition* to types that pass Select-UIType
        [Parameter()]
        [String[]]
        $TypeNameWhiteList,

        # A blacklist for types that you do not want to generate cmdlets for even if they pass Select-UIType
        [Parameter()]
        [String[]]
        $TypeNameBlackList,

        # The name of the module to create (either a simple name, or a full path to the psd1)
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        # Additional assemblies (assembly names, or full paths) that are required as references for the module
        [string[]]
        $RequiredAssemblies,

        # Generate CSharp Cmdlets instead of script functions
        [switch]
        $AsCmdlet,

        # If set, don't generate the psd1 metadata file
        [switch]
        $AssemblyOnly,

        # Override the default placement of the source code output
        [string]
        $SourceCodePath,

        # Import the module after generating it
        [switch]
        $Import,

        # Output the module info after generating it
        [switch]
        $Passthru,

        # A scriptblock to run whenever the module is imported
        [ScriptBlock]
        $On_ImportModule,

        # A scriptblock to run whenever the module is removed
        [ScriptBlock]
        $On_RemoveModule,

        # The Write-Progress id for nesting with other calls to Write-Progress
        [Int]
        $ProgressId = $(Get-Random),

        # The Write-Progress parent id for nesting with other calls to Write-Progress
        [Int]
        $ProgressParentId = -1
    )
    begin {
        $typeCounter = 0
        $ConstructorCmdletNames = New-Object Collections.Generic.List[String]
        $resultList = New-Object Collections.Generic.List[String]
    }
    process {
        if ($psCmdlet.ParameterSetName -eq 'Type') {
            [Type[]]$filteredTypes = $type
        } else {
            for($p=0;$p -lt $Path.Count;$p++){
                $Path[$p] = $ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath(($Path[$p]))
            }
            $RequiredAssemblies += @($Path) + @($AssemblyName) | Where { $_ }
            Write-Progress "Filtering Types" " " -ParentId $ProgressParentId -Id $ProgressId
            [Type[]]$filteredTypes = Select-UIType -Path @($Path) -AssemblyName @($AssemblyName) -TypeNameWhiteList @($TypeNameWhiteList) -TypeNameBlackList @($TypeNameBlackList)
        }
        $ofs = [Environment]::NewLine
        $count = $filteredTypes.Count
        foreach ($include in $filteredTypes)
        {
            if (-not $include) { continue }
            $typeCounter++
            if($count -gt 1) {
                $perc = $typeCounter * 100/ $count 
                Write-Progress "Generating Code" $include.Fullname -PercentComplete $perc -Id $ProgressId -ParentId $ProgressParentId
            } else {
                Write-Progress "Generating Code" $include.Fullname -Id $ProgressId -ParentId $ProgressParentId
            }
            $typeCode = ConvertFrom-TypeToScriptCmdlet -Type $include -AsScript:(!$AsCmdlet) `
                        -ConstructorCmdletNames ([ref]$ConstructorCmdletNames)  -ErrorAction SilentlyContinue
            $null = $resultList.Add( ($typeCode -join [Environment]::NewLine) )
        }
    }
    end {
        Write-Progress "Code Generation Complete" " " -PercentComplete 100 -Id $ProgressId -ParentId $ProgressParentId

        $codeList = foreach($r in $resultList){ if($r){ $r } }
        $ConstructorCmdletNames = foreach($c in $ConstructorCmdletNames){ if($c){ $c } }
        $code = $codeList -join [Environment]::NewLine
        
        if ($name.Contains("\")) {
            # It's definitely a path
            $semiResolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Name)
            if ($semiResolved -like "*.psd1") {
                $moduleMetadataPath = $semiResolved
            } elseif ($semiResolved -like "*.psm1") {
                $moduleMetadataPath = $semiResolved.Replace(".psm1", ".psd1")
            } elseif ($semiResolved -like "*.dll") {
                $AssemblyPath = $SemiResolved
                $moduleMetadataPath = $semiResolved.replace(".dll",".psd1")
            } else {
                $leaf = Split-Path -Path $semiResolved -Leaf 
                $moduleMetadataPath = Join-Path $semiResolved "${leaf}.psd1" 
            }
            
        } elseif ($name -like "*.dll") {
            $moduleMetadataPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($name.replace(".dll",".psd1"))
        } elseif ($name -like "*.psd1") {
            $moduleMetadataPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($name)
        } elseif ($name -like ".psm1" ) {
            $moduleMetadataPath = $moduleMetadataPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($name.Replace(".psm1",".psd1"))
        } else {
            # It's just a name, figure out what the real manifest path will be
            $moduleMetadataPath = "$env:UserProfile\Documents\WindowsPowerShell\Modules\$Name\$Name.psd1"
        }
        
        $moduleroot = Split-Path $moduleMetadataPath
        
        if (-not (Test-Path $moduleroot)) {
            New-Item -ItemType Directory -Path $moduleRoot | Out-Null
        }
        
        $psm1Path = $moduleMetadataPath.Replace(".psd1", ".psm1")
           
        if ($AsCmdlet) {
            if(!$SourceCodePath) {
                $SourceCodePath = $moduleMetadataPath.Replace(".psd1","Commands.cs")
            }
            Set-Content -LiteralPath $SourceCodePath -Value $Code
            if(!$AssemblyPath) {
                $AssemblyPath = $moduleMetadataPath.Replace(".psd1","Commands.dll")
            }
        } else {
            $modulePath = $moduleMetadataPath.Replace(".psd1", ".psm1")
        }

        if(!$AssemblyOnly) {
    # Ok, build the module scaffolding
@"
@{
    ModuleVersion = '1.0'
    RequiredModules = 'ShowUI'
    RequiredAssemblies = '$($RequiredAssemblies -Join "','")'
    ModuleToProcess = '$psm1Path'
    GUID = '$([GUID]::NewGuid())' 
    $( if($AsCmdlet) { 
    "NestedModules = '$AssemblyPath'
    CmdletsToExport = "
    } else { "FunctionsToExport = " }
    )@('New-$($ConstructorCmdletNames -join ''',''New-' ) ' ) 
    AliasesToExport = @( '$($ConstructorCmdletNames -join ''',''')' )
}
"@ | 
            Set-Content -Path $moduleMetadataPath -Encoding Unicode
        }

        if(!$AssemblyOnly -or !$AsCmdlet) {
"
$On_ImportModule
$(
    if(!$AsCmdlet) {
        $code
    }
    if($On_RemoveModule) {"
`$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    $On_RemoveModule
}
"   }
    foreach($n in $ConstructorCmdletNames) {"
Set-Alias -Name $n -Value New-$n "
    }
)
Export-ModuleMember -Cmdlet * -Function * -Alias *
" | 
            Set-Content -Path $psm1Path -Encoding Unicode
    
        }

        if ($AsCmdlet) {
            #  if(!$RequiredAssemblies) {
                #  $RequiredAssemblies = 
                    #  [Reflection.Assembly]::Load("WindowsBase, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
                    #  [Reflection.Assembly]::Load("PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
                    #  [Reflection.Assembly]::Load("PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")
            #  }
            if($PSVersionTable.CLRVersion -ge "4.0") {
                $RequiredAssemblies += [Reflection.Assembly]::Load("System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"), 
                                       [Reflection.Assembly]::Load("System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
            }

            $AddTypeParameters = @{
                TypeDefinition       = $code
                IgnoreWarnings       = $true
                Language             = 'CSharpVersion3'
                ReferencedAssemblies = Get-AssemblyName -RequiredAssemblies $RequiredAssemblies -ExcludedAssemblies "MSCorLib","System","System.Core"
            }
            # If we're running in .Net 4, we shouldn't specify the Language, because it'll use CSharp4
            if ($PSVersionTable.ClrVersion.Major -ge 4) {
                $AddTypeParameters.Remove("Language")
            }
            # Check to see if the outputpath can be written to: we don't *have* to save it as a dll
            $TestPath = "$(Split-Path $AssemblyPath)\test.write"
            if (Set-Content $TestPath -Value "1" -ErrorAction SilentlyContinue -PassThru) {
                Remove-Item $TestPath -ErrorAction SilentlyContinue
                $AddTypeParameters.OutputAssembly = $AssemblyPath
            }
            Write-Debug "Type Parameters:`n$($addTypeParameters | Out-String)"
            Write-Progress "Code Generation Complete" "Compiling ShowUI Assembly" -PercentComplete 100 -Id $ProgressId -ParentId $ProgressParentId
            
            Add-Type @addTypeParameters
        }

        if($Import) {
            Write-Progress "Code Generation Complete" "Importing ShowUI Assembly" -PercentComplete 100 -Id $ProgressId -ParentId $ProgressParentId
            Import-Module $moduleMetadataPath -Passthru:$Passthru
        } elseif($Passthru) {
            Get-Module $Name -ListAvailable
        }
    }    
} 
