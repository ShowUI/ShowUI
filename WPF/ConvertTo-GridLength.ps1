function ConvertTo-GridLength
{
    <#
    .Synopsis
        Turns $legnth into Windows.GirdLength objects
    .Description
        Turns the length parameter into GridLength objects.
    .Parameter length
        If the Length is just one integer, than that number of grid lengths will be created.
        If the Length is a list of strings and integers, then individual rows will be created
            If the string is 'Auto', the GridLength will be AutoSized
            If the string is a number followed by *, the GridLength will be a ratio of the available space
            If the string is a number, then the GridLength will be a specific number of pixels
    .Example
        ConvertTo-GridLength 5
    .Example
        ConvertTo-GridLength 'Auto','1*', 'Auto'
    #>
    param(
    $length
    )
    
    if ($length -as [uint32]) {
        foreach ($n in (1..$length)) {
            New-Object Windows.GridLength 1,Star
        }
    } else {
        foreach ($l in $length) {
            switch ($l) {
                Auto {
                    New-Object Windows.GridLength 1, Auto
                }
                {$_ -as [Double]} {
                    New-Object Windows.GridLength $_, Pixel
                }
                {"$_".EndsWith('*')} {
                    $ratio = "$_".Split("*")[0]
                    if (-not $ratio) { $ratio = 1 } 
                    New-Object Windows.GridLength $ratio, Star 
                }
            }
        }
    }
}
