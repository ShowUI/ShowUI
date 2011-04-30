if(!$PSScriptRoot){ 
   Write-Debug $($MyInvocation.MyCommand | fl * | out-string)
   $PSScriptRoot=(Split-Path $MyInvocation.MyCommand.Path -Parent) 
}

$EAP = $Global:ErrorActionPreference
$ErrorActionPreference = "SilentlyContinue"
Add-PsSnapin PoshWpf
$ErrorActionPreference = $EAP

$ShowUI.InstallPath = $PSScriptRoot
$ParameterHashCache = @{}
$DependencyProperties = @{}
if(Test-Path $ShowUI.InstallPath\DependencyPropertyCache.xml) {
   $DependencyProperties = [System.Windows.Markup.XamlReader]::Parse( (gc $ShowUI.InstallPath\DependencyPropertyCache.xml) )
}
$LoadedAssemblies = @(); 

$null = [Reflection.Assembly]::Load( "PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )

## Dot-Source all of these
. "$($ShowUI.InstallPath)\Core Functions\UtilityFunctions.ps1"
. "$($ShowUI.InstallPath)\Core Functions\ContentProperties.ps1"
. "$($ShowUI.InstallPath)\Core Functions\Add-UIFunction1.ps1"
. "$($ShowUI.InstallPath)\Core Functions\Set-DependencyProperty1.ps1"
. "$($ShowUI.InstallPath)\Core Functions\New-UIImage.ps1"
. "$($ShowUI.InstallPath)\Core Functions\Set-UIProperties.ps1"
. "$($ShowUI.InstallPath)\Core Functions\Add-ChildControl.ps1"

## Put ths scripts into the path
[string[]]$path = ${Env:Path}.Split(";")
if($path -notcontains "$ShowUI.InstallPath\Types_Generated\") {
   ## Note: Functions in "Types_StaticOverrides" override regular functions
   $path += "$ShowUI.InstallPath\Types_StaticOverrides\","$ShowUI.InstallPath\Types_Generated\"
   ${Env:Path} = [string]::Join(";", $path)
}

## Generate aliases for all the functions ....
$Scripts = Get-ChildItem "$ShowUI.InstallPath\Types_Generated\New-*.ps1","$ShowUI.InstallPath\Types_StaticOverrides\New-*.ps1" -ErrorAction 0
if(!$Scripts) {
   & "$ShowUI.InstallPath\Core\Reset-ShowUI.ps1"
   $Scripts = Get-ChildItem "$ShowUI.InstallPath\Types_Generated\New-*.ps1","$ShowUI.InstallPath\Types_StaticOverrides\New-*.ps1" -ErrorAction 0
}

foreach($script in $Scripts) {
   $TypeName = $script.Name -replace 'New-(.*).ps1','$1'
   
   # Set-Alias -Name "New-$TypeName" $Script.FullName                     -EA "SilentlyContinue" -EV +ErrorList
   Set-Alias -Name "$($TypeName.Split('.')[-1])" "New-$TypeName"        -EA "SilentlyContinue" -EV +ErrorList
}

## Extra aliases....
# A work around for the built-in "Grid" alias, call it GridPanel (which is what the class ought to be anyway?)
$errorList = @()
## We don't need this work around for the "Grid" alias anymore
## but we preserve compatability by still generating GridPanel (which is what the class ought to be anyway?)
Set-Alias -Name GridPanel  -Value "New-System.Windows.Controls.Grid"   -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning """GridPanel"" alias not created, you must use New-System.Windows.Controls.Grid" }

Set-Alias -Name Boots      -Value "Show-UI"         -EA "SilentlyContinue" -EV +ErrorList
$errorList = @()
Set-Alias -Name Show       -Value "Show-UI"         -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "Show alias not created, you must use the full Show-UI function name!" }

Set-Alias -Name BootsImage -Value "Out-UIImage"          -EA "SilentlyContinue" -EV +ErrorList
$errorList = @()
Set-Alias -Name UIImage -Value "Out-UIImage"          -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "UIImage alias not created, you must use the full Out-UIImage function name!" }

Set-Alias -Name obi        -Value "Out-UIImage"          -EA "SilentlyContinue"
Set-Alias -Name ouii       -Value "Out-UIImage"          -EA "SilentlyContinue"
Set-Alias -Name sap        -Value "Set-DependencyProperty"  -EA "SilentlyContinue"
Set-Alias -Name gbw        -Value "Get-UI"         -EA "SilentlyContinue"
Set-Alias -Name gui        -Value "Get-UI"         -EA "SilentlyContinue"
Set-Alias -Name rbw        -Value "Remove-UI"      -EA "SilentlyContinue"
Set-Alias -Name rui        -Value "Remove-UI"      -EA "SilentlyContinue"
