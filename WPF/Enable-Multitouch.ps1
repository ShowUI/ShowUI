function Enable-MultiTouch
{
    <#
    .Synopsis
        Enables multiple touch events on a window
    .Description
        Registers a window for multiple touch events and creates
        three buffers (TouchStarts,TouchStops,TouchMoves) that
        will contain all of the touch events that have occured within 
        a buffer window.
        This enables raw multitouch support, but does not 
        enable gestures such as pinching or zooming
    .Parameter Window
        The Window to Enable for multitouch events
    .Parameter Buffer
        The time buffer to record event
    .Example
    
    
New-Window -WindowState Maximized -Resource @{
    Styluses=@{}
} -On_Loaded {
    $this | 
        Enable-MultiTouch
} -On_StylusDown {
    $styluses = $this.Resources.Styluses 
    $origin = $_.GetPosition($this.Content)
    $color = 'Black', 'Pink', 'Red', 'Blue', 'Green', 'Orange','DarkRed', 'MidnightBlue', 'Maroon', 'SaddleBrown' | 
        Get-Random 
    
    $line = New-Polyline -Stroke $color -StrokeThickness 3 -Points { $origin } 
    $styluses.($_.StylusDevice.ID) = @{
        Line = $line
    }
    $line | 
        Add-ChildControl $this.Content
} -On_StylusMove {
    $styluses = $this.Resources.Styluses
    $line = $styluses.($_.StylusDevice.ID).Line
    $point = $_.GetPosition($this.Content)
    $null = $line.Points.Add($point)
} -On_StylusUp {
    $styluses = $this.Resources.Styluses 
    $styluses.($_.StylusDevice.ID).Line | 
        Move-Control -fadeOut -duration ([timespan]::FromMilliseconds(500))
    $styluses.Remove($_.StylusDevice.ID) 
} -Content {
    New-Canvas 
} -asJob        
    #>
    param(
    [Parameter(ValueFromPipeline=$true, 
        Mandatory=$true)]
    [Windows.Window]
    $Window,
    
    [Timespan]
    $Buffer = [Timespan]::FromSeconds(30)
    )
    begin {
        if (-not ('WPK.MT' -as [TYPE])) {
            $referencedAssemblies = 'WindowsBase, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
        'PresentationCore, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35',
        'PresentationFramework, Version=3.0.0.0, Culture=neutral, PublicKeyToken=31bf3856ad364e35'
            Add-Type 'MT' -Namespace WPK -IgnoreWarnings `
            -ReferencedAssemblies $referencedAssemblies `
            -UsingNamespace System.Windows, System.Windows.Interop `
            -MemberDefinition '
[DllImport("user32")]
public static extern bool SetProp(IntPtr hWnd, string lpString, IntPtr hData);
','
/// <summary>
/// Enable Stylus events, that represent touch events. 
/// </summary>
/// <remarks>Each stylus device has an Id that is corelate to the touch Id</remarks>
/// <param name="window">The WPF window that needs stylus events</param>
public static void EnableStylusEvents(System.Windows.Window window)
{
    WindowInteropHelper windowInteropHelper = new WindowInteropHelper(window);

    // Set the window property to enable multitouch input on inking context.
    SetProp(windowInteropHelper.Handle, "MicrosoftTabletPenServiceProperty", new IntPtr(0x01000000));
}
' 
        }
    }
    process {
        [WPK.MT]::EnableStylusEvents($window)
        $LinkedListType = "Collections.Generic.LinkedList"

        $window.Resources.TouchStarts = New-Object "$LinkedListType[PSObject]"
        $window.Resources.TouchStops = New-Object "$LinkedListType[PSObject]"
        $window.Resources.TouchMoves = New-Object "$LinkedListType[PSObject]"
        $window.Resources.TouchBuffer = $Buffer
        $window.add_StylusUp({
            $object = $_ |
                Add-Member NoteProperty Sender $this -PassThru |
                Add-Member NoteProperty TimeGenerated ([DateTime]::Now) -PassThru
            $TouchStops =$this.Resources.TouchStops
            $Buffer = $this.Resources.TouchBuffer
            $check = $TouchStops.First
            $time = $check.Value.TimeGenerated
            while ($time -and 
                (($time.Add($Buffer)) -lt (Get-Date))) {
                $oldCheck = $check
                $check = $check.Next
                if (-not $check) { return } 
                $time = $check.Value.TimeGenerated
                $null = $TouchStops.Remove($oldCheck)
                $oldCheck = $null
            }
            $null = $TouchStops.AddLast($Object)            
        })
        $window.add_StylusDown({
            $object = $_ |
                Add-Member NoteProperty Sender $this -PassThru |
                Add-Member NoteProperty TimeGenerated ([DateTime]::Now) -PassThru
            $TouchStarts =$this.Resources.TouchStarts
            $Buffer = $this.Resources.TouchBuffer
            $check = $TouchStarts.First
            $time = $check.Value.TimeGenerated
            while ($time -and 
                (($time.Add($Buffer)) -lt (Get-Date))) {
                $oldCheck = $check
                $check = $check.Next
                if (-not $check) { return } 
                $time = $check.Value.TimeGenerated
                $null = $TouchStarts.Remove($oldCheck)
                $oldCheck = $null
            }
            $null = $TouchStarts.AddLast($Object)            
        })
        $window.add_StylusMove({
            $object = $_ |
                Add-Member NoteProperty Sender $this -PassThru |
                Add-Member NoteProperty TimeGenerated ([DateTime]::Now) -PassThru
            $TouchMoves =$this.Resources.TouchMoves
            $Buffer = $this.Resources.TouchBuffer
            $check = $TouchMoves.First
            $time = $check.Value.TimeGenerated
            while ($time -and 
                (($time.Add($Buffer)) -lt (Get-Date))) {
                $oldCheck = $check
                $check = $check.Next
                if (-not $check) { return } 
                $time = $check.Value.TimeGenerated
                $null = $TouchMoves.Remove($oldCheck)
                $oldCheck = $null
            }
            $null = $TouchMoves.AddLast($Object)            
        })                
    }
}
