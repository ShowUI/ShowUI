function Start-Animation{
    <#
    .Synopsis
        Starts animations on a property in any number of inputObjects
    .Description
        Starts animations on a property in any number of inputObjects
    .Example
        New-Window "Hello World" -SizeToContent WidthAndHeight -On_Loaded { 
            $this | 
                Start-Animation -property "FontSize" -animation (
                    New-DoubleAnimation -From 10 -To 100 -Duration (New-TimeSpan -Seconds 1)
                )      
        } -show    
    .Parameter inputObject
        An object with DependencyProperties that can be animated.
    .Parameter property
        The name of the property to animate    
    .Parameter animation
        The animation to run on the property
    #>
    param(
    [Parameter(ValueFromPipeline=$true)]
    $inputObject,
    
    [Parameter(Mandatory=$true)]
    [PSObject[]]$property,
    
    [Windows.Media.Animation.AnimationTimeline[]]
    $animation)
    
    process {
        foreach ($p in $property) { 

            if ($p -is [Windows.DependencyProperty]) {
                $dp = $p
            }
            if ($p -is [string]) {            
                $dp = $inputObject.GetType()::"${P}Property"
                if (-not $dp) {
                    Write-Error "$p not found on $($inputObject.GetType().Fullname)"
                }
            }
            if (-not $dp) { return } 
            if (-not $inputObject.BeginAnimation) {
                return 
            }
            foreach ($a in $animation) {
                $null = $inputObject.BeginAnimation($dp, $a)
            }
        }
    }
}
