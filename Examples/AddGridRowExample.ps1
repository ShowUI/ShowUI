New-Window -Width 640 -Height 480 {
    New-Grid -Rows 2 -Columns 2 -ShowGridLines {
        New-Button -Row 0 -Column 0 -On_Click {
            $addingRow = $true, $false | Get-Random
            if ($addingRow) {
                Add-GridRow $this.Parent -row 1 -index 0 
            } else {            
                Add-GridColumn $this.Parent -column 1 -index 0
            }
        }
    }
} -show