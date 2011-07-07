function Add-GridColumn
{
    <#
        .Synopsis
            Adds a column to an existing grid
        .Description
            Adds a column to an existing grid, and optionally offsets everything past a certain row
        .Example
            Add-GridColumn $grid -column Auto,Auto -index 2
        .Parameter grid
            The Grid control to add columns
        .Parameter column
            The column or columns to add to the grid
        .Parameter index
            The offset within the grid 
        .Parameter passThru  
            If set, will output the columns created     
    #>    
    param(
    [Parameter(Mandatory=$true,
        Position=0)]
    [Windows.Controls.Grid]$grid,
    [Parameter(Mandatory=$true,
        Position=1)]
    [ValidateScript({
        if (ConvertTo-GridLength $_) {
            return $true
        }
        return $false
    })]
    $column,
    
    $index,
    
    [switch]$passThru
    )    
    
    process {    
        $realColumns= @(ConvertTo-GridLength $column)
        foreach ($rc in $realColumns) {        
            $col = New-Object Windows.Controls.ColumnDefinition -Property @{
                Width = $rc
            }
            $null = $grid.ColumnDefinitions.Add($col)
            if ($passThru) { $col } 
        }
        if ($psBoundParameters.ContainsKey("Index")) {
            foreach ($c in $grid.Children) {
                $controlColumn = $c.GetValue([Windows.Controls.Grid]::ColumnProperty)
                if ($controlColumn -ge $index) {
                    $c.SetValue(
                        [Windows.Controls.Grid]::ColumnProperty, 
                        [Int]($controlColumn + $realColumns.Count)
                    )                    
                }
            }
        }               
    }
}
