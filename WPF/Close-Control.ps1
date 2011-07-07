function Close-Control
{
    param(
    [Parameter(ValueFromPipeline=$true)]
    [Windows.Media.Visual]
    $Visual = $this
    )
    
    process {
        if (-not $visual) { return } 
        $parent = Get-ParentControl -Control $Visual
        if ($parent) {
            if ($parent -is [Windows.Window]) {
                $parent.Close()
            } elseif ($parent.Parent -is [Windows.Window]) {
                $parent.Parent.Close()
            } else {
                $parent.Visibility = 'Collapsed'
            }            
        } else {
            
        }
    }
} 
