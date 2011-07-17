param(
$outputPathBase = "$psScriptRoot\GeneratedAssemblies\",
$CommandPath    = "$outputPathBase\ShowUI.CLR$($psVersionTable.clrVersion).dll",
$CoreOutputPath = "$outputPathBase\ShowUICore.CLR$($psVersionTable.clrVersion).dll",
$Assemblies,
$Force
)

# If the expected output already exists, then we've nothing to do here :)
if((Test-Path $CommandPath, $CoreOutputPath) -notcontains $False) { return }

# But otherwise, we need to start regenerating the code ...
. $psScriptRoot\CodeGenerator\Rules\WpfCodeGenerationRules.ps1
# Regenerate the code
$progressId = Get-Random
$childId = Get-Random    

Write-Progress "Preparing Show-UI for First Time Use" "Please Wait" -Id $progressId 

if (-not (Test-Path $outputPathBase)) {
    New-Item $outputPathBase -ItemType "Directory" -Force | Out-Null
}
$SourcePathBase = ($outputPathBase -replace "GeneratedAssemblies","GeneratedCode")

if (-not (Test-Path $SourcePathBase)) {
    New-Item $SourcePathBase -ItemType "Directory" -Force | Out-Null
}

Write-Progress "Compiling Core Features" " " -ParentId $progressId -Id $childId

if(!$Assemblies) {
    try {
        $Assemblies = 
        [Reflection.Assembly]::Load("WindowsBase, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
        [Reflection.Assembly]::Load("PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
        [Reflection.Assembly]::Load("PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
        [Reflection.Assembly]::Load("WindowsFormsIntegration, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35")

        if ($PSVersionTable.ClrVersion.Major -ge 4) {
            $Assemblies += [Reflection.Assembly]::Load("System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
        }
    } catch {
        throw $_
    }
}
$generatedCode = ""

<#
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

$allTypes = foreach ($assembly in $assemblies) {
    $Name = $assembly.GetName().Name
    
    Write-Progress "Filtering Types from Assembly" $Name -Id $ChildId -ParentId $progressId
    $Assembly.GetTypes() | Where-Object {
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

$generatedCode = New-Object Collections.arraylist 
$typeCounter =0
$count= @($allTypes).Count


foreach ($type in $allTypes) 
{
    if (-not $type) { continue }
    $typeCounter++
    $perc = $typeCounter * 100/ $count 
    Write-Progress "Generating Code" $type.Fullname -PercentComplete $perc -ParentId $progressID -Id $childId     
    $typeCode = ConvertFrom-TypeToScriptCmdlet -Type $type -ErrorAction SilentlyContinue -AsCSharp    
    $null = $generatedCode.Add("$typeCode")
}

$ofs = [Environment]::NewLine

$generatedCode = $generatedCode | Where-Object { $_ } 
#>
$controlNameDependencyObject = [IO.File]::ReadAllText("$psScriptRoot\C#\ShowUIDependencyObjects.cs")
$cmdCode = [IO.File]::ReadAllText("$psScriptRoot\C#\ShowUICommand.cs")
$ValueConverter = [IO.File]::ReadAllText("$psScriptRoot\C#\LanguagePrimitivesValueConverter.cs")
$wpfJob = [IO.File]::ReadAllText("$psScriptRoot\C#\WPFJob.cs")
$PowerShellDataSource = [IO.File]::ReadAllText("$psScriptRoot\C#\PowerShellDataSource.cs")
$OutXamlCmdlet = [IO.File]::ReadAllText("$psScriptRoot\C#\OutXaml.cs")

$generatedCode = "
$controlNameDependencyObject
$cmdCode
$ValueConverter
$wpfJob 
$PowerShellDataSource
$generatedCode
$OutXamlCmdlet
"

$CoreSourceCodePath  =   "$SourcePathBase\ShowUICore.CLR$($psVersionTable.clrVersion).cs"
try {
    # For debugging purposes, try to put the code in the module.  
    # The module could be run from CD or a filesystem without write access, 
    # so redirect errors into the Debug channel.
    [IO.File]::WriteAllText($CoreSourceCodePath, $generatedCode)
} catch {
    $_ | Out-String | Write-Debug
}

$RequiredAssemblies = $Assemblies + @("System.Windows.Forms, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089", 
                                      "System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")

$addTypeParameters = @{
    TypeDefinition=$generatedCode
    IgnoreWarnings=$true
    ReferencedAssemblies=Get-AssemblyNames -RequiredAssemblies $RequiredAssemblies -ExcludedAssemblies "MSCorLib","System"
    Language='CSharpVersion3'
}
# If we're running in .Net 4, we shouldn't specify the Language, because it'll use CSharp4
if ($PSVersionTable.ClrVersion.Major -ge 4) {
    $AddTypeParameters.Remove("Language")
}
# Check to see if the outputpath can be written to: we don't *have* to save it as a dll
if (Set-Content "$outputPathBase\test.write" -Value "1" -ErrorAction SilentlyContinue -PassThru) {
    Remove-Item "$outputPathBase\test.write" -ErrorAction SilentlyContinue
    $AddTypeParameters.OutputAssembly = $CoreOutputPath
}

Write-Debug "Type Parameters:`n$($addTypeParameters | Out-String)"

Add-Type @addTypeParameters

if((Test-Path $CommandPath) -and !$Force) { return }
$SourceCodePath = $CommandPath -replace "GeneratedAssemblies", "GeneratedCode" -replace '.dll$','.cs'

Write-Debug "Generating Commands From Assemblies:`n$($Assemblies | Format-Table @{name="Version";expr={$_.ImageRuntimeVersion}}, FullName -auto | Out-String)"
Add-UIModule -AssemblyName $Assemblies -RequiredAssemblies $RequiredAssemblies -Name $CommandPath -SourceCodePath $SourceCodePath -AsCmdlet -AssemblyOnly -ProgressParentId $progressId -ProgressId $ChildId
