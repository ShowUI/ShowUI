function Write-UIOutput
{    
    param(
    [Parameter(ValueFromPipeline=$true, Position=0)]
    [PSObject]
    $Value,
    
    [Windows.FrameworkElement]
    $Ui = $Window,
    
    [switch]
    $passThru
    )
    
    begin {
        if($ui.Tag -and $ui.Tag -isnot [System.Collections.IList]) {
            $ui.Tag = New-Object System.Collections.ArrayList (,@($ui.Tag))
        } elseif(!$ui.Tag) {
            $ui.Tag = New-Object System.Collections.ArrayList
        }
    }

    process {
        if ($psBoundParameters.ContainsKey('Value')) {
            $null = $ui.Tag.Add( $value )
            $Ui.DataContext = $value            
        } else {
            $uiValue = Get-UIValue -Ui $ui
            $null = $ui.Tag.Add( $uiValue )
            $ui.DataContext = $uiValue
        }    
        
        if ($passThru) {
            $ui
        }    
    }
}
