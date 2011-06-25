$outputPathBase = "$psScriptRoot\GeneratedAssemblies\"
$outputPath = "$outputPathBase\ShowUI.CLR$($psVersionTable.clrVersion).dll"
    
. $psScriptRoot\CodeGenerator\Rules\WpfCodeGenerationRules.ps1

if (
    # If the generatedassemblies directory doesn't exist, or...
    (-not (Test-Path $outputPath))
) {
    # Regenerate the code
    $progressId = Get-Random
    Write-Progress "Preparing Show-UI for First Time Use" "Please Wait" -Id $progressId 
    
    if (-not (Test-Path $psScriptRoot\GeneratedAssemblies)) {
        New-Item $psScriptRoot\GeneratedAssemblies -ItemType "Directory" -Force | Out-Null
    }
    

    if (-not (Test-Path $psScriptRoot\GeneratedCode)) {
        New-Item $psScriptRoot\GeneratedCode -ItemType "Directory" -Force | Out-Null
    }

   
    $childId = Get-Random    
    Write-Progress "Filtering Types" " " -ParentId $progressId -Id $childId
    $WinFormsIntegration = "WindowsFormsIntegration, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"

    try {
        $Assemblies = [Reflection.Assembly]::LoadWithPartialName("WindowsBase"),
            [Reflection.Assembly]::LoadWithPartialName("PresentationFramework"),
            [Reflection.Assembly]::LoadWithPartialName("PresentationCore"),
            [Reflection.Assembly]::Load($WinFormsIntegration)
    } catch {
        throw $_
    }
    

    $specificTypeNameBlackList = 
        'System.Windows.Threading.DispatcherFrame', 
        'System.Windows.DispatcherObject',
        'System.Windows.Interop.DocObjHost',
        'System.Windows.Ink.GestureRecognizer',
        'System.Windows.Data.XmlNamespaceMappingCollection',
        'System.Windows.Annotations.ContentLocator',
        'System.Windows.Annotations.ContentLocatorGroup'

    $allTypes = foreach ($assembly in $assemblies) {
        $Name = $assembly.GetName().Name
        
        Write-Progress "Filtering Types from Assembly" $Name -Id $ChildId -ParentId $progressId
        $Assembly.GetTypes() | 
            Where-Object {
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
                (-not $_.IsSubclassOf([Windows.Input.InputGesture])) -and
                (-not $_.IsSubclassOf([Windows.Input.InputBinding])) -and
                (-not $_.IsSubclassOf([Windows.TemplateKey])) -and                
                (-not $_.IsSubclassOf([Windows.Media.Imaging.BitmapEncoder])) -and                
                ($_.BaseType -ne [Object]) -and
                ($_.BaseType -ne [ValueType]) -and
                $_.Name -notlike '*KeyFrame' -and                
                $specificTypeNameBlackList -notcontains $_.FullName
            }                            
    }       
    
    $resultList = New-Object Collections.arraylist 
    $typeCounter =0
    $count= @($allTypes).Count


    foreach ($type in $allTypes) 
    {
        if (-not $type) { continue }
        $typeCounter++
        $perc = $typeCounter * 100/ $count 
        Write-Progress "Generating Code" $type.Fullname -PercentComplete $perc -ParentId $progressID -Id $childId     
        $typeCode = ConvertFrom-TypeToScriptCmdlet -Type $type -ErrorAction SilentlyContinue -AsCSharp    
        $ofs = [Environment]::NewLine
        $null = $resultList.Add("$typeCode")
    }

    $resultList = $resultList | Where-Object { $_ } 
    
    Write-Progress "Code Generation Complete" " " -PercentComplete 100 -ParentId $progressID -Id $childId     
    $controlNameDependencyObject = [IO.File]::ReadAllText("$psScriptRoot\C#\ShowUIDependencyObjects.cs")
    $attributeCode = [IO.File]::ReadAllText("$psScriptRoot\C#\ShowUIAttribute.cs")
    $ValueConverter = [IO.File]::ReadAllText("$psScriptRoot\C#\LanguagePrimitivesValueConverter.cs")
    $wpfJob = [IO.File]::ReadAllText("$psScriptRoot\C#\WPFJob.cs")
    $PowerShellDataSource = [IO.File]::ReadAllText("$psScriptRoot\C#\PowerShellDataSource.cs")
    $generatedCode = "
    $controlNameDependencyObject
    $attributeCode
    $ValueConverter
    $wpfJob 
    $PowerShellDataSource
    $resultList
    
    
    "
    $generatedCodePath  = "$psScriptRoot\GeneratedCode\ShowUICommands.cs"
    try {
        # For debugging purposes, try to put the code in the module.  
        # The module could be run from CD or a filesystem without write access, 
        # so redirect errors into the Debug channel.
        [IO.File]::WriteAllText($generatedCodePath, $generatedCode)
    } catch {
        $_ | Out-String | Write-Debug
    }
    $winFormsAssembly = "System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"                
    $Assemblies+=$winFormsAssembly
    $outputPath = "$psScriptRoot\GeneratedAssemblies\ShowUI.CLR$($psVersionTable.clrVersion).dll"
        
    if ($PSVersionTable.ClrVersion.Major -ge 4) {
        $xamlAsm = [Reflection.Assembly]::Load('System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
        $assemblies += $xamlAsm
    }

    $addTypeParameters = @{
        TypeDefinition=$generatedCode
        IgnoreWarnings=$true
        ReferencedAssemblies=$Assemblies
        Language='CSharpVersion3'
        OutputAssembly=$outputPath
        PassThru=$true                      
    }

    # Check to see if the outputpath can be written to
    $canWrite = Set-Content "$outputPathBase\test.write" -Value (Get-Random) -ErrorAction SilentlyContinue -PassThru
    if (-not $canWrite) {
        $null = $addTypeParameters.Remove('OutputAssembly')
    } else {
        Remove-Item "$outputPathBase\test.write" -ErrorAction SilentlyContinue
    }
    
    
    Add-Type @addTypeParameters
}

