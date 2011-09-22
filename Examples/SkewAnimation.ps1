New-Window -Width 200 -Height 200 {
    New-Rectangle -Fill Black -Width 200 -Height 100 -RenderTransform {
        New-SkewTransform -AngleY 89
    } -On_Loaded {
        $da = New-DoubleAnimation -From 89 -To 0 -Duration ([Timespan]::FromMilliseconds(750)) -RepeatBehavior Forever
        Start-Animation -InputObject $this.RenderTransform -Property AngleY -animation $da
    }
} -show
