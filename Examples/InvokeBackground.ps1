Grid -Rows 2 -ControlName Progression -Margin 5 -MinWidth 250 {
    ProgressBar -name progress -height 28 -maximum 100 -Margin "0,0,0,5"
    Label -name report -zindex 1 -background Transparent
        # -DataBinding @{ "Value" = "LastProgress.PercentComplete" }
    Button "Click" -Name "Click" -Row 1 -on_Click {
        $this.IsEnabled = $false
        $window.Cursor = "Wait"
        Invoke-Background -Scriptblock { 
            1..10 | % {
                sleep -milli 200  # imagine this was doing real work
                write-progress -percent ($_ * 10) -activity "Super"
            }
        } -On_Progress { 
            # Write-Host ($this.DataContext.LastProgress |Out-String)
            if($this.DataContext.LastProgress.RecordType -ne "Completed") {
                $progress.Value = $this.DataContext.LastProgress.PercentComplete
                $report.Content  = "{0}%" -f $this.DataContext.LastProgress.PercentComplete
            }
        } -On_IsFinishedChanged {
            if($this.DataContext.IsFinished) {
                $progress.Value = $progress.Maximum
                $window.Cursor = "Arrow"
                $Click.IsEnabled = $true
            }                
        }
    }
} -show

