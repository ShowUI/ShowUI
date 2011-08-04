function New-UIWidget {
    param(
        [Parameter(Position=0,ValueFromPipeline=$true)]
        [ScriptBlock]$Content,
        [Alias("Refresh")]
        [TimeSpan]$Interval = "0:0:2",
        [ScriptBlock]$UpdateBlock = $([ScriptBlock]::Create("`$Window.Content = ( `n${Content}`n )")),
        [Switch]$ShowInTaskbar,
        [Switch]$Show,
        [Switch]$AsJob
    )

    process { 
        $psBoundParameters.Interval = $interval
        $psBoundParameters.UpdateBlock = $UpdateBlock 
        $Widget = @{
            On_MouseLeftButtonDown = { 
                $Window.DragMove()
            }
            On_Closing = {
                $Window.Resources.Timers."Clock".Stop()
            }
            Tag = @{
                "UpdateBlock"=$UpdateBlock;
                "Interval"=$Interval
            }
            On_SourceInitialized = {
                $Window.Resources.Timers.Clock = (New-Object Windows.Threading.DispatcherTimer).PSObject.ImmediateBaseObject
                $Window.Resources.Timers.Clock.Interval = $Interval
                Add-EventHandler $Window.Resources.Timers.Clock Tick $UpdateBlock
                $Window.Resources.Timers.Clock.Start()
                $Window.Tag = $Null

                if(!("Win32.Dwm" -as [Type])) {
                    add-type -Name Dwm -Namespace Win32 -MemberDefinition @"
                    [DllImport("dwmapi.dll", PreserveSig = false)]
                    public static extern int DwmSetWindowAttribute(IntPtr hwnd, int attr, ref int attrValue, int attrSize);
"@
                }
                $enable = 2
                [Win32.Dwm]::DwmSetWindowAttribute( (New-Object System.Windows.Interop.WindowInteropHelper $Window).Handle, 12, [ref]$enable, 4 )
            }
            On_Loaded = $UpdateBlock
        } + $PSBoundParameters

        $null = $Widget.Remove("Interval")
        $null = $Widget.Remove("UpdateBlock")

        New-Window -VisualStyle Widget @Widget

    }
}
