function Set-UIValue
{    
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Windows.FrameworkElement]    
    $Ui,
    
    [PSObject]
    $Value,
    
    [switch]
    $passThru
    )
    
    begin {
        Set-StrictMode -Off
        function MaybeAddUIProperty {
            param($ui)
            if (-not $DoNotAddUINoteProperty) {
                $newValue = Add-Member -InputObject $newValue NoteProperty UI $Ui -PassThru 
            }
        }
         
    }
    
    process {
        if ($psBoundParameters.ContainsKey('Value')) {
            $ui.Tag = $value
            $Ui.DataContext = $value            
        } else {
            $uiValue = Get-UIValue -Ui $ui
            $ui.Tag = $uiValue
            $ui.DataContext = $uiValue
        }    
        
        if ($passThru) {
            $ui
        }    
    }
}

Set-Alias -Name Write-UIValue -Value Set-UIValue
Set-Alias -Name Write-BootsValue -Value Set-UIValue
Set-Alias -Name Update-UIValue -Value Set-UIValue
