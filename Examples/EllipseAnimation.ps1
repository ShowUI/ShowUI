New-Window -Width 200 -Height 200 {
    New-Ellipse -Fill Black -Width 200 -Height 100 -RenderTransform { 
        New-RotateTransform -CenterX 75 -CenterY 50
    } -On_Loaded {
        $da = New-DoubleAnimation -From 0 -To 360 -Duration ([Timespan]::FromMilliseconds(750)) -RepeatBehavior Forever
        Start-Animation -InputObject $this.RenderTransform -Property Angle -animation $da
    }
} -show
