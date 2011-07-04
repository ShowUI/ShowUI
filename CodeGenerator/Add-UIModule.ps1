function Add-UIModule
{
    param(
    [Parameter(ParameterSetName='File',
        Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
    [string]
    $File,        
    
    [Parameter(ParameterSetName='Assembly',Mandatory=$true,ValueFromPipelineByPropertyName=$true)]
    [string]
    $Assembly,    
    
    [Parameter(ParameterSetName='Type',
        Mandatory=$true,
        ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true)]
    [Type]
    $Type,
    
    # The name of the module to create (either a simple name, or a full path to the psd1)
    [string]
    $Name,
    
    [switch]
    $AsScript,
    
    [switch]
    $OutputCode,
        
    [ScriptBlock]
    $On_ImportModule,
    
    [ScriptBlock]
    $On_RemoveModule
    )
    
    begin {
        $specificTypeNameWhiteList =
            'System.Windows.Input.ApplicationCommands',
            'System.Windows.Input.ComponentCommands',
            'System.Windows.Input.NavigationCommands',
            'System.Windows.Input.MediaCommands',
            'System.Windows.Documents.EditingCommands',
            'System.Windows.Input.CommandBinding'

        $specificTypeNameBlackList =
            'System.Windows.Threading.DispatcherFrame', 
            'System.Windows.DispatcherObject',
            'System.Windows.Interop.DocObjHost',
            'System.Windows.Ink.GestureRecognizer',
            'System.Windows.Data.XmlNamespaceMappingCollection',
            'System.Windows.Annotations.ContentLocator',
            'System.Windows.Annotations.ContentLocatorGroup'


    }
    
    process {
        $types = @()
        if ($psCmdlet.ParameterSetName -eq 'Type') 
        {
            $types+=$type
        } elseif ($psCmdlet.ParameterSetName -eq 'File') 
        {            
            $asm = [Reflection.Assembly]::LoadFrom($ExecutionContext.SessionState.Path.GetResolvedPSPathFromPSPath($file))
            if ($asm) {
                $types += $asm.GetTypes()
            }
        } elseif ($psCmdlet.ParameterSetName -eq 'Assembly') {
            try {
                $types += [Reflection.Assembly]::Load($assembly)
            } catch {
                $err = $_
                try {
                    [Reflection.Assembly]::LoadWithPartialName($assembly)
                } catch {
                    Write-Error $err                                     
                    Write-Error $_
                }
            }
        }
        
        $childId = Get-Random
        if ($types) {                    
            $resultList = New-Object Collections.arraylist 
            $typeCounter =0
            $count= @($types).Count

            $filteredTypes = $types | Where-Object {
                    $specificTypeNameWhiteList -contains $_.FullName -or
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
        #               (-not $_.IsSubclassOf([Windows.Input.InputGesture])) -and
        #               (-not $_.IsSubclassOf([Windows.Input.InputBinding])) -and
                        (-not $_.IsSubclassOf([Windows.TemplateKey])) -and
                        (-not $_.IsSubclassOf([Windows.Media.Imaging.BitmapEncoder])) -and
                        ($_.BaseType -ne [Object]) -and
                        ($_.BaseType -ne [ValueType]) -and
                        $_.Name -notlike '*KeyFrame' -and
                        $specificTypeNameBlackList -notcontains $_.FullName
                    )
                }
            }

            $ofs = [Environment]::NewLine
            $count = $filteredTypes.Count
            $ConstructorCmdletNames = @()
            foreach ($type in $filteredTypes) 
            {
                if (-not $type) { continue }
                $typeCounter++
                $perc = $typeCounter * 100/ $count 
                Write-Progress "Generating Code" $type.Fullname -PercentComplete $perc -Id $childId     
                $typeCode = ConvertFrom-TypeToScriptCmdlet -Type $type -ErrorAction SilentlyContinue -AsScript:$AsScript -ConstructorCmdletNames ([ref]$ConstructorCmdletNames)
                $null = $resultList.Add("$typeCode")
            }

            $resultList = $resultList | Where-Object { $_ }
            $ConstructorCmdletNames = $ConstructorCmdletNames | Where-Object { $_ }
        
            $code = "$resultList"                   
            if ($outputCode) {
                $Code
            }
            
            if ($name.Contains("\")) {
                # It's definitely a path
                $semiResolved = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Name)
                if ($semiResolved -like "*.psd1") {
                    $moduleMetadataPath = $semiResolved
                } elseif ($semiResolved -like "*.psm1") {
                    $moduleMetadataPath = $semiResolved.Replace(".psm1", ".psd1")
                } elseif ($semiResolved -like "*.dll" -and !$AsScript) {
                    $moduleMetadataPath = $semiResolved.replace(".dll",".psd1")
                } else {
                    $leaf = Split-Path -Path $semiResolved -Leaf 
                    $moduleMetadataPath = Join-Path $semiResolved "${leaf}.psd1" 
                }
                
            } elseif ($name -like "*.dll" -and !$AsScript) {
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
            
            if (!$AsScript) {
               $modulePath = $moduleMetadataPath.Replace(".psd1","Commands.dll")
               $psm1Path = $moduleMetadataPath.Replace(".psd1", ".psm1")
            } else {
               $psm1Path = $modulePath = $moduleMetadataPath.Replace(".psd1", ".psm1")
            }
            # Ok, build the module scaffolding
@"
@{
    ModuleVersion = '1.0'
    RequiredModules = 'ShowUI'
    RequiredAssemblies = $(if($File){"'$File'"}if($Assembly){"'$Assembly'"})
    ModuleToProcess = '$psm1Path'
    GUID = '$([GUID]::NewGuid())' 
    $( if(!$AsScript) { 
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
if($AsScript) {
$code
}
if($On_RemoveModule) {"
`$myInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
    $On_RemoveModule
}
"
}
foreach($n in $ConstructorCmdletNames) {"
Set-Alias -Name $n -Value New-$n "
}
)
Export-ModuleMember -Cmdlet * -Function * -Alias *
" | Set-Content -Path $psm1Path -Encoding Unicode
    
            if (!$AsScript) {
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
                   PassThru             = $true
                   ReferencedAssemblies = $types | 
                       Select-Object -ExpandProperty Assembly -Unique | 
                       ForEach-Object { @($_) + @($_.GetReferencedAssemblies()) | Select-Object -Unique } |
                       Where-Object { $_.Name -ne 'MSCorLib' -and $_.Name -ne "System" } | 
                       ForEach-Object { if ($_.Location) { $_.Location } else { $_.Fullname } }                      
               }
               
               if($PSVersionTable.CLRVersion -ge "4.0") {
                  $addTypeParameters.ReferencedAssemblies += "System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
               }
                           
               Add-Type @addTypeParameters
                return Get-Item $dllPath                
            }
            
    }    
} 
