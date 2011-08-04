New-Grid -ControlName ToggleExample -Rows (@('Auto')*5) -Columns (@('Auto')*5) -On_Loaded {
    foreach ($n in (1..25)) {
        [int]$row = [Math]::Floor(($n  -1)/ $toggleExample.RowDefinitions.Count)
        [int]$column = ($n - 1)% $toggleExample.ColumnDefinitions.Count
        New-ToggleButton $n -Row $row -Column $column -Width 100 -Height 100 -On_Checked { 
            $uid = $This.Uid.Tostring()
            $parent | 
                Get-ChildControl -OnlyDirectChildren | 
                Where-Object { 
                    $_.Uid -ne $this.Uid
                } |
                Move-Control -fadeOut -duration "0:0:2"
        } -On_Unchecked {
            $parent | 
                Get-ChildControl -OnlyDirectChildren | 
                Where-Object { 
                    $_.Uid -ne $this.Uid
                } |
                Move-Control -fadeIn -duration "0:0:2"
        } | Add-ChildControl -parent $this
    }
} -show