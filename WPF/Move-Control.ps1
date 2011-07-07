function Move-Control {
    <#
    .Synopsis
        Moves a control to a location, and animates the transition
    .Description
        Moves a control to a fixed point on the screen, to another control's location, or to the location and size of the parent control.
        Also allows the control to be faded in or faded out
    .Example
        New-Button -show "Click me and I'll fade away" -On_Click { 
            $this | Move-Control -fadeOut -duration ([Timespan]::FromMilliseconds(500))
        }        
    .Parameter name
        The name of the control to move
    .Parameter control
        The real control to move
    .Parameter targetName
        The name of the target to move the control to
    .Parameter target
        The real control to move the target to
    .Parameter Width
        The width to resize the control to.
        If target or targetName is set, this will be replaced with the target's width.
    .Parameter Height
        The height to resize the control to.
        If target or targetName is set, this will be replaced with the target's height.
    .Parameter Top
        The new top location of the control
        If target or targetName is set, this will be replaced with the target's top.
    .Parameter Left
        The new left location of the control
        If target or targetName is set, this will be replaced with the target's left.    
    .Parameter duration
        The amount of time the transition should take.  If this is not set, then the transition will be immediate.
    .Parameter fadeIn
        If set, will fade in the opacity of the control
    .Parameter fadeOut
        If set, will fade out the opacity of the control
    .Parameter AccelerationRatio
        The AccelerationRatio used for all animation
    .Parameter DecelerationRatio
        The DeccelerationRatio used for all animation
    .Parameter autoScroll
        If set, will find the fist parent UI element containing this item and will scroll it to the upper left coordinates of the item.
    .Parameter On_Completed
        If set, will run the script block when the move is completed
    #>
    [CmdletBinding(DefaultParameterSetName="Name")]
    param(
        [Parameter(Mandatory=$true,
            ParameterSetName="Name",
            Position=0)]
        [string[]]
        $name,
        
        [Parameter(Mandatory=$true,
            ParameterSetName="Control",
            ValueFromPipeline=$true)]
        [Windows.UIElement]
        $control,
        
        [string]
        $targetName,
        
        [Windows.UIElement]
        $target,
        
        [Double]
        $Width,
        
        [Double]
        $Height,
        [Double]
        $Top,        
        
        [Double]
        $Left,
        
        [Timespan]$duration = [Timespan]"0:0:0.00",
        
        [Double]$AccelerationRatio,
        [Double]$DecelerationRatio,
        [ScriptBlock[]]$On_Completed = {},
        [switch]$fadeIn,
        [switch]$fadeOut,
        [switch]$autoScroll
    )
    begin {
        $controls = @()
    }
    process {
        switch ($psCmdlet.ParameterSetName) {
            Name {
                if ($window) {
                    foreach ($n in $name) {
                        $controls += ($window | Get-ChildControl $n)
                    }
                }
            }
            Control {                
                $controls += $control
            }
        }
    }
    end {
        if ($targetName) {
            $target = $window | Get-ChildControl $targetName
        }
                
        if ($target) {            
            $width = $target.ActualWidth            
            $height = $target.ActualHeight
            $top = $target.Top
            $left = $target.Left
        }
    
        $animationTemplate = @{
            AccelerationRatio = $AccelerationRatio
            DecelerationRatio = $DecelerationRatio
            Duration = $duration        
        }
        foreach ($c in $controls) {
            $dp = @{}
            $c.GetLocalValueEnumerator() | ForEach-Object {
                $value = $_
                switch ($_.Property.Name) {
                    Width { $dp.Width = $value.Property } 
                    Height { $dp.Height = $value.Property } 
                    Top { $dp.Top = $value.Property } 
                    Left { $dp.Left = $value.Property } 
                }
            }
            $widthProperty = $dp.Width
            if ($widthProperty -and 
                ($psBoundParameters.ContainsKey("Width") -or $psBoundParameters.Target -or $psBoundParameters.TargetName)) {                
                if ($width -ne ($c.GetValue($widthProperty))) {
                    if ($duration.TotalMilliseconds) {                        
                        $widthChange = New-DoubleAnimation `
                                -From $c.GetValue($widthProperty) `
                                -To $width `
                                -On_Completed $On_Completed @animationTemplate
                        $On_Completed = {}
                        $c.BeginAnimation(
                            $widthProperty,
                            $WidthChange
                        )
                    } else {
                        $c.SetValue($widthProperty, $width)                    
                    }
                }
            }
            
            $HeightProperty = $dp.Height
            if ($HeightProperty -and
                ($psBoundParameters.ContainsKey("Height") -or $psBoundParameters.Target -or $psBoundParameters.TargetName)) {                
                if ($height -ne ($c.GetValue($HeightProperty))) {
                    if ($duration.TotalMilliseconds) {
                        $heightChange = New-DoubleAnimation `
                                -From $c.GetValue($heightProperty) `
                                -To $height `
                                -On_Completed $On_Completed @animationTemplate
                        $On_Completed = {}
                        $c.BeginAnimation(
                            $HeightProperty,
                            $HeightChange
                        )
                    } else {
                        $c.SetValue($HeightProperty, $Height)
                    }
                }
            }
            $TopProperty = $dp.Top
            if ($TopProperty -and 
                ($psBoundParameters.ContainsKey("Top") -or $psBoundParameters.Target -or $psBoundParameters.TargetName)) {                
                if ($top -ne ($c.GetValue($topProperty))) {
                    if ($duration.TotalMilliseconds) {                
                        $topChange = New-DoubleAnimation `
                                -From $c.GetValue($topProperty) `
                                -To $top `
                                -On_Completed $On_Completed @animationTemplate
                        $On_Completed = {}
                        $c.BeginAnimation(
                            $TopProperty,
                            $TopChange
                        )
                    } else {
                        $c.SetValue($TopProperty, $Top)
                    }
                }
            }
            
            $LeftProperty = $dp.Left
            if ($LeftProperty -and 
                ($psBoundParameters.ContainsKey("Left") -or $psBoundParameters.Target -or $psBoundParameters.TargetName)) {                
                if ($left -ne ($c.GetValue($leftProperty))) {
                    if ($duration.TotalMilliseconds) {
                        $leftChange = New-DoubleAnimation `
                                -From $c.GetValue($leftProperty) `
                                -To $left `
                                -On_Completed $On_Completed @animationTemplate
                        $On_Completed = {}
                        $c.BeginAnimation(
                            $LeftProperty,
                            $LeftChange
                        )
                    } else {
                        $c.SetValue($LeftProperty, $Left)
                    }
                }
            }
            
            if ($fadeIn) {
                $c.Visibility = "Visible"
                if ($duration.TotalMilliseconds) {
                    $fadeChange = 
                        New-DoubleAnimation `
                            -From ($c.GetValue($c.GetType()::OpacityProperty)) `
                            -To 1 `
                            -On_Completed $on_Completed @animationTemplate
                    $On_completed = {}
                    $c.BeginAnimation(
                        $c.GetType()::OpacityProperty,
                        $fadeChange
                    )
                } else {
                    $c.SetValue($c.GetType()::OpacityProperty, [Double]1)
                }
            } else {
                if ($fadeOut) {
                    if ($duration.TotalMilliseconds) {
                        $guid = [GUID]::NewGuid().ToString()
                        $window.Resources.TemporaryControls."$guid" = $c
                        $hideScript = [ScriptBlock]::Create("
                            `$window.Resources.TemporaryControls.'$guid'.Visibility = 'Collapsed'
                            `$window.Resources.TemporaryControls.Remove('$guid')
                        ")
                        $fadeChange = 
                            New-DoubleAnimation @animationTemplate `
                                -from ([Double]($c.GetValue($c.GetType()::OpacityProperty)))`
                                -to ([Double]0) -On_Completed $hideScript
                        $on_Completed = {}
                        $c.BeginAnimation(
                            $c.GetType()::OpacityProperty,
                            $fadeChange
                        )
                    } else {
                        $c.SetValue($c.GetType()::OpacityProperty, [Double]0)
                        $c.Visibility = "Collapsed"
                    }                    
                }
            }
            if ($autoScroll) {
                #If there's a scrollviewer, then scroll the scrollviewer 
                $scrollViewer = $null
                $p = $c.Parent            
                while ($p) {
                    if ($p -is [Windows.Controls.ScrollViewer]) {
                        $scrollViewer = $p
                        break
                    }
                    $p = $p.Parent
                }
                if ($scrollViewer) {
                    if ($duration.TotalMilliseconds) {
                        $guid = [GUID]::NewGuid().ToString()
                        $window.Resources.TemporaryControls."$guid" = $c
                        $scrollViewerGuid = [GUID]::NewGuid().ToString()
                        $window.Resources.TemporaryControls."$scrollViewerGuid" = $scrollViewer                        
                        $scrollScript = [ScriptBlock]::Create("
                            `$scrollViewer = `$window.Resources.TemporaryControls.'$scrollViewerGuid'
                            `$c = `$window.Resources.TemporaryControls.'$guid'                            
                            `$p = `$c.TranslatePoint(
                                (New-Object Windows.Point 0,0),
                                `$scrollViewer)
                            `$scrollViewer.ScrollToVerticalOffset(`$p.Y)
                            `$scrollViewer.ScrollToHorizontalOffset(`$p.X)
                            `$window.Resources.TemporaryControls.Remove('$guid')
                            `$window.Resources.TemporaryControls.Remove('$scrollViewerGuid')
                        ")
                        Register-PowerShellCommand `
                            -run -once -in $duration `
                            -scriptBlock $scrollScript                     
                    } else {
                        $p = $c.TranslatePoint(
                            (New-Object Windows.Point 0,0),
                            $scrollViewer)
                        $scrollViewer.ScrollToVerticalOffset($p.X)
                        $scrollViewer.ScrollToHorizontalOffset($p.Y)
                    }
                }
            }                            
        }
    }   
}
 
