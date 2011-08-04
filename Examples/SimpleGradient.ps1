New-Canvas -Width 400 -Height 400 -Background {
    New-LinearGradientBrush -SpreadMethod Pad -StartPoint "0,0" -EndPoint "1,1" { 
        New-GradientStop -Color "White" -Offset .1
        New-GradientStop -Color "AliceBlue" -Offset .2
        New-GradientStop -Color "Blue" -Offset .9
    }
} -show
