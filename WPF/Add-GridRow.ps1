function Add-GridRow
{
    <#
        .Synopsis
            Adds a row to an existing grid
        .Description
            Adds a row to an existing grid, and optionally offsets everything past a certain row
        .Example
            Add-GridRow $grid -row Auto,Auto -index 2
        .Parameter grid
            The Grid control to add rows
        .Parameter row
            The row or rows to add to the grid
        .Parameter index
            The offset within the grid 
        .Parameter passThru  
            If set, will output the rows created     
    #>    
    param(
    [Parameter(Mandatory=$true,Position=0)]
    [Windows.Controls.Grid]$grid,
    [Parameter(Mandatory=$true,Position=1)]
    [ValidateScript({
        if (ConvertTo-GridLength $_) {
            return $true
        }
        return $false
    })]
    $row,    
    $index,
    [switch]$passThru
    )    
    
    process {    
        $realRows = @(ConvertTo-GridLength $row)
        foreach ($rr in $realRows) {
            $r = New-Object Windows.Controls.RowDefinition -Property @{
                    Height = $rr
            }
            $null = $grid.RowDefinitions.Add($r)
            if ($passThru) { $r } 
        }
        if ($psBoundParameters.ContainsKey("Index")) {
            foreach ($c in $grid.Children) {
                $controlRow = $c.GetValue([Windows.Controls.Grid]::RowProperty)
                if ($controlRow -ge $index) {
                    $c.SetValue(
                        [Windows.Controls.Grid]::RowProperty, 
                        [Int]($controlRow + $realRows.Count)
                    )                    
                }
            }
        }               
    }
}
