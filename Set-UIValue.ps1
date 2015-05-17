function Set-UIValue {
    #.Synopsis
    #   Set the UI value
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
        if($ui) {
            if (!$psBoundParameters.ContainsKey('Value')) {
                $Value = Get-UIValue -Ui $ui
            }
            # For backwards compatibility with people's hacks.
            $Ui.Tag = $value
            $Ui.DataContext = $value
            # The new way:
            if($Value -is [ScriptBlock]) {
                Add-Member -InputObject $Ui ScriptProperty ShowUIValue $Value -Force
            } else {
                Add-Member -InputObject $Ui NoteProperty ShowUIValue $Value -Force
            }
        }
        if ($passThru) {
            $Ui
        }    
    }
}

Set-Alias -Name Write-UIValue -Value Set-UIValue
Set-Alias -Name Write-BootsValue -Value Set-UIValue
Set-Alias -Name Update-UIValue -Value Set-UIValue
