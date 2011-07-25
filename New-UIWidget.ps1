function New-UIWidget {
[CmdletBinding()]
param(
    [ScriptBlock]$Content,
    [Alias("Refresh")]
    [TimeSpan]$Interval = "0:0:2",
    [ScriptBlock]$UpdateBlock,
    [Switch]$Show, [Switch]$AsJob
)

$WidgetValues = @{ 
    # AllowsTransparency = $true
    WindowStyle = "None" 
    ShowInTaskbar = $true
    Background = "Transparent" 
    On_MouseLeftButtonDown = { $Window.DragMove() }
    On_Closing = { $Window.Resources.Timers."Clock".Stop() }
    Tag = @{"UpdateBlock"=$UpdateBlock;"Interval"=$Interval}
    SizeToContent = "WidthAndHeight"
    ResizeMode = "NoResize"
    On_SourceInitialized = {
        $Window.Resources.Timers.Clock = (New-Object Windows.Threading.DispatcherTimer).PSObject.BaseObject
        $Window.Resources.Timers.Clock.Interval = $Window.Tag.Interval
        Add-EventHandler $Window.Resources.Timers.Clock Tick $Window.Tag.UpdateBlock
        $Window.Resources.Timers.Clock.Start()
        $Window.Tag = $Null
        
        #  Import-Module HuddledTricks
        #  Set-Window -Handle (New-Object System.Windows.Interop.WindowInteropHelper $Window).Handle -BottomMost
    }
    On_ContentRendered = $UpdateBlock
    
}

New-Window @WidgetValues -Content $Content -Show:$Show -AsJob:$AsJob

}
