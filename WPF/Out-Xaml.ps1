function Out-Xaml
{
    param(
    [Parameter(ValueFromPipeline=$true)]
    $InputObject,
    
    [switch]
    [Alias('ShowQuickly')]
    $Flash,
    
    [switch]
    $AsXml    
    )
    
    process {
        if ($Flash) {
            New-Window -Top -10000 -Left -10000 -On_ContentRendered {            
                $window.Close()#Register-PowerShellCommand -ScriptBlock { $window.Close() } -Run -In "0:0:1"                
            } -Content $inputObject -Show
        }
        $xaml = [Windows.Markup.XamlWriter]::Save($inputObject)
        if (-not $?) { return}
        $xml = [Xml]$xaml
        
        $nodes = @()
        
        $nodes += 
            Select-Xml -Xml $xml -XPath //sma:PSObject -Namespace @{
                sma='clr-namespace:System.Management.Automation;assembly=System.Management.Automation'
            } | 
                Select-Object -ExpandProperty Node
        
        $nodes += Select-Xml -Xml $xml -XPath //@x:Uid -Namespace @{
                x='http://schemas.microsoft.com/winfx/2006/xaml'
            } | 
                Select-Object -ExpandProperty Node
                
        $nodes += Select-Xml -Xml $xml -XPath //sc:Hashtable -Namespace @{
                sc='clr-namespace:System.Collections;assembly=mscorlib'
            } | 
                Select-Object -ExpandProperty Node
        
        foreach ($node in $nodes) { 
            if ($node.ParentNode) {
                $null = $node.ParentNode.RemoveChild($node)
            }
        }
        
        if ($AsXml){
            return $xml
        } else {
            $strWrite = New-Object IO.StringWriter
            $xml.Save($strWrite)
            return "$strWrite"
        }         
    }
}
