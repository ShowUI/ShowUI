param(
[ValidateSet('CleanCore','Clean','Normal','DoNothing','OnlyLoadCommonCommands', 'CleanAndDoNothing', 'ResetStyles', 'BuildLocal')]
[string]
$LoadBehavior = 'Normal'
)

$ShowUIModuleRoot = (Get-Variable PSScriptRoot).Value
# We're storing our generated code in a shared, writeable, location now
$CacheModuleRoot = if($LoadBehavior -eq "BuildLocal") { $ShowUIModuleRoot } else { "${Env:ProgramData}\ShowUI" }
$ClrVersion = "" + $PSVersionTable.CLRVersion.Major + "." + $PSVersionTable.CLRVersion.Minor

$LocalCommandsPath = "$ShowUIModuleRoot\GeneratedModules\ShowUI.CLR${ClrVersion}.psm1"
$LocalCoreOutputPath = "$ShowUIModuleRoot\GeneratedModules\ShowUICore.CLR${ClrVersion}.dll"

$CommandsPath = "$CacheModuleRoot\GeneratedModules\ShowUI.CLR${ClrVersion}.psm1"
$CoreOutputPath = "$CacheModuleRoot\GeneratedModules\ShowUICore.CLR${ClrVersion}.dll"

#region Cleanup Parameter Handling
if ($LoadBehavior -eq 'DoNothing') { return }

# turn off strict mode for the module context
Set-StrictMode -Off
if ('Clean', 'CleanCore', 'CleanAndDoNothing', 'ResetStyles' -contains $LoadBehavior) {
    Remove-Item $CacheModuleRoot\Styles -Recurse -Force -ErrorAction SilentlyContinue
}
# If they said CleanCore not CleanAll, then leave the Commands in place
if('CleanCore' -eq $LoadBehavior) {
    $exclude = "ShowUI.CLR$($psVersionTable.clrVersion)*"
}
if ('Clean', 'CleanCore', 'CleanAndDoNothing' -contains $LoadBehavior) {
    Get-ChildItem $CacheModuleRoot\GeneratedModules -Force -Recurse -Exclude $exclude -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
    Get-ChildItem $CacheModuleRoot\GeneratedCode  -Recurse -Force -Exclude $exclude -ErrorAction SilentlyContinue |
        Remove-Item -Force -ErrorAction SilentlyContinue
    if ($LoadBehavior -eq 'CleanAndDoNothing') { return } 
}

#endregion

#region Assembly Loading
$Assemblies = 
[Reflection.Assembly]::Load("WindowsBase, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
[Reflection.Assembly]::Load("PresentationFramework, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
[Reflection.Assembly]::Load("PresentationCore, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
[Reflection.Assembly]::Load("WindowsFormsIntegration, Version=4.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"),
[Reflection.Assembly]::Load("System.Xaml, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
try {
    $Assemblies += [Reflection.Assembly]::Load("System.Windows.Controls.Ribbon, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089")
} catch {}
#endregion

#region Code Generator Functions
# We need to be able to generate code ...
. $ShowUIModuleRoot\CodeGenerator\Add-CodeGenerationRule.ps1
. $ShowUIModuleRoot\CodeGenerator\Add-UiModule.ps1
. $ShowUIModuleRoot\CodeGenerator\Select-UiType.ps1
. $ShowUIModuleRoot\CodeGenerator\Get-AssemblyName.ps1
. $ShowUIModuleRoot\CodeGenerator\ConvertFrom-TypeToCmdlet.ps1
. $ShowUIModuleRoot\CodeGenerator\ConvertTo-ParameterMetaData.ps1
. $ShowUIModuleRoot\CodeGenerator\Rules\WPFCodeGenerationRules.ps1
#endregion Code Generator Functions

#region WPF functions
. $ShowUIModuleRoot\WPF\Add-ChildControl.ps1
. $ShowUIModuleRoot\WPF\Add-EventHandler.ps1
. $ShowUIModuleRoot\WPF\Add-GridRow.ps1
. $ShowUIModuleRoot\WPF\Add-GridColumn.ps1
. $ShowUIModuleRoot\WPF\ConvertTo-DataTemplate.ps1
. $ShowUIModuleRoot\WPF\ConvertTo-GridLength.ps1
. $ShowUIModuleRoot\WPF\ConvertTo-Xaml.ps1
. $ShowUIModuleRoot\WPF\Copy-DependencyProperty.ps1
. $ShowUIModuleRoot\WPF\Close-Control.ps1
. $ShowUIModuleRoot\WPF\Enable-Multitouch.ps1
. $ShowUIModuleRoot\WPF\Get-ChildControl.ps1
. $ShowUIModuleRoot\WPF\Get-ParentControl.ps1
. $ShowUIModuleRoot\WPF\Get-CommonParentControl.ps1
. $ShowUIModuleRoot\WPF\Get-ControlPosition.ps1
. $ShowUIModuleRoot\WPF\Get-DependencyProperty.ps1   
. $ShowUIModuleRoot\WPF\Get-Resource.ps1
. $ShowUIModuleRoot\WPF\Hide-UIElement.ps1
. $ShowUIModuleRoot\WPF\Initialize-EventHandler.ps1
. $ShowUIModuleRoot\WPF\Move-Control.ps1
. $ShowUIModuleRoot\WPF\Remove-ChildControl.ps1
. $ShowUIModuleRoot\WPF\Set-DependencyProperty.ps1
. $ShowUIModuleRoot\WPF\Set-WpfProperty.ps1
. $ShowUIModuleRoot\WPF\Set-Resource.ps1
. $ShowUIModuleRoot\WPF\Show-UIElement.ps1
. $ShowUIModuleRoot\WPF\Show-Window.ps1
. $ShowUIModuleRoot\WPF\Show-UI.ps1
. $ShowUIModuleRoot\WPF\Start-Animation.ps1
. $ShowUIModuleRoot\WPF\Test-Ancestor.ps1
. $ShowUIModuleRoot\WPF\Test-Descendent.ps1
. $ShowUIModuleRoot\WPF\Write-WPFError.ps1
. $ShowUIModuleRoot\WPF\Out-Xaml.ps1

#endregion WPF functions

$script:UIStyles = @{}
. $ShowUIModuleRoot\Export-Application.ps1
. $ShowUIModuleRoot\Register-PowerShellCommand.ps1

. $ShowUIModuleRoot\New-UIWidget.ps1
. $ShowUIModuleRoot\Get-UIValue.ps1
. $ShowUIModuleRoot\Start-PowerShellCommand.ps1
. $ShowUIModuleRoot\Start-WPFJob.ps1
. $ShowUIModuleRoot\Stop-PowerShellCommand.ps1
. $ShowUIModuleRoot\Unregister-PowerShellCommand.ps1
. $ShowUIModuleRoot\Update-WPFJob.ps1
. $ShowUIModuleRoot\Set-UIValue.ps1
. $ShowUIModuleRoot\Write-Program.ps1

. $ShowUIModuleRoot\Get-PowerShellDataSource.ps1
. $ShowUIModuleRoot\Get-PowerShellOutput.ps1
. $ShowUIModuleRoot\Get-PowerShellCommand.ps1
. $ShowUIModuleRoot\Invoke-Background.ps1
. $ShowUIModuleRoot\Get-ReferencedCommand.ps1
. $ShowUIModuleRoot\Get-UICommand.ps1

. $ShowUIModuleRoot\ConvertTo-ISEAddOn.ps1

if ($LoadBehavior -eq 'OnlyLoadCommonCommands') { return }

# If it exists, import it
if ((Test-Path $CommandsPath, $CoreOutputPath) -notcontains $False) {
    $importedModule = Import-Module $CommandsPath, $CoreOutputPath -PassThru
# if not, check the local location
} elseif ((Test-Path $LocalCommandsPath, $LocalCoreOutputPath) -notcontains $False) {
    $importedModule = Import-Module $LocalCommandsPath, $LocalCoreOutputPath -PassThru
# Otherwise, generate it
} else {
    # Pass Parameters so we don't have to calculate them twice
    . $ShowUIModuleRoot\CodeGenerator\InstallShowUIAssembly.ps1 `
        -OutputPathBase "$CacheModuleRoot\GeneratedModules\" `
        -CommandPath $CommandsPath `
        -CoreOutputPath $CoreOutputPath `
        -Assemblies $Assemblies `
        -Force:$($LoadBehavior -eq 'CleanAll')

    if ($CoreOutputPath -like "\\*" -or $commandsPath -like "\\*") {
        $tempOutputPath = Join-Path $env:Temp (Split-Path -Leaf $CoreOutputPath)
        $tempCommandsPath= Join-Path $env:Temp (Split-Path -Leaf $commandsPath)
        Copy-Item -LiteralPath $CoreOutputPath -Destination $tempOutputPath -Force
        Copy-Item -LiteralPath $commandsPath -Destination $tempCommandsPath -Force
        $importedModule  = Import-Module $tempOutputPath, $tempCommandsPath -PassThru
    } else {
        $importedModule  = Import-Module $CommandsPath, $CoreOutputPath -PassThru
    }
    
    attrib "$CacheModuleRoot\GeneratedModules" +h /d /s
    attrib "$CacheModuleRoot\GeneratedCode" +h /d /s
    attrib "$CacheModuleRoot\Styles" +h /d /s
}
## Fix xaml Serialization 
[ShowUI.XamlTricks]::FixSerialization()

## Generate aliases for all the New-* cmdlets
## Ideally, with the module name on it: ShowUI\New-Whatever
[String]$ModulePath = $ExecutionContext.SessionState.Module.Name + "\"
if($ModulePath.Length -le 1) { $ModulePath = "" }
$importedCommands = @()
foreach($m in @($importedModule)) {
    $importedCommands += $m.ExportedCommands.Values
    foreach($ta in $importedCommands | Where-Object { $_.Verb -eq 'New' }) {
        Set-Alias -Name $ta.Noun -Value "$ModulePath$ta"
    }
}

#region Styles
. $ShowUIModuleRoot\StyleSystem\Get-UIStyle.ps1
. $ShowUIModuleRoot\StyleSystem\Set-UIStyle.ps1
. $ShowUIModuleRoot\StyleSystem\Import-UIStyle.ps1

if (-not (Test-Path $CacheModuleRoot\Styles\*)) {
    Set-UIStyle -StyleName "Hyperlink" -Style @{
        Resource = @{
                AllowedSchemes = 'http','https'
            }
            Foreground = 'DarkBlue'
            TextDecorations = { 
                 [Windows.TextDecorations]::Underline
            }
            On_PreviewMouseDown = {
                if ($this.Resources.Url) {
                    $realUrl = [Uri]$this.Resources.Url
                    $allowedSchemes = $this.Resources.AllowedSchemes
                    if (-not $allowedSchemes) { $allowedSchemes = 'http', 'https' }
                    if ($allowSchemes -contains $realUrl.Scheme) {
                        Start-Process -FilePath $realUrl 
                    }
                }
            }
    }

    Set-UIStyle -StyleName Bold -Style @{
        FontWeight = 'Bold'
    }

    Set-UIStyle -StyleName BoldItalic -Style @{
        FontWeight = 'Bold'
        FontStyle = 'Italic'
    }

    Set-UIStyle -StyleName SmallText -Style @{
        FontSize = 9
    }

    Set-UIStyle -StyleName MediumText -Style @{
        FontSize = 14
    }

    Set-UIStyle -StyleName LargeText -Style @{
        FontSize = 18
    }

    Set-UIStyle -StyleName HugeText -Style @{
        FontSize = 32
    }

    Set-UIStyle -StyleName ErrorStyle -Style @{
        Foreground = 'DarkRed'
        TextDecorations = { [Windows.TextDecorations]::Underline }
    }

    Set-UIStyle -StyleName "CueText" -Style @{
        On_Loaded = {
            $this.Resources.OriginalText =  $this.Text
        }
        FontStyle = "Italic"
        Foreground = "DarkGray"
        On_GotFocus = {
            if ($this.Text -eq $OriginalText) {
                $this.Text = ""
            }
            $this.ClearValue([Windows.Controls.Control]::ForegroundProperty)
            $this.ClearValue([Windows.Controls.Control]::FontStyleProperty)
        }
        On_LostFocus = {
            if($this.Text -eq "") {
                $this.Text = $OriginalText   
            }
            if ($this.Text -eq $OriginalText) {
                $this.Foreground = "DarkGray"
                $this.FontStyle = "Italic"
            } else {
                $this.ClearValue([Windows.Controls.Control]::ForegroundProperty)
                $this.ClearValue([Windows.Controls.Control]::FontStyleProperty)
            }
        }
    }
    
    Set-UIStyle -StyleName "Widget" -Style @{
        AllowsTransparency = $true
        WindowStyle = "None"
        Background = "Transparent"
        SizeToContent = "WidthAndHeight"
        ResizeMode = "NoResize"
    }
    
} else {
    Use-UiStyle "Current"
}


#endregion Styles


#region Common Controls
. $ShowUIModuleRoot\CommonControls\Select-Date.ps1
. $ShowUIModuleRoot\CommonControls\Edit-StringList.ps1
. $ShowUIModuleRoot\CommonControls\Get-Input.ps1
. $ShowUIModuleRoot\CommonControls\Show-Clock.ps1
. $ShowUIModuleRoot\CommonControls\Select-ViaUI.ps1
#endregion Common Controls

Export-ModuleMember -Cmdlet * -Function * -Alias *
