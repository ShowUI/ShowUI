function Select-UIType {
[CmdletBinding()]
param(
    [Parameter(Position=0, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [string[]]
    $Path,        
    
    [Parameter()]
    [Alias('AN')]
    [string[]]
    $AssemblyName,    
    
    [Parameter()]
    [Type[]]
    $Type,

    [Parameter()]
    [String[]]
    $TypeNameWhiteList,

    [Parameter()]
    [String[]]
    $TypeNameBlackList
)
begin {
    $TypeNameWhiteList = $TypeNameWhiteList + @(
        'System.Windows.Input.ApplicationCommands',
        'System.Windows.Input.ComponentCommands',
        'System.Windows.Input.NavigationCommands',
        'System.Windows.Input.MediaCommands',
        'System.Windows.Documents.EditingCommands',
        'System.Windows.Input.CommandBinding' ) | Select -Unique

    $TypeNameBlackList = $TypeNameBlackList + @(
        'System.Windows.Threading.DispatcherFrame', 
        'System.Windows.DispatcherObject',
        'System.Windows.Interop.DocObjHost',
        'System.Windows.Ink.GestureRecognizer',
        'System.Windows.Data.XmlNamespaceMappingCollection',
        'System.Windows.Annotations.ContentLocator',
        'System.Windows.Annotations.ContentLocatorGroup' ) | Select -Unique
}
process {
    if(!(Test-Path Variable:Type) -or ($Type -eq $null)) {
        $Type = New-Object Type[] 0
    }
    if ($Path) 
    {
        foreach($p in $path) {
            Write-Verbose "$($ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($p))"
            $asm = [Reflection.Assembly]::LoadFrom($ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($p))
            if ($asm) {
                $Type += $asm.GetTypes()
            }
        }
    } 
    if ($AssemblyName) {
        foreach($a in $AssemblyName) {
            try {
                $asm = [Reflection.Assembly]::Load($a)
                if ($asm) {
                    $Type += $asm.GetTypes()
                }
            } catch {
                $err = $_
                try {
                    $asm = [Reflection.Assembly]::LoadWithPartialName($a)
                    if ($asm) {
                        $Type += $asm.GetTypes()
                    }
                } catch {
                    Write-Error $err                                     
                    Write-Error $_
                }
            }
        }
    }
}
end {
    $Type | Where-Object {
        $TypeNameWhiteList -contains $_.FullName -or
        (
            $_.IsPublic -and 
            (-not $_.IsGenericType) -and 
            (-not $_.IsAbstract) -and
            (-not $_.IsEnum) -and
            ($_.FullName -notlike "*Internal*") -and
            (-not $_.IsSubclassOf([EventArgs])) -and
            (-not $_.IsSubclassOf([Exception])) -and
            (-not $_.IsSubclassOf([Attribute])) -and
            (-not $_.IsSubclassOf([Windows.Markup.ValueSerializer])) -and
            (-not $_.IsSubclassOf([MulticastDelegate])) -and
            (-not $_.IsSubclassOf([ComponentModel.TypeConverter])) -and
            (-not $_.GetInterface([Collections.ICollection])) -and
            (-not $_.IsSubClassOf([Windows.SetterBase])) -and
            (-not $_.IsSubclassOf([Security.CodeAccessPermission])) -and
            (-not $_.IsSubclassOf([Windows.Media.ImageSource])) -and
            (-not $_.IsSubclassOf([Windows.TemplateKey])) -and
            (-not $_.IsSubclassOf([Windows.Media.Imaging.BitmapEncoder])) -and
            ($_.BaseType -ne [Object]) -and
            ($_.BaseType -ne [ValueType]) -and
            $_.Name -notlike '*KeyFrame' -and
            $TypeNameBlackList -notcontains $_.FullName
        )
    }
}
}


function Add-UIModule
{
    [CmdletBinding()]
    param(
    [Parameter(ParameterSetName='Path', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('PSPath')]
    [string[]]
    $Path,        
    
    [Parameter(ParameterSetName='Assembly', Mandatory=$true, ValueFromPipelineByPropertyName=$true)]
    [Alias('AN')]
    [string[]]
    $AssemblyName,    
    
    [Parameter(ParameterSetName='Type', Mandatory=$true, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
    [Type[]]
    $Type,
    
    # The name of the module to create (either a simple name, or a full path to the psd1)
    [string]
    $Name,
    
    [string[]]
    $RequiredAssemblies,
    
    [switch]
    $AsCmdlet,
    
    [switch]
    $Import,
    
    [switch]
    $PassthruCode,
    
    [switch]
    $PassthruTypes,
    
    [switch]
    $PassthruAssembly,
    
    [switch]
    $PassthruModule,
    
    [ScriptBlock]
    $On_ImportModule,
    
    [ScriptBlock]
    $On_RemoveModule
    )
    begin {
        $childId = Get-Random
        $typeCounter = 0
        $ConstructorCmdletNames = New-Object Collections.Generic.List[String]
        $resultList = New-Object Collections.Generic.List[String]
    }
    process {
        if ($psCmdlet.ParameterSetName -eq 'Type') 
        {
            $filteredTypes = $type
        } else {
            $requiredAssemblies += @($Path) + @($AssemblyName)
            $filteredTypes = Select-UIType -Path @($Path) -AssemblyName @($AssemblyName)
        }
        $ofs = [Environment]::NewLine
        $count = @($filteredTypes).Count
        foreach ($type in $filteredTypes) 
        {
            if (-not $type) { continue }
            $typeCounter++
            if($count -gt 1) {
                $perc = $typeCounter * 100/ $count 
                Write-Progress "Generating Code" $type.Fullname -PercentComplete $perc -Id $childId 
            } else {
                Write-Progress "Generating Code" $type.Fullname -Id $childId
            }
            $typeCode = ConvertFrom-TypeToScriptCmdlet -Type $type -AsScript:(!$AsCmdlet) `
                        -ConstructorCmdletNames ([ref]$ConstructorCmdletNames)  -ErrorAction SilentlyContinue
            $null = $resultList.Add("$typeCode")
        }
    }
    end {
        $resultList = $resultList | Where-Object { $_ }
        $ConstructorCmdletNames = $ConstructorCmdletNames | Where-Object { $_ }
        $code = "$resultList"                   
        if ($PassthruCode) {
            $Code
        }
        
        if ($name.Contains("\")) {
            # It's definitely a path
            $semiResolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Name)
            if ($semiResolved -like "*.psd1") {
                $moduleMetadataPath = $semiResolved
            } elseif ($semiResolved -like "*.psm1") {
                $moduleMetadataPath = $semiResolved.Replace(".psm1", ".psd1")
            } elseif ($semiResolved -like "*.dll") {
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
            Set-Content -LiteralPath $moduleMetadataPath.Replace(".psd1","Commands.cs") -Value $Code
            $modulePath = $moduleMetadataPath.Replace(".psd1","Commands.dll")
        } else {
            $modulePath = $moduleMetadataPath.Replace(".psd1", ".psm1")
        }
        
# Ok, build the module scaffolding
@"
@{
    ModuleVersion = '1.0'
    RequiredModules = 'ShowUI'
    RequiredAssemblies = '$(if($Path){$Path -Join "','"}elseif($AssemblyName){$AssemblyName -Join "','"})'
    ModuleToProcess = '$psm1Path'
    GUID = '$([GUID]::NewGuid())' 
    $( if($AsCmdlet) { 
    "NestedModules = '$modulePath'
    CmdletsToExport = "
    } else { "FunctionsToExport = " }
    )@('New-$($ConstructorCmdletNames -join ''',''New-' ) ' ) 
    AliasesToExport = @( '$($ConstructorCmdletNames -join ''',''')' )
}
"@ | Set-Content -Path $moduleMetadataPath -Encoding Unicode

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
" | Set-Content -Path $psm1Path -Encoding Unicode
        
        if ($AsCmdlet) {
            $dllPath = $modulePath
       
            <#
                Unfortunately, compiled code would add a lot of complexity here
                (some assemblies link only if they are installed with regasm, which would 
                get into selective elevation and open up a large can of worms.
               
                For the moment, this can be done with the script generator
            #>
            $addTypeParameters = @{
                TypeDefinition       = $code
                IgnoreWarnings       = $true
                Language             = 'CSharpVersion3'
                OutputAssembly       = $dllPath
                PassThru             = $PassthruTypes
                ReferencedAssemblies = $filteredTypes | 
                    Select-Object -ExpandProperty Assembly -Unique | 
                    ForEach-Object { @($_) + @($_.GetReferencedAssemblies()) | Select-Object -Unique } |
                    Where-Object { "MSCorLib","System","System.Core" -notcontains $_.Name } | 
                    ForEach-Object { if ($_.Location) { $_.Location } else { $_.Fullname } }                      
            }
            
            if($PSVersionTable.CLRVersion -ge "4.0") {
                $addTypeParameters.ReferencedAssemblies += "System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
            }
            
            Add-Type @addTypeParameters
            if($PassthruAssembly){
                Get-Item $dllPath
            }
        }

        if($Import) {
            Import-Module $moduleMetadataPath -Passthru:$PassthruModule
        } elseif($PassthruModule) {
            Get-Module $Name -ListAvailable
        }
    }    
} 
