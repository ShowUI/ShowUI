function Hide-UIElement
{
    <#
    .Synopsis
        Hides a UI Element
    .Description
        Changes the Visibility property of one or more UI Elements to collapsed
    .Parameter control
        The UI Element to hide
    .Parameter name
        The name of the UI Element or elements to hide
    .Example
        New-Window {
            New-StackPanel -Children {
                New-Button "Click Me" -On_Click { $this | Hide-UIElement } 
            }
        } -show
    #>
    param(
        [Parameter(ParameterSetName='Control', Mandatory=$true,ValueFromPipeline=$true)]
        [Windows.UIElement]
        $control,
        
        [Parameter(ParameterSetName='Name', Mandatory=$true,Position=0)]
        [string[]]
        $name
    )
    
    process {
        switch ($psCmdlet.ParameterSetName) {
            Control {
                $control.Visibility = 'Collapsed'
            }
            Name {
                foreach ($n in $name) {
                    $window | 
                        Get-ChildControl $n | 
                        Where-Object {
                            $_.Visibility                            
                        } | ForEach-Object {
                            $_.Visibility = 'Collapsed'
                        }
                }
            }
        }
    }
}
