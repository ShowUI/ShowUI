function Show-UIElement
{   
    <#
    .Synopsis
        Shows a UI Element
    .Description
        Changes the Visibility property of one or more UI Elements to Visible
    .Parameter control
        The UI Element to show
    .Parameter name
        The name of the UI Element or elements to show
    .Example
        New-Grid -Columns 2 {
            New-Button -Name "Left" "Show Right" -On_Click {            
                Show-UIElement Right
                $this | Hide-UIElement
            }
            New-Button -Visibility Collapsed -Column 1 -Name "Right" "Show Left" -On_Click {            
                Show-UIElement Left
                $this | Hide-UIElement
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
                $control.Visibility = 'Visible'
            }
            Name {
                foreach ($n in $name) {
                    $window | 
                        Get-ChildControl $n | 
                        Where-Object {
                            $_.Visibility                            
                        } | ForEach-Object {
                            $_.Visibility = 'Visible'
                        }
                }
            }
        }
    }
}
