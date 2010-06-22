Param([int[]]$which=0)

   $null = [Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")  # To get the Double-Click time

   function global:New-GraphLabel {
      PARAM ( 
         [String]$Label = "Name", 
         [String]$Value = "Length", 
         [ScriptBlock]$DoubleClickAction = $null, 
         [Int]$max = $null, 
         [Int]$width = 200, 
         [double]$margin = 2,
         [Int]$DoubleClickTime = $([System.Windows.Forms.SystemInformation]::DoubleClickTime),
         $InputObject
      )
      BEGIN { $maxx = $max; $global:DoubleClickTime = $DoubleClickTime }
      PROCESS {
         if($_){ $InputObject = $_ }
         if(!$maxx){ $maxx=@($InputObject)[0].$Value }

         foreach($io in $InputObject) {
            ## This is the core part of the script ...
            ## For each input, generate a grid panel with a label and a rectangle in the background
         
            GridPanel -tag @{item=$io; action=$DoubleClickAction} -width $Width -margin $margin $( 
               Label $io.$Label 
               Rectangle -HorizontalAlignment Left -Fill "#9F00" `
                         -Width ($Width * ($io."$Value" / $maxx))
            ) -On_MouseLeftButtonDown {
               if($this.Tag.Action) { # They passed in a doubleclick action, so lets handle it
                  if($global:ClickTime -and 
                     ([DateTime]::Now - $ClickTime).TotalMilliseconds -lt $DoubleClickTime) {
                     # We invoke the scriptblock 
                     # and pass it the original input object 
                     # and the grid panel object
                     &$This.Tag.Action $this.Tag.Item $this
                  } else {
                     $global:ClickTime = [DateTime]::Now
                  }
               }
            }
         }
      }
   }
   Set-Alias GraphLabel New-GraphLabel -Scope Global
   
   if(gcm Microsoft.PowerShell.Utility\Get-Random -EA 0) {
      Set-Alias Get-Random Microsoft.PowerShell.Utility\Get-Random -ErrorAction SilentlyContinue -Option AllScope
   } else { 
      $global:randor = new-object random
      function global:Get-Random([int]$min,[int]$max=$([int]::MaxValue)){
         if($min) {
            $global:randor.Next($min,$max)
         } else {
            $global:randor.Next($max)
         }
      }
   }
   
switch($which) {
0 { 
@"
This script just runs the various demo scripts I've written to test Boots.
You need to pass it a number (between 1 and 29) for the samples you want to run!
"@
}
1 {
   New-BootsWindow -SizeToContent WidthAndHeight -Content {
      Button -Content "Push Me" 
   }
}
2 {
   Boots { Button -Content "Push Me" }
}
3 { 
   Boots {
      StackPanel {
         Button "A bed of clams"
         Button "A coalition of cheetas"
         Button "A gulp of swallows"
      }
   }
}
4 {
   Boots { "A bed of clams", "A coalition of cheetas", "A gulp of swallows" | Button | StackPanel }
}
5 {
   Boots { "A bed of clams", "A coalition of cheetas", "A gulp of swallows" | Label | StackPanel | Button }
}
6 {
   Boots {
      StackPanel -Margin 5 -Background Pink {
         Button -Margin 2 "A bed of clams"
         Button -Margin 2 "A coalition of cheetas"
         Button -Margin 2 "A gulp of swallows"
      }
   }
}
7 {
   Boots { "A bed of clams", "A coalition of cheetas", "A gulp of swallows" | Button -Margin 2 | StackPanel -Margin 5 -Background Pink }
}
8 {
   Boots { Ellipse -Width 60 -Height 80 -Margin "20,10,60,20" -Fill Black }
}
9 {
   Boots {
      Canvas -Height 100 -Width 100 -Children $(
         Rectangle -Margin "10,10,0,0" -Width 45 -Height 45 -Stroke Purple -StrokeThickness 2 -Fill Red
         Polygon -Stroke Pink -StrokeThickness 2 -Fill DarkRed -Points "10,60", "50,60", "50,50", "65,65",
                                                                       "50,80", "50,70", "10,70", "10,60" 
      )
   }
}
10 {
   Boots {
      Image -Source http://huddledmasses.org/images/PowerBoots/IMG_3298.jpg -MaxWidth 400 | 
   } -Title "Now those are some powerful boots!" -Async
}
11 {
   Boots {
      StackPanel -Margin 10 -Children $(
         TextBlock "A Question" -FontSize 42 -FontWeight Bold -Foreground "#FF0088" 
         TextBlock -FontSize 24 -Inlines $(
            Bold "Q. "
            "Are you starting to dig "
            Hyperlink "PowerBoots?" -NavigateUri http://huddledmasses.org/tag/powerboots/ `
                                    -On_RequestNavigate { [Diagnostics.Process]::Start( $this.NavigateUri ) }
         )
         TextBlock -FontSize 16 -Inlines $(
            Span -FontSize 24 -FontWeight Bold -Inlines "A. "
            "Leave me alone, I'm hacking here!"
         )
      )
   }
}
12 {
   Boots { 
      $global:Count = 0
      WrapPanel {
         Button "Push Me" -On_Click {
            # Export-NamedElement
            $script:Count++
            $clickLabel.Content = "You clicked the button ${script:Count} times!"
         }
         Label "Nothing pushed so far" -Name clickLabel
      }
   } -Title "Test App" -On_Closing { $global:BootsOutput = $script:Count; rm variable:Count } -Export
}
13 {
   Boots {
      WrapPanel -On_Load { $Count = 0 }  {
         Button "Push Me" -On_Click {
            Export-NamedElement
            Write-BootsOutput (++$count)
            $output.Inlines.Clear(); 
            $output.Inlines.Add("You clicked the button $count times!") 
         }
         TextBlock "Nothing pushed so far" -VerticalAlignment Center -name output
      }
   }
}
14 {
   ## This syntax only works in PowerSHell 2 running as MTA 
   ## because it requires making a RadialGradientBrush outside the boots thread...
   #  Boots -Background $(
      #  RadialGradientBrush {
         #  GradientStop -Offset 0 -Color "#F00"
         #  GradientStop -Offset 1 -Color "#F90"
      #  }
   #  ) {
      #  Label "Boots" -HorizontalAlignment Center `
                    #  -VerticalAlignment Center `
                    #  -Foreground White -Margin 80 `
                    #  -FontWeight Bold  -FontSize 40
   #  }
   
   Boots {
      Label "Boots" -HorizontalAlignment Center `
                    -VerticalAlignment Center `
                    -Foreground White -Margin 80 `
                    -FontWeight Bold  -FontSize 40
   } -async -passthru | Invoke-BootsWindow -Element {$_} {
      $BootsWindow.Background = RadialGradientBrush {
         GradientStop -Offset 0 -Color "#F00"
         GradientStop -Offset 1 -Color "#F90"
      }
   }
}
15 {
   Boots {
      TextBox -Width 220 
   } -Title "Enter your name" -On_Closing { 
         Write-BootsOutput $BootsWindow.Content.Text 
   }
}
16 {
   function Get-BootsInput {
      Param([string]$Prompt = "Please enter your name:")
      
      Boots {
         Border -BorderThickness 4 -BorderBrush "#BE8" -Background "#EFC" (
            StackPanel -Margin 10  $( 
               Label $Prompt
               StackPanel -Orientation Horizontal $(
                  TextBox -Width 150 -On_KeyDown { 
                     if($_.Key -eq "Return") { 
                        Write-BootsOutput $global:textbox.Text
                        $BootsWindow.Close()
                     }
                  } | Tee -Variable global:textbox
                  Button "Ok" -On_Click { 
                     Write-BootsOutput $global:textbox.Text
                     $BootsWindow.Close()
                  }
               )
            )
         )
      } -On_Load { Invoke-BootsWindow $global:textbox { $global:textbox.Focus() } } `
      -WindowStyle None -AllowsTransparency `
      -On_PreviewMouseLeftButtonDown { 
         if($_.Source -notmatch ".*\.(TextBox|Button)") 
         {
            $BootsWindow.DragMove() 
         }
      }
   }
   Get-BootsInput
}
17 {
   ## Example 1: list of processes with most RAM usage
   ## DoubleClickAction is `kill`
   Boots {
      ps | sort PM -Desc | Select -First 20 | 
         GraphLabel ProcessName PM { 
            Kill $Args[0].Id -WhatIf
            $global:panel.Children.Remove($Args[1])
         } | 
      StackPanel | Tee -Var global:panel
   }
}
18 {
   ## Example 2: list of images, with file size indicated
   ## DoubleClickAction is `open`
   Boots {
      ls ~/Pictures/ -recurse -Include *.jpg | 
      Select -First 10 | ## For the sake of the demo, just 10
      Sort Length -Desc |
      % {
         if(!$Max){$Max=$_.Length}

         StackPanel -Width 200 -Margin 5 $(
            Image -Source $_.FullName
            GraphLabel Name Length -Max $Max -IO $_ {
               [Diagnostics.Process]::Start( $args[0].FullName )
            }
         ) 
      } | WrapPanel 
   } -Width 800
}
19 {
# Write-Host "We're going to ask for your password here, so we can upload an image via FTP"
# $credential = Get-Credential
   New-BootsImage BootsImage-Screenshot.jpg {
      StackPanel -Margin "10,5,10,5" {
         Label "Please enter your name:"
         StackPanel -Orientation Horizontal {
            TextBox -Width 150 -On_KeyDown { 
               if($_.Key -eq "Return") { 
                  Write-BootsOutput $global:textbox.Text
                  $BootsWindow.Close()
               }
            } | Tee-Object -Variable global:textbox 
            Button "Ok" -Padding "5,0,5,0" -Margin "2,0,0,0" -On_Click { 
               Write-BootsOutput $textbox.Text
               $BootsWindow.Close()
            }
         }
      } 
   }
   #| ForEach-Object { 
      #Send-FTP HuddledMasses.org $credential -LocalFile $_ -Remotefile "$imgPath/$($_.Name)" 
      #[Windows.Clipboard]::SetText( "!http://huddledmasses.org/images/PowerBoots/$($_.Name)!" )
   #}
}
20 {
   Boots -Async {
      StackPanel -Margin 10 {
         TextBlock "The Question" -FontSize 42 -FontWeight Bold -Foreground "#FF0088"
         TextBlock -FontSize 24 {
            Hyperlink {
               Bold "Q. "
               "Can PowerBoots do async threads?"
            } -NavigateUri " " -On_RequestNavigate {
               if($global:Answer.Visibility -eq 2) { 
                  $global:Answer.Visibility = "Visible"
               } else {
                  $global:Answer.Visibility = "Collapsed"
               }
            }
         }
         TextBlock -FontSize 16 {
            Span "A. " -FontSize 24 -FontWeight Bold 
            "Oh yes we can!"
         } -Visibility Collapsed | Tee -Variable global:Answer
      }
   } 
}
21 {
   # This works with just the PoshWpf snapin
   $global:Splash = New-BootsWindow -Async -Passthru -On_MouseDown { $this.DragMove() } -SourceTemplate '<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation" WindowStyle="None" AllowsTransparency="True" Opacity="0.8" Topmost="True" SizeToContent="WidthAndHeight" WindowStartupLocation="CenterOwner" ShowInTaskbar="False"><Image Source="http://dilbert.com/dyn/str_strip/000000000/00000000/0000000/000000/40000/1000/200/41215/41215.strip.print.gif" Height="177" /></Window>' 
   # Imagine this is your script, working ...
   &{ 1..25 | % { write-progress "Doing ..." "Lost of work" -percent ($_ * 4); Start-Sleep -milli 200 } }
   # And now you're done, and want to close it
   Remove-BootsWindow -Window $Splash
}
22 {
   ## This requires PowerBoots...
   $global:Splash = Boots -Async -Passthru -Content { 
      Image -Height 177 -Source http://dilbert.com/dyn/str_strip/000000000/00000000/0000000/000000/40000/1000/200/41215/41215.strip.print.gif
   } -WindowStyle None -AllowsTransparency -Opacity 0.8 -Topmost -WindowStartupLocation CenterOwner -ShowInTaskbar:$False -On_MouseDown { $this.DragMove() }

   # Imagine this is your script, working ...
   &{ 1..25 | % { write-progress "Doing ..." "Lost of work" -percent ($_ * 4); Start-Sleep -milli 200 } }
   # And now you're done, and want to close it
   Remove-BootsWindow -Window $Splash
}
23 {
   ## Demonstrate how to load XAML and use data-binding and Resource to animate things on it.
   ## The downside is that you need GLOBAL variables to make sure the module can see them...

   Write-Host "Initializing Performance Counters, please have patience" -fore Cyan
   ### Import PoshWpf module
   Import-Module PowerBoots -Force
   ### Or, on v1:
   # Add-PSSnapin PoshWpf

   $global:cpu = new-object System.Diagnostics.PerformanceCounter "Processor", "% Processor Time", "_Total"
   $global:ram = new-object System.Diagnostics.PerformanceCounter "Memory", "Available KBytes"

   ## get initial values, because the counters don't work until the second call
   $null = $global:cpu.NextValue()
   $null = $global:ram.NextValue()
   $global:maxram = (gwmi Win32_OperatingSystem).TotalVisibleMemorySize

   Write-Host "Loading XAML window... (right-click to close it)" -fore Cyan
   ## Load the XAML and show the window. It won't be updating itself yet...
   ## Note that this loads -Async so it returns control to the console
   ## We also use -Passthru to make it easier to Invoke-BootsWindow later
   $global:clock = New-BootsWindow -Async -Passthru -FileTemplate "$PowerBootsPath\Samples\Clock.xaml" 

   ## Create a script block which will update the UI by changing the Resources!
   $counter = 0;
   $global:updateBlock = {
      # Update the clock
      $global:clock.Resources["Time"] = [DateTime]::Now.ToString("hh:MM.ss")

      # We only want to update the counters at most once a second
      # Otherwise their values are invalid and ...
      # The CPU counter fluctuates from 0 to the real number
      if( $counter++ -eq 4 ) {
         $counter = 0
         # Update the CPU counter with the absolute value and the percentage
         $cu = $global:cpu.NextValue()
         $global:clock.Resources.CpuP = ($cu / 100)
         $global:clock.Resources.Cpu = "{0:0.0}%" -f $cu
         # Update the RAM counter with the absolute value and the percentage
         $rm = $global:ram.NextValue()
         $global:clock.Resources.RamP = ($rm / $global:maxram)
         $global:clock.Resources.Ram = "{0:0.00}Mb" -f ($rm/1MB)
      }
   }

   ## Now we need to call that scriptblock on a timer. That's easy, but it
   ## must be done on the window's thread, so we use Invoke-BootsWindow.
   ## Notice the first argument is the window we want to run the script in
   Invoke-BootsWindow $clock {
      ## We'll create a timer
      $global:timer = new-object System.Windows.Threading.DispatcherTimer
      ## Which will fire 4 times every second
      $timer.Interval = [TimeSpan]"0:0:0.25"
      ## And will invoke the $updateBlock
      $timer.Add_Tick( $global:updateBlock )
      ## Now start the timer running
      $timer.Start()
   }

   ## Note that this uses global variables, rather than Export-NamedElement
   Register-BootsEvent $clock -Event MouseLeftButtonDown -Action {
      $_.Handled = $true
      $clock.DragMove() # WPF Magic!
   }
   Register-BootsEvent $clock -Event MouseRightButtonDown -Action {
      $_.Handled = $true
      $timer.Stop()  # we'd like to stop that timer now, thanks.
      $clock.Close() # and close the windows
   }
}
24 {
   ## Demonstrate how to load XAML and use Export-NamedElement to work with controls defined in it
   
   ## VERY important: Define your event handlers as GLOBAL, but inside the PowerBoots scope:
   &(gmo PowerBoots) {
      function global:CalculateGas {
         Export-NamedElement
         $Total.Text = '${0:n2}' -f (($Miles.Text -as [Double]) / ($Mpg.Text -as [Double]) * ($Cost.Text -as [Double]))
      }
   }

   
   ## Specify the event handlers using the PoshExtension in XAML: (.Net 4 only)
   New-BootsWindow -Async -Source @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:ps="http://schemas.huddledmasses.org/wpf/powershell"
        Title="Trip Cost">
    <Grid>
        <Grid.RowDefinitions>
            <RowDefinition Height="28" />
            <RowDefinition Height="28" />
            <RowDefinition Height="28" />
            <RowDefinition Height="28" />
        </Grid.RowDefinitions>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="110" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>
        <Label Content="Miles" VerticalAlignment="Top" />
        <TextBox Grid.Column="1" Grid.Row="0" Height="23" Width="200" HorizontalAlignment="Stretch" Name="miles" Text="10" />
        <Label Grid.Row="1" Content="Miles per Gallon" VerticalAlignment="Top" />
        <TextBox Grid.Column="1" Grid.Row="1" Height="23" Width="200" HorizontalAlignment="Stretch" Name="mpg" Text="2" />
        <Label Grid.Row="2" Content="Cost per Gallon"  VerticalAlignment="Top" />
        <TextBox Grid.Column="1" Grid.Row="2" Height="23" Width="200" HorizontalAlignment="Stretch" Name="cost" Text="5" />
        <!-- *******************************************
             ** See the click handler on this Button? **
             ******************************************* -->
        <Button Name="calculate" Grid.Row="3" Content="_Calculate" HorizontalAlignment="Center" Click="{ps:Posh CalculateGas}" />
        <TextBlock Grid.Column="1" Grid.Row="3" Height="23" Width="200" HorizontalAlignment="Stretch" Name="total" Text="--" />
    </Grid>
</Window>
"@
}
25 {
New-BootsWindow { ScrollViewer { TextBlock "Loading Fonts..." -FontSize 62 -FontFamily SegoeUI } } -Async -Passthru | 
Invoke-BootsWindow -Script { 
   $This.Content.Content = $( 
      ForEach( $font in [System.Windows.Media.Fonts]::SystemFontFamilies ) { 
         TextBlock -FontFamily $font.Source -Text "The Quick Brown Fox Jumps over the Lazy Dog" -FontSize 18; Write-Host $font
      }
   ) | StackPanel
}
}
26 {

   Add-BootsFunction -T System.Windows.Forms.FolderBrowserDialog | Out-Null

  

$Date, $Folder = New-BootsWindow -Title "Copy Logs Demo" -Source @"
   <Window
       xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
       xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
       xmlns:ps="http://schemas.huddledmasses.org/wpf/powershell"
       Title="Copy Logs Demo" Height="307" Width="358" WindowStartupLocation="CenterScreen" ResizeMode="NoResize" Background="{StaticResource {x:Static SystemColors.ControlBrushKey}}">
       <Grid>
           <TextBlock Height="35" HorizontalAlignment="Left" Margin="12,12,0,0" Name="Label" Text="Select a date of logs you wish to view and click the Choose Directory button to copy to selected directory." VerticalAlignment="Top" Width="340" TextWrapping="Wrap" TextAlignment="Left" />
           <Button Content="Choose Directory" IsEnabled="False" Height="23" HorizontalAlignment="Left" Margin="125,230,0,0" Name="ChooseDirButton" TabIndex="2" VerticalAlignment="Top" Width="95" />
           <Calendar Height="148" HorizontalAlignment="Left" Margin="84,53,0,0" Name="PickDate" VerticalAlignment="Top" Width="180" TabIndex="1" AllowDrop="False" FontFamily="Tahoma" />
       </Grid>
   </Window>
"@ -On_Loaded  {
   $ChooseDirButton, $PickDate  = Select-BootsElement $this ChooseDirButton, PickDate

   Register-BootsEvent $PickDate "SelectedDatesChanged" -Action { 
      $ChooseDirButton.IsEnabled = $true
      Write-BootsOutput $PickDate.SelectedDate
      # Calendar widget seems to capture mouse, prevent this from happening
      $PickDate.ReleaseMouseCapture()
   }.GetNewClosure()

         
   Register-BootsEvent $this "Click" -Action {
   #	$dirName = $dirPicker1.selectedPath
      $dateStr = $selectedDate.ToString('yyyy.MM.dd')
      $FolderPicker = FolderBrowserDialog -RootFolder ([System.Environment+SpecialFolder]'MyComputer') -ShowNewFolderButton:$false -SelectedPath "C:\" -Description "Please select the folder where the log files are"

      if ($FolderPicker.ShowDialog() -eq [Windows.Forms.DialogResult]::OK) {
         Write-BootsOutput $FolderPicker.SelectedPath
         $this.Close()
      }
   }.GetNewClosure()
}

# Once that returns ...
Write-Host "Copying log files from $Folder that are newer than $Date"


   $global:ProgressDialog =  New-BootsWindow -Async -Passthru -Name "ProgressDialog" -Title "Copying Progress" -Height 200 -Width 311 -WindowStartupLocation "CenterScreen" -ResizeMode "NoResize"  {
      StackPanel {
         TextBlock "Please wait, copying logs..." -Margin "12"
         TextBlock "OK, we're not really copying. Our demo is done." -Name "CopyStatusText" -Margin "12" | Tee -var global:ProgressFileName
         ProgressBar -Height 17 -IsIndeterminate -BorderBrush "#FF2CDC00" -Foreground "#FF00E100" -Margin "12"
         Button "Cancel" -Width 110 -Name "CancelButton" | Tee -var global:CancelButton
      }
   }

   Register-BootsEvent $CancelButton "Click" -Action {
      Write-Host "Stop Copying Stuff, Hypothetically"
      $global:ProgressDialog.Close()
   }.GetNewClosure()
   
   foreach($file in ls $Folder | Where { $_.LastWriteTime -gt $Date } ) {
      Write-Host "Copying $file"
      Invoke-BootsWindow "Copying Progress" {param($fileName)  $Global:ProgressFileName.Text = "Copying $fileName"  } -Parameters $file
      sleep 1
   }
   Write-Host "Removing $ProgressDialog"
   Get-BootsWindow "Copying Progress" | Remove-BootsWindow 
}


## END OF SAMPLES
}
