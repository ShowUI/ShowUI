## A really fancy clock
Import-Module ShowUI -FOrce
New-UIWidget -AsJob -Content {
    $shadow = DropShadowEffect -Color Black -Shadow 0 -Blur 8
    $now = Get-Date;
    StackPanel {
        TextBlock -Name "Time" ('{0:h:mm tt}' -f $now) -FontSize 108 -LineHeight 100 -LineStackingStrategy BlockLineHeight -Margin 0 -Padding 0 -Foreground White -Effect $shadow -FontFamily "Century Gothic"
        StackPanel -Orientation Horizontal {
            TextBlock -Name "Day" ('{0:dd}' -f $now) -FontSize 80 -LineHeight 80 -LineStackingStrategy BlockLineHeight -Margin 0 -Padding 0 -Foreground White -Opacity 0.6 -Effect $shadow -FontFamily "Century Gothic"
            StackPanel {
                TextBlock -Name "Month" ('{0:MMMM}' -f $now).ToUpper() -fontsize 40 -LineHeight 40 -LineStackingStrategy BlockLineHeight -Margin 0 -Padding 0 -FontFamily "Century Gothic"
                TextBlock -Name "Weekday" ('{0:dddd}' -f $now).ToUpper() -fontsize 28 -LineHeight 28 -LineStackingStrategy BlockLineHeight -Margin 0 -Padding 0 -Foreground White -Effect $shadow -FontFamily "Century Gothic"
            } -Margin 0
        } -Margin 0
    } -Margin 0
} -Interval "0:0:0.2" -UpdateBlock {
    $now = Get-Date

    $Time.Text    =  '{0:h:mm tt}' -f $now
    $Day.Text     =  '{0:dd}'   -f $now
    $Month.Text   = ('{0:MMMM}' -f $now).ToUpper()
    $Weekday.Text = ('{0:dddd}' -f $now).ToUpper()
}



## And a slick weather widget using Yahoo's forecast and images
New-UIWidget -AsJob { 
    Grid {
        Rectangle -RadiusX 10 -RadiusY 10 -StrokeThickness 0 -Width 170 -Height 80 -HorizontalAlignment Left -VerticalAlignment Top -Margin "60,40,0,0" -Fill { 
            LinearGradientBrush -Start "0.5,0" -End "0.5,1" -Gradient {
                GradientStop -Color "#FF007bff" -Offset 0
                GradientStop -Color "#FF40d6ff" -Offset 1
            }
        }
        Image -Name Image -Stretch Uniform -Width 250.0 -Height 180.0 -Source "http://l.yimg.com/a/i/us/nws/weather/gr/31d.png"
        TextBlock -Name Temp -Text "99°" -FontSize 80 -Foreground White -Margin "130,0,0,0" -Effect { DropShadowEffect -Color Black -Shadow 0 -Blur 8 }
        TextBlock -Name Forecast -Text "Forecast" -FontSize 12 -Foreground White -Margin "120,95,0,0"
    }
} -Refresh "00:10" {
    # To find your WOEID, browse or search for your city from the Weather home page. 
    # The WOEID is the LAST PART OF the URL for the forecast page for that city. 
    $woEID = 14586
    $channel = ([xml](New-Object Net.WebClient).DownloadString("http://weather.yahooapis.com/forecastrss?p=$woEID")).rss.channel
    $h = ([int](Get-Date -f hh))
    
    if($h -gt ([DateTime]$channel.astronomy.sunrise).Hour -and $h -lt ([DateTime]$channel.astronomy.sunset).Hour) {
        $dayOrNight = 'd'
    } else {
        $dayOrNight = 'n'
    }
    $source = "http`://l.yimg.com/a/i/us/nws/weather/gr/{0}{1}.png" -f $channel.item.condition.code, $dayOrNight
    
    $Image.Source  = $source
    $Temp.Text     = $channel.item.condition.temp + [char]176
    $Forecast.Text = "High: {0}{2} Low: {1}{2}" -f $channel.item.forecast[0].high, $channel.item.forecast[0].low, [char]176
}

## An analog clock with "hands" and an old-school ticking motion.
New-UIWidget -AsJob -Content { 
    $shadow = DropShadowEffect -Color Black -Shadow 0 -Blur 8
   Grid {
      Ellipse -Fill Transparent -Stroke Black -StrokeThickness 4  -Width 300 -Height 300 
      Ellipse -Fill Transparent -Stroke Black -StrokeThickness 6  -Width 290 -Height 290 -StrokeDashArray 1,11.406
      Ellipse -Fill Transparent -Stroke Black -StrokeThickness 10 -Width 280 -Height 280 -StrokeDashArray 64.25
      Ellipse -Fill Transparent -Stroke Black -StrokeThickness 5  -Width 255 -Height 255 -StrokeDashArray 60,59
      Ellipse -Name Hour -Fill Transparent -Stroke White -StrokeThickness 100 -Width 255 -Height 255 -StrokeDashArray 0.04,300 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 } -Effect $shadow 
      Ellipse -Name Minute -Fill Transparent -Stroke '#FFC0B7B7' -StrokeThickness 100 -Width 275 -Height 275 -StrokeDashArray 0.05,300 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 } -Effect $shadow 
      Ellipse -Name Second -Fill Transparent -Stroke '#FF31C2FF' -StrokeThickness 100 -Width 215 -Height 215 -StrokeDashArray 0.02,300 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 } -Effect $shadow 
    }
} -Refresh "00:00:00.2" -Update { 
   $now = Get-Date
   $deg = (1/60) * 360
   
   $Hour.RenderTransform.Angle = $now.Hour * 5 * $deg -90
   $Minute.RenderTransform.Angle = $now.Minute * $deg -90
   $Second.RenderTransform.Angle = $now.Second * $deg -90
}

## A variation on the target clock, without the smooth animated "quartz movement"
New-UIWidget { 
   Grid {
      $shadow = DropShadowEffect -ShadowDepth 0 -BlurRadius 5 -Direction 0
      Ellipse -Name Hour   -Fill Transparent -Stroke Black -StrokeThickness 100 -Width 350 -Height 350 -StrokeDashArray 7.85,7.85 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
      Ellipse -Name Minute -Fill Transparent -Stroke Gray -StrokeThickness 75 -Width 325 -Height 325 -StrokeDashArray 10.468,10.468 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
      Ellipse -Name Second -Fill Transparent -Stroke White -StrokeThickness 50 -Width 300 -Height 300 -StrokeDashArray 15.71,15.71 -RenderTransformOrigin "0.5,0.5" -RenderTransform { RotateTransform -Angle -90 }
   }
} -Refresh "00:00:00.2" { 
   $now = Get-Date
   $Hour.StrokeDashArray[0]   = $Hour.StrokeDashArray[1]/60 * $now.Hour * 5
   $Minute.StrokeDashArray[0] = $Minute.StrokeDashArray[1]/60 * $now.Minute
   $Second.StrokeDashArray[0] = $Second.StrokeDashArray[1]/60 * $now.Second
}






#  New-BootsGadget { 
   #  label "hh:mm" -fontsize 24 -Effect {DropShadowEffect -Color White -Shadow 0 -Blur 8}
#  } -Refresh "00:00:00.5" { 
   #  $this.Tag.Content.Content = Get-Date -f 'h:mm'
#  } -Title "Clock" -Topmost
