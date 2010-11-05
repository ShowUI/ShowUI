if(!(Get-Command New-BootsWindow -EA SilentlyContinue)) {
   # Add-PsSnapin PoshWpf
   Import-Module PowerBoots
   Add-BootsContentProperty 'DataPoints', 'Series'
   #[Void][Reflection.Assembly]::LoadFrom( (Convert-Path (Resolve-Path "~\Documents\WindowsPowershell\Libraries\WPFVisifire.Charts.dll")) )
   Add-BootsFunction -Assembly "~\Documents\WindowsPowershell\Libraries\WPFVisifire.Charts.dll"
   Add-BootsFunction ([System.Windows.Threading.DispatcherTimer])
}

if(Get-Command Ping-Host -EA SilentlyContinue) {
   $pingcmd = { (Ping-Host $args[0] -count 1 -Quiet).AverageTime }
} else {
   $pingcmd = { [int]([regex]"time=(\d+)ms").Match( (ping $args[0] -n 1) ).Groups[1].Value }
}

$global:onTick = {
$window = $this.Tag
   #  Invoke-BootsWindow $window {
      try {
         foreach($s in $window.Content.Series.GetEnumerator()) {
            $ping = &$pingcmd $s.LegendText
            $points = $s.DataPoints
            foreach($dp in 0..$($points.Count - 1)) 
            {
               if(($dp+1) -eq $points.Count) {
                  $points[$dp].YValue = $ping
               } else {
                  $points[$dp].YValue = $points[$dp+1].YValue
               }
            }
         }
      } catch { 
         Write-Output $_
      }
   #  }
}

function Add-PingHost {
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string[]]$target
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,  
   [Parameter(Position=2)]
   [System.Windows.Window]$window = $global:pingWindow
,
   [Parameter()]
   [Switch]$Passthru
)
PROCESS {
   if($Window) {
      Invoke-BootsWindow $Window { 
         $target | Add-PingHostInternal -render $renderAs -window $window
      }
      return $Window
   } else {
      return New-PingMonitor -Hosts $target -RenderAs $renderAs
   }
}
}

function Add-PingHostInternal {  
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string]$target
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,  
   [Parameter(Position=2)]
   [System.Windows.Window]$window = $global:pingWindow
)
Process {
   $start = $(get-random -min 10 -max 20)
   $window.Content.Series.Add( $(
      DataSeries { 1..25 | %{DataPoint -YValue $start} } -LegendText $target -RenderAs $renderAs
   ) )
}
}

function New-PingMonitor {
[CmdletBinding()]
Param(
   [Parameter(Position=0,ValueFromPipeline=$true)]
   [string[]]$hosts = $(Read-Host "Please enter the name of a computer to ping")
,
   [Parameter(Position=1)]
   [Visifire.Charts.RenderAs]$renderAs="Line"
,
   [Parameter()]
   [Switch]$Passthru
)
Process { 
   $script:renderAs = $renderAs
   $script:Hosts = $Hosts
      
   $global:pingWindow = New-BootsWindow -Async {
      Param($window) # New-Boots passes the window to us ...
      # Make a new scriptblock of the OnTick handle, passing it ourselves
      # Make a timer, and stick it in the window....
      $window.Tag = @((DispatcherTimer -Interval "00:00:01.0" -On_Tick $global:onTick -Tag $window), $global:onTick)
      
      Chart {
         foreach($h in $hosts) {
            $script:start = get-random -min 10 -max 20
            DataSeries {
               foreach($i in 1..25) {
                  DataPoint -YValue $script:start
               }
            } -LegendText $h -RenderAs $renderAs
         }
      } -watermark $false
   } -On_ContentRendered {
      $this.tag[0].Start()
   } -On_Closing { 
      $this.tag[0].Remove_Tick($this.tag[1])
      $this.tag[0].Stop()
      $global:pingWindow = $null 
      Remove-BootsWindow $this
   } -Title "Ping Monitor" -Passthru -height 300 -width 800 

   if($Passthru) {
      return $global:pingWindow
   }
}
}