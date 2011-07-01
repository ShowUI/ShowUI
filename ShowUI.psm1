param(
[ValidateSet('Clean','Normal','DoNothing','OnlyLoadCommonCommands', 'CleanAndDoNothing', 'ResetStyles')]
[string]
$LoadBehavior = 'Normal'
)

#region Cleanup Parameter Handling
 
if ($LoadBehavior -eq 'DoNothing') { return } 

# turn off strict mode for the module context
Set-StrictMode -Off

if ('Clean', 'CleanAndDoNothing', 'ResetStyles') {
    Remove-Item $psScriptRoot\Styles -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
}

if ('Clean', 'CleanAndDoNothing' -contains $LoadBehavior) {
    Remove-Item $psScriptRoot\GeneratedAssemblies -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    Remove-Item $psScriptRoot\GeneratedCode -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
    if ($LoadBehavior -eq 'CleanAndDoNothing') { return } 
}

#endregion


#region Rule Loading
$WinFormsIntegration = "WindowsFormsIntegration, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35"

$Assemblies = [Reflection.Assembly]::LoadWithPartialName("WindowsBase"),
            [Reflection.Assembly]::LoadWithPartialName("PresentationFramework"),
            [Reflection.Assembly]::LoadWithPartialName("PresentationCore"),
            [Reflection.Assembly]::Load($WinFormsIntegration)
#endregion

#region Code Generator Functions
. $psScriptRoot\CodeGenerator\Add-CodeGenerationRule.ps1
. $psScriptRoot\CodeGenerator\ConvertFrom-TypeToCmdlet.ps1
. $psScriptRoot\CodeGenerator\ConvertTo-ParameterMetaData.ps1
#endregion Code Generator Functions

#region WPF functions
. $psScriptRoot\WPF\Add-ChildControl.ps1
. $psScriptRoot\WPF\Add-EventHandler.ps1
. $psScriptRoot\WPF\Add-GridRow.ps1
. $psScriptRoot\WPF\Add-GridColumn.ps1
. $psScriptRoot\WPF\ConvertTo-DataTemplate.ps1
. $psScriptRoot\WPF\ConvertTo-GridLength.ps1
. $psScriptRoot\WPF\ConvertTo-Xaml.ps1
. $psScriptRoot\WPF\Copy-DependencyProperty.ps1
. $psScriptRoot\WPF\Close-Control.ps1
. $psScriptRoot\WPF\Enable-Multitouch.ps1
. $psScriptRoot\WPF\Get-ChildControl.ps1
. $psScriptRoot\WPF\Get-ParentControl.ps1
. $psScriptRoot\WPF\Get-CommonParentControl.ps1
. $psScriptRoot\WPF\Get-ControlPosition.ps1
. $psScriptRoot\WPF\Get-DependencyProperty.ps1   
. $psScriptRoot\WPF\Get-Resource.ps1
. $psScriptRoot\WPF\Hide-UIElement.ps1
. $psScriptRoot\WPF\Initialize-EventHandler.ps1
. $psScriptRoot\WPF\Move-Control.ps1
. $psScriptRoot\WPF\Remove-ChildControl.ps1
. $psScriptRoot\WPF\Set-DependencyProperty.ps1
. $psScriptRoot\WPF\Set-Property.ps1
. $psScriptRoot\WPF\Set-Resource.ps1
. $psScriptRoot\WPF\Show-UIElement.ps1
. $psScriptRoot\WPF\Show-Window.ps1
. $psScriptRoot\WPF\Start-Animation.ps1
. $psScriptRoot\WPF\Test-Ancestor.ps1
. $psScriptRoot\WPF\Test-Descendent.ps1
. $psScriptRoot\WPF\Write-WPFError.ps1

#endregion WPF functions

$script:UIStyles = @{}
. $psScriptRoot\Export-Application.ps1
. $psScriptRoot\Register-PowerShellCommand.ps1

. $psScriptRoot\Get-UIValue.ps1
. $psScriptRoot\Start-PowerShellCommand.ps1
. $psScriptRoot\Start-WPFJob.ps1
. $psScriptRoot\Stop-PowerShellCommand.ps1
. $psScriptRoot\Unregister-PowerShellCommand.ps1
. $psScriptRoot\Update-WPFJob.ps1
. $psScriptRoot\Set-UIValue.ps1

. $psScriptRoot\Get-PowerShellDataSource.ps1
. $psScriptRoot\Get-PowerShellOutput.ps1
. $psScriptRoot\Get-PowerShellCommand.ps1
. $psScriptRoot\Invoke-Background.ps1

if ($LoadBehavior -eq 'OnlyLoadCommonCommands') { return }

$types = . $psScriptRoot\CodeGenerator\InstallShowUIAssembly.ps1


$importPath = "$psScriptRoot\GeneratedAssemblies\ShowUI.CLR$($psVersionTable.clrVersion).dll"
if (Test-Path $importPath) {
    $importedModule= Import-Module $importPath -PassThru
} else {
    $importedModules = $types | Select-Object -ExpandProperty Assembly -Unique | Import-Module
}
## Fix xaml Serialization 
[ShowUI.XamlTricks]::FixSerialization()

$importedCommands = $importedModule.ExportedCommands.Values
$toAlias = $importedCommands | 
    Where-Object {
        $_.Verb -eq 'New'
    }

foreach ($ta in $toAlias) {
    if (-not $ta) { continue } 
    Set-Alias -Name $ta.Noun -Value "$ta"
}

#region Styles
. $psScriptRoot\StyleSystem\Get-UIStyle.ps1
. $psScriptRoot\StyleSystem\Set-UIStyle.ps1
. $psScriptRoot\StyleSystem\Import-UIStyle.ps1

if (-not (Test-Path $psScriptRoot\Styles)) {
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
        On_GotFocus = {
            if ($this.Text -eq $OriginalText) {
                $this.Text = ""
                $this.ClearValue([Windows.Controls.Control]::FontStyleProperty)
            }
        }
    }


    
} else {
    Use-UiStyle "Current"
}


#endregion Styles


#region Common Controls
. $psScriptRoot\CommonControls\Select-Date.ps1
. $psScriptRoot\CommonControls\Select-ViaUI.ps1
. $psScriptRoot\CommonControls\Edit-StringList.ps1
. $psScriptRoot\CommonControls\Get-Input.ps1
#endregion Common Controls

Export-ModuleMember -Cmdlet * -Function * -Alias *
