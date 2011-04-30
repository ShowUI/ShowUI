Import-Module ShowUI -Global
Add-Type -AssemblyName System.Drawing

## Note that functions that are findable in module scope can be used as event handlers
## You can do this with Autoload, with GLOBAL scope, or with &$Module {} invocation:
& (Get-Module ShowUI) {
   function Global:ConvertTo-DpiRectangle([System.Windows.Media.Visual]$visual,[System.Windows.Rect]$bounds) {
      $source = [System.Windows.PresentationSource]::FromVisual($visual)
      $matrix = $source.CompositionTarget.TransformToDevice

      $origin = $matrix.Transform( (new-object System.Windows.Point $bounds.Left, $bounds.Top) )
      $size   = $matrix.Transform( (new-object System.Windows.Point $bounds.Width,$bounds.Height) )
      return New-Object System.Drawing.Rectangle $origin.X, $origin.Y, $size.X, $size.Y
   }

   function Global:Get-VirtualScreenSize {
      return New-Object System.Windows.Rect ([System.Windows.SystemParameters]::VirtualScreenLeft), 
                                            ([System.Windows.SystemParameters]::VirtualScreenTop),
                                            ([System.Windows.SystemParameters]::VirtualScreenWidth), 
                                            ([System.Windows.SystemParameters]::VirtualScreenHeight)
   }

   function Global:ClosePopup {
      $window = $this.Parent
      if($_.Source -notmatch ".*\.(TextBox|Button)") 
      {
         $window.Close(); 
         $Global:ShownToast = $Global:ShownToast -ne $window
      }
   }
}

$Global:ShownToast = @()

function New-UIToast {
   Param([string]$Message = "Something Has Happened")
   $Global:ScreenSize = Get-VirtualScreenSize
   $Global:Message = $Message
         
   $Toast = Show -Left ($ScreenSize.Right - 250) -Top $ScreenSize.Bottom -Height 0 {
         Write-Host "Ok, making toast"
      Border -BorderThickness 4 -BorderBrush "#BE8" -Background "#EFC" -Width 250 {
         Write-Host "Ok, labelling toast"
         Label $Global:Message
      } -On_PreviewMouseLeftButtonDown ClosePopup -Name Toast -On_Loaded {
         Write-Host "Ok, loading toast"
         $Rect = Get-VirtualScreenSize
         # Write-Host "Turning $this into $($this.Parent) and Toasting it"
         $window = $this.Parent
         # Write-Host "Animate from 0 to $($window.ActualHeight), and from $($window.Top) to $($window.Top - $window.ActualHeight)" -Fore Green
         $window.Left = $ScreenSize.Right - $window.ActualWidth
         $window.Top = $ScreenSize.Bottom - ($window.ActualHeight * ($ShownToast.Count - 1))
         
         $size = DoubleAnimation -From 0 -To $window.ActualHeight -Duration 0:0:0.5 -"StoryBoard.TargetProperty" "(FrameworkElement.Height)" # -"StoryBoard.TargetName" "Toast" 
         $pos = DoubleAnimation -From $window.Top -To $($window.Top - $window.ActualHeight) -Duration 0:0:0.5 -"StoryBoard.TargetProperty" "(Window.Top)"
         Write-Host "Animate"
         $sb = StoryBoard $pos,$size
         [System.Windows.Media.Animation.StoryBoard]::SetTarget( $size, $window )
         #[System.Windows.Media.Animation.StoryBoard]::SetTargetProperty( $size, "(FrameworkElement.Height)" )
         
         [System.Windows.Media.Animation.StoryBoard]::SetTarget( $pos, $window )
         #[System.Windows.Media.Animation.StoryBoard]::SetTargetProperty( $pos, "(Window.Top)" )
         $sb.Begin()
         Write-Host "Done Loaded"
      }
   } -Async -Passthru -WindowStyle None -AllowsTransparency -Export

   $Global:ShownToast += $Toast
   #[Threading.Thread]::Sleep(600)
   sleep 1
}

Export-ModuleMember -Function New-UIToast

#  . $ProfileDir\Modules\PowerBoots\Samples\New-BootsToast.ps1

#  $fsw = new-object system.io.filesystemwatcher $pwd
#  $fsw.EnableRaisingEvents = $true
#  $action = { 
#     # Write-Host "$($eventArgs.Name) $($eventArgs.ChangeType)" -fore Cyan
#     New-BootsToast "$($eventArgs.Name) $($eventArgs.ChangeType)"
#     # sleep -milli 1200
#  }

#  Register-ObjectEvent $fsw Created -Action $action
#  Register-ObjectEvent $fsw Deleted -Action $action
                                                                                        
#  Register-ObjectEvent $fsw Changed -Action $action
