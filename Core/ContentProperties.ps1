$Global:ShowUI.ContentProperties = 'Content','Child','Children','Frames','Items','Pages','Blocks','Inlines','GradientStops','Source','DataPoints', 'Series', 'VisualTree'
function Get-UIContentProperty {
   $Global:ShowUI.ContentProperties
}
function Add-UIContentProperty {
PARAM([string[]]$PropertyNames, [switch]$Passthru)
   $Global:ShowUI.ContentProperties = $Global:ShowUI.ContentProperties + $PropertyNames | ForEach { [regex]::Escape($_) } | Sort -Unique
   if($Passthru) {
      $Global:ShowUI.ContentProperties
   }
}
function Remove-UIContentProperty {
PARAM([string[]]$PropertyNames)
   $Global:ShowUI.ContentProperties = $Global:ShowUI.ContentProperties | Where { $PropertyNames -notcontains $_ }
}