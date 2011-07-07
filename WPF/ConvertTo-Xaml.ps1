function ConvertTo-Xaml 
{
    <#
        .Synopsis
            Attempts to coerce the text into XAML
        .Description
            Attempts to coerce the text into XAML
        .Example
            ConvertTo-Xaml "<Button Content='Click Me' />"
        .Parameter text
            The text to attempt to transform into XAML
    #>
    param([string]$text)
    
    $text = $text.Trim()
    if ($text[0] -ne "<") { return } 
    if ($text -like "*x:*" -and $text -notlike '*http://schemas.microsoft.com/winfx/2006/xaml*') {
        $text = $text.Trim()
        $firstSpace = $text.IndexOfAny(" >".ToCharArray())    
        $text = $text.Insert($firstSpace, ' xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" ')
    }

    if (-not $text) { return }
    $xml = $text -as [xml]
    if (-not $xml) { return } 
    $xml.SelectNodes("//*") |
        Select-Object -First 1 | 
        Foreach-Object {
            if (-not $_.xmlns) {
                $_.SetAttribute("xmlns", 'http://schemas.microsoft.com/winfx/2006/xaml/presentation')
            }
            $_.OuterXml
        }            
}
