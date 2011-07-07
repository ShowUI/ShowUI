function Update-ControlOutput
{    
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Windows.FrameworkElement]    
    $Ui,
    
    [PSObject]
    $Value
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
            $ui.Tag = Get-UIValue -Ui $ui
            $ui.DataContext = Get-UIValue -Ui $ui            
        }        
    }
}

Set-Alias -Name Write-UIValue -Value Update-ControlOutput
Set-Alias -Name Write-BootsValue -Value Update-ControlOutput
