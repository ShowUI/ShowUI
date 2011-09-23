New-Grid -Rows 2 -Columns 2 -On_Loaded {
        Register-PowerShellCommand -name UpdateClock -scriptBlock {
            $stopWatch = Get-ChildControl StopWatch
            $stopWatch.Content = [Datetime]::Now - $stopWatch.Tag
        }
    } {
    New-Label -Name Stopwatch "0:0:0" -ColumnSpan 2
    New-Button -Row 1 -Column 0 S_tart -On_Click {
        $stopwatch.Tag  = Get-Date
        Start-PowerShellCommand "UpdateClock" -interval ([Timespan]::FromMilliseconds(25))
    } 
    New-Button -Row 1 -Column 1 Sto_p -On_Click {
        Stop-PowerShellCommand -name "UpdateClock"  
    }
} -show
