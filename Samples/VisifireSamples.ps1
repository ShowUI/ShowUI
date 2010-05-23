Param([int[]]$which=0)

if(!(get-command New-Visifire.Charts.DataSeries -EA 0)){
   Add-BootsContentProperty 'DataPoints', 'Series'
   Add-BootsFunction -Assembly "$PowerBootsPath\BinaryAssemblies\WPFVisifire.Charts.dll"
}


switch($which) {
0 { 
@"
This script just runs the various Visifire demo scripts I've written to test Boots.
You need to pass it a number (between 1 and 5) for each sample you want to run!
"@
}
1 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Boots {
      New-Visifire.Charts.Chart -MinWidth 200 -MinHeight 150 -Theme Theme3 {
         New-Visifire.Charts.DataSeries {
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
            New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
         }
      }
   } -Title "Sample, Theme 3"
}
2 {
   Write-Warning "This sample requires HttpRest and Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   [int]$tk    = (Invoke-Http get http://google.com/search -with @{q="TCL Tk"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   [int]$shoes = (Invoke-Http get http://google.com/search -with @{q="Ruby Shoes Rb"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   [int]$boots = (Invoke-Http get http://google.com/search -with @{q="PowerShell PowerBoots"} |
                  Receive-Http Text "//div[@id='resultStats']") -split " " | select -index 1
   Boots {
      New-Visifire.Charts.Chart -MinHeight 300 -MinWidth 400 {
         New-Visifire.Charts.DataSeries -RenderAs Bar {
            New-Visifire.Charts.DataPoint -YValue $tk    -AxisXLabel Tk    -Href http://google.com/search?q=TCL+Tk
            New-Visifire.Charts.DataPoint -YValue $shoes -AxisXLabel Shoes -Href http://google.com/search?q=Ruby+Shoes
            New-Visifire.Charts.DataPoint -YValue $boots -AxisXLabel Boots -Href http://google.com/search?q=PowerSHell+PowerBoots
         }
      }
   }
}
3 {
   Write-Warning "This sample requires Visifire and -STA -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Write-Host "Doing an ActiveDirectory Search. This may take a long time. (Ctrl+C to cancel)"
   $ad=New-Object DirectoryServices.DirectorySearcher [ADSI]''
   # Set a limit or TimeOut, PageSize lets us get more later
   $ad.PageSize = 200

   # ADSI field names are awful.
   # l = location, l=* returns only users with locations set
   $ad.Filter = "(&(objectClass=Person)(l=*))"  
   $results = $ad.FindAll().GetEnumerator() | ForEach { $_ }
   $users   = $results | ForEach { $_.GetDirectoryEntry() }

   # "l" is a PropertyValueCollection, use the first value
   $users | Group-Object {$_.l[0]}  | ForEach { 
      New-Visifire.Charts.DataPoint -YValue ([int]$_.Count) -AxisXLabel $_.Name 
   }| New-Visifire.Charts.DataSeries -RenderAs Doughnut | 
      New-Visifire.Charts.Chart -Height 300 -Width 300  | 
      Boots -Title "AD Users by Location"
}
4 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   Boots {
   ls | ForEach { 
      New-Visifire.Charts.DataPoint -YValue ([DateTime]::Now - $_.LastWriteTime).TotalDays `
                -ZValue ($_.Length/1KB) `
                -AxisXLabel $_.Name -Tag $_ `
                -On_MouseLeftButtonUp { 
                  if($this.Tag) { 
                     Write-BootsOutput $this.Tag; 
                     $global:series.DataPoints.Remove($this)
                  }
               }
   } | New-Visifire.Charts.DataSeries -RenderAs Bubble -ToolTipText "#AxisXLabel`nAge: #YValue days, Size: #ZValue Kb" | 
      Tee-Object -Variable global:series |
      New-Visifire.Charts.Chart -MinHeight 350 -MinWidth 600 -Theme Theme3 
   } | Remove-Item -Confirm
}
5 {
   Write-Warning "This sample requires Visifire -- it WILL NOT WORK with WPFToolkit DataVisualization"
   # Write-Host "We're going to ask for your password here, so we can upload an image via FTP"
   # $credential = Get-Credential

   if($PsVersionTable) {
      ## BUG BUG: Setting boolan properties isn't working in PowerShell 1
      Write-Host "Using PowerShell 2 Version" -Fore Cyan
      New-BootsImage VisiFire-BootsImage.jpg {
         New-Visifire.Charts.Chart -Width 200 -Height 150 -Theme Theme3 -Watermark:$false -Animation:$false -Series {
            New-Visifire.Charts.DataSeries {
               1..(Get-Random -min 3 -max 6) | ForEach-Object  {
                  New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
               }
            }
         }
      }
      #| ForEach-Object { 
      #   Send-FTP HuddledMasses.org $credential -LocalFile $_ -Remotefile "$imgPath/$($_.Name)" 
      #   [Windows.Clipboard]::SetText( "!http://huddledmasses.org/images/PowerBoots/$($_.Name)!" )
      #}
   } else {
      Write-Host "Using PowerShell 1 Version" -Fore Cyan
      Boots -Title "ScreenCapWindow" {
         New-Visifire.Charts.Chart -Width 200 -Height 150 -Theme Theme3 -Watermark:$false -Animation:$false -Series {
            New-Visifire.Charts.DataSeries {
               1..(Get-Random -min 3 -max 6) | ForEach-Object  {
                  New-Visifire.Charts.DataPoint -YValue (Get-Random 100)
               }
            }
         } | tee -var global:chart  
      } -Async
      sleep 5
      Export-BootsImage VisiFire-BootsImage.jpg $global:chart
      Remove-BootsWIndow "ScreenCapWindow" 
   }
}

}