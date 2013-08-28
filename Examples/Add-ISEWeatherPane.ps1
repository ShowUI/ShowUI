
ConvertTo-ISEAddOn -DisplayName "Weather" -ScriptBlock {
    $zip=14586
    $celsius = $false

    $url = "http`://weather.yahooapis.com/forecastrss?p={0}{1}" -f $zip, $(if($celcius){"&u=c"})
    $channel = ([xml](New-Object Net.WebClient).DownloadString($url)).rss.channel

    function Get-TempColorRun ($temp, [switch]$celcius) {
        if($celcius) { 
            Run -Text "$temp C" -Foreground $( if( $temp -lt 0 ) { "blue" } elseif( $temp -le 10 ) { "cyan" } elseif( $temp -le 21 ) { "blue" } elseif( $temp -lt 27 ) { "green" } else { "red" } )
        } else { 
            Run -Text "$temp C" -Foreground $( if( $temp -lt 5 ) { "blue" } elseif( $temp -le 50 ) { "cyan" } elseif( $temp -le 70 ) { "blue" } elseif( $temp -lt 80 ) { "green" } else { "red" } )
        }
    }

    function Get-ForecastPanel {
    param($forecast,[switch]$celcius)
        StackPanel -VerticalAlignment Top -Margin "6,2,6,2" -ToolTip $forecast.text {
            Image -Source "http://image.weather.com/web/common/wxicons/52/$($forecast.code).png" -Stretch Uniform # Width="{{Binding Source.PixelWidth,RelativeSource={{RelativeSource Self}}}}" Height="{{Binding Source.PixelHeight,RelativeSource={{RelativeSource Self}}}}" />
            TextBlock -TextAlignment Center { 
                Run -FontWeight 700 -Text $forecast.day
                LineBreak
                Get-TempColorRun $forecast.low -celcius:$celcius
                " - "
                Get-TempColorRun $forecast.high -celcius:$celcius
            }
        }
    }



    StackPanel {
        TextBlock -FontFamily Constantia -FontSize 12pt { "{0}, {1} {2}" -f $channel.location.city,  $channel.location.region, $channel.lastBuildDate }
        StackPanel -Orientation Horizontal {
            StackPanel -VerticalAlignment Top -Margin "6,2,6,2" -ToolTip $channel.item.condition.text {
                Image -Source "http://image.weather.com/web/common/wxicons/52/$($channel.item.condition.code).png" -Stretch Uniform #-Width {Binding Source.PixelWidth -RelativeSource=$this} -Height {Binding Source.PixelHeight -RelativeSource=$this}
                TextBlock -TextAlignment Center { 
                    Run -FontWeight 700 -Text "Currently"
                    LineBreak
                    Get-TempColorRun $channel.item.condition.temp -celcius:$celcius
                }
            }
            Get-ForecastPanel $channel.item.forecast[0] -celcius:$celcius
            Get-ForecastPanel $channel.item.forecast[1] -celcius:$celcius
        }
    } 
}  -AddHorizontally -Visible
