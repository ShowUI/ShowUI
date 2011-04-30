##Requires -Version 2.0
####################################################################################################
if(!(Test-Path Variable::ShowUI.InstallPath)) {
New-Variable ShowUI @{} -Description "ShowUI Settings Variable" -Option ReadOnly -Scope Global
$ShowUI.InstallPath  = $PSScriptRoot
}
$ParameterHashCache = @{}
[Hashtable]$DependencyProperties = @{}
if(Test-Path "$($ShowUI.InstallPath)\DependencyPropertyCache.xml") {
   [Hashtable]$DependencyProperties = [System.Windows.Markup.XamlReader]::Parse( (gc "$($ShowUI.InstallPath)\DependencyPropertyCache.xml") )
}
$LoadedAssemblies = @(); 

$null = [Reflection.Assembly]::Load( "PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35" )

## Dotsource these rather than autoloading because we're guaranteed to need them
. "$($ShowUI.InstallPath)\Core\Add-UIFunction.ps1"
. "$($ShowUI.InstallPath)\Core\Set-DependencyProperty.ps1"
. "$($ShowUI.InstallPath)\Core\Set-UIProperties.ps1"
. "$($ShowUI.InstallPath)\Core\UtilityFunctions.ps1"
. "$($ShowUI.InstallPath)\Core\ContentProperties.ps1"

## Dotsource this because calling it from inside AutoLoad messes with the -Scope value
# . "$($ShowUI.InstallPath)\Core\Export-NamedControl.ps1"

## Autoload these for public consumption if needed
AutoLoad "$($ShowUI.InstallPath)\Core\New-UIImage.ps1" -Alias New-UIImage -Module ShowUI

## TODO: This would be a great function to add, if we could make it ADD instead of SET.
# AutoLoad "$($ShowUI.InstallPath)\New Functions\Add-ChildControl.ps1" Add-ChildControl ShowUI

## Add-EventHandler is deprecated because the compiled Register-UIEvent is a better way
#. "$($ShowUI.InstallPath)\New Functions\Add-EventHandler.ps1"
## TODO: Can Register-UIEvent be an actual PSEvent and still execute on the thread the way I need it to?

## Select-ChildControl (aka: Get-ChildControl) is deprecated because Export-NamedControls is a better way
#. "$($ShowUI.InstallPath)\New Functions\Select-ChildControl.ps1"
## I don't need this one, 'cause I've integrated it into the core! ;)
# . "$($ShowUI.InstallPath)\New Functions\ConvertTo-DataTemplate.ps1"

## TODO: I'm not really sure how these fit in yet
# "$($ShowUI.InstallPath)\Core\ConvertTo-GridLength.ps1"
# "$($ShowUI.InstallPath)\Extras\Enable-Multitouch.ps1"
# "$($ShowUI.InstallPath)\Extras\Export-Application.ps1"

# This is #Requires -STA
$ShowUI.IsSTA  = ([System.Threading.Thread]::CurrentThread.ApartmentState -eq "STA")

## In case they delete the "Deprecated" folder (like I would)...
if(Test-Path "$($ShowUI.InstallPath)\Deprecated\Out-UI.ps1") {
   if( !$ShowUI.IsSTA ) { 
      function Out-UI {
         Write-Error "Out-UI disabled in MTA mode. Use Show-UI instead. (You must run PowerShell with -STA switch to enable Out-UI)"
      }
   } else { # Requires -STA
      AutoLoad "$($ShowUI.InstallPath)\Deprecated\Out-UI.ps1" -Alias Out-UI -Module ShowUI
   }
}


## Autoload all the functions ....
if(!(Get-ChildItem "$($ShowUI.InstallPath)\Types_Generated\New-*.ps1" -ErrorAction SilentlyContinue)) {
   & "$($ShowUI.InstallPath)\Core\Reset-ShowUI.ps1"
}

foreach($script in Get-ChildItem "$($ShowUI.InstallPath)\Types_Generated\New-*.ps1", "$($ShowUI.InstallPath)\Types_StaticOverrides\New-*.ps1" -ErrorAction 0) {
   $TypeName = $script.Name -replace 'New-(.*).ps1','$1'
   
   Set-Alias -Name "$($TypeName.Split('.')[-1])" "New-$TypeName"     -EA "SilentlyContinue" -EV +ErrorList
   AutoLoad -Name $Script.FullName -Alias "New-$TypeName" -Module ShowUI
   # Write-Host -fore yellow $(Get-Command "New-$TypeName" | Out-String)
}

## Extra aliases....
$errorList = @()
## We don't need this work around for the "Grid" alias anymore
## but we preserve compatability by still generating GridPanel (which is what the class ought to be anyway?)
Set-Alias -Name GridPanel  -Value "New-System.Windows.Controls.Grid" -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning """GridPanel"" alias not created, you must use New-System.Windows.Controls.Grid" }

###################
## Backwards compat aliases ...
Set-Alias -Name Boots                  -Value "Show-UI"              -EA "SilentlyContinue" -EV +ErrorList
Set-Alias -Name Write-BootsOutput      -Value "Write-UIOutput"       -EA "SilentlyContinue" -EV +ErrorList
Set-Alias -Name BootsImage             -Value "Out-BootsImage"       -EA "SilentlyContinue" -EV +ErrorList


$errorList = @()
Set-Alias -Name Show                   -Value "Show-UI"              -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "Show alias not created, you must use the full Show-UI function name!" }

$errorList = @()
Set-Alias -Name UIOut                  -Value "Write-UIOutput"       -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "UIOut alias to Show-UI not created!" }

$errorList = @()
Set-Alias -Name UIImage                -Value "Out-UIImage"          -EA "SilentlyContinue" -EV +ErrorList
if($ErrorList.Count) { Write-Warning "UIImage alias not created, you must use the full Out-UIImage function name!" }

Set-Alias -Name obi    -Value "Out-UIImage"                          -EA "SilentlyContinue"
Set-Alias -Name oui    -Value "Out-UIImage"                          -EA "SilentlyContinue"
Set-Alias -Name sdp    -Value "Set-DependencyProperty"               -EA "SilentlyContinue"
Set-Alias -Name gbw    -Value "Get-UI"                               -EA "SilentlyContinue"
Set-Alias -Name gui    -Value "Get-UI"                               -EA "SilentlyContinue"
Set-Alias -Name rbw    -Value "Remove-UI"                            -EA "SilentlyContinue"
Set-Alias -Name rui    -Value "Remove-UI"                            -EA "SilentlyContinue"
                                                    
$ShowUIFunctions = @("Add-UIFunction", "Set-DependencyProperty", "New-*") +
                  @("Get-UIModule", "Get-UIAssemblies", "Get-Parameter", "Get-UIParam" ) + 
                  @("Get-UIContentProperty", "Add-UIContentProperty", "Remove-UIContentProperty") +
                  @("Get-UIHelp", "Get-UICommand", "Out-UIWindow", "New-UIImage") +
                  @("Select-UIElement","Select-ChildControl", "Add-ChildControl", "Add-EventHandler" ) +
                  @("ConvertTo-GridLength", "Enable-MultiTouch", "Export-Application") + 
                  @("Autoloaded", "Export-NamedElement")

Export-ModuleMember -Function $ShowUIFunctions -Cmdlet (Get-Command -Module PoshWpf) -Alias * -Variable "ShowUI"
