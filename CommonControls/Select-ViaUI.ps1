function Select-ViaUI {
#.Synopsis
#  Select objects through a visual interface
#.Description
# Uses a graphical interface to select (and pass-through) pipeline objects
# Idea from Lee Holmes (http://www.leeholmes.com/blog)

    [OutputType([Windows.Controls.Grid])]
    param(
    # The name of the control        
    [string]$Name,
    # If the control is a child element of a Grid control (see New-Grid),
    # then the Row parameter will be used to determine where to place the
    # top of the control.  Using the -Row parameter changes the 
    # dependency property [Windows.Controls.Grid]::RowProperty
    [Int]$Row,
    # If the control is a child element of a Grid control (see New-Grid)
    # then the Column parameter will be used to determine where to place
    # the left of the control.  Using the -Column parameter changes the
    # dependency property [Windows.Controls.Grid]::ColumnProperty
    [Int]$Column,
    # If the control is a child element of a Grid control (see New-Grid)
    # then the RowSpan parameter will be used to determine how many rows
    # in the grid the control will occupy.   Using the -RowSpan parameter
    # changes the dependency property [Windows.Controls.Grid]::RowSpanProperty 
    [Int]$RowSpan,
    # If the control is a child element of a Grid control (see New-Grid)
    # then the RowSpan parameter will be used to determine how many columns
    # in the grid the control will occupy.   Using the -ColumnSpan parameter
    # changes the dependency property [Windows.Controls.Grid]::ColumnSpanProperty
    [Int]$ColumnSpan,
    # The -Width parameter will be used to set the width of the control                
    [Int]$Width, 
    # The -Height parameter will be used to set the height of the control
    [Int]$Height,
    # If the control is a child element of a Canvas control (see New-Canvas),
    # then the Top parameter controls the top location within that canvas
    # Using the -Top parameter changes the dependency property 
    # [Windows.Controls.Canvas]::TopProperty
    [Double]$Top,
    # If the control is a child element of a Canvas control (see New-Canvas),
    # then the Left parameter controls the left location within that canvas
    # Using the -Left parameter changes the dependency property
    # [Windows.Controls.Canvas]::LeftProperty
    [Double]$Left,
    # If the control is a child element of a Dock control (see New-Dock),
    # then the Dock parameter controls the dock style within that panel
    # Using the -Dock parameter changes the dependency property
    # [Windows.Controls.DockPanel]::DockProperty
    [Windows.Controls.Dock]$Dock,
    # If Show is set, then the UI will be displayed as a modal dialog within the current
    # thread.  If the -Show and -AsJob parameters are omitted, then the control should be 
    # output from the function
    [Switch]$Show,
    # If AsJob is set, then the UI will displayed within a WPF job.
    [Switch]$AsJob        
)


    # We're going to need the parameters later
    $uiParameters = @{} + $psBoundParameters


## Get the item as it would be displayed by Format-Table
## Generate the window
# Show-UI -Title "Object Filter" -MinWidth 400 -Height 600 {
Grid -Margin 5  -ControlName SelectFTList -Rows Auto, *, Auto, Auto -Resource @{
    # The Resource dictionary is used to store information and default settings
    Cmdlet = $psCmdlet
    PSBoundParameters = $PSBoundParameters
    Args = $args
} -Children {

    # we need to store the original items ... so we can output them later
    # But we're going to convert them to strings to display them
    $SelectViaUIStringItems = New-Object System.Collections.ArrayList
    # So, use a hashtable, with the strings as the keys to the original values 
    $SelectViaUIOriginalItems = @{}
    ## Convert input to string representations and store ...
    foreach($item in $Input) {
        $stringRepresentation = (($item | ft -HideTableHeaders | Out-String )-Split"\n")[-4].trimEnd()
        $SelectViaUIOriginalItems[$stringRepresentation] = $item
        $null = $SelectViaUIStringItems.Add($stringRepresentation)
    }
    
    ## This is just a label ...
    TextBlock -Margin 5 -Row 0 "Type or click to search. Press Enter or click OK to pass the items down the pipeline." 
    
    ## Put the items in a ListBox, inside a ScrollViewer so it can scroll :)
    ScrollViewer -Margin 5 -Row 1 {
        ListBox -SelectionMode Multiple -ItemsSource $SelectViaUIStringItems -Name SelectedItems `
                -FontFamily "Consolas, Courier New" -On_MouseDoubleClick {
                                        $e = $_
                                        $parent | Set-UIValue -value $SelectViaUIOriginalItems[$e.OriginalSource.DataContext] -passthru | Close-Control
                                    }
    }

    ## This is the filter box: Notice we update the filter on_KeyUp
    TextBox -Margin 5 -Name SearchText -Row 2 -On_KeyUp {
        $filterText = $this.Text
        [System.Windows.Data.CollectionViewSource]::GetDefaultView( $SelectedItems.ItemsSource ).Filter = [Predicate[Object]]{ 
            param([string]$item)
            ## default to true
            trap { return $true }
            ## Do a regex match
            $item -match $filterText
        }
    }

    ## Use a GridPanel ... it's a simple, yet effective way to lay out a couple of buttons.
    Grid -Margin 5 -HorizontalAlignment Right -Columns 65, 10, 65 {
        Button "OK" -IsDefault -Width 65 -On_Click {
            $source = $selectedItems.Items

            if($selectedItems.SelectedItems.Count -gt 0)
            {
                $source = $selectedItems.SelectedItems
            }

            ## Use Write-UIOutput to send things out from the UI to the pipeline...
            $parent | Set-UIValue -value $SelectViaUIOriginalItems[$source] -passthru | Close-Control
        } -Column 0
        Button "Cancel" -IsCancel -Width 65 -Column 2
    } -Row 3
    ## Focus on the Search box by default
} -On_Loaded { $SearchText.Focus() } @uiParameters

}