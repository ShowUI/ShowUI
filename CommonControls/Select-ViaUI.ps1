function Select-ViaUI {
#.Synopsis
#   Select objects through a visual interface
#.Description
#   Uses a graphical interface to select (and pass-through) pipeline objects
#   Idea from Lee Holmes (http://www.leeholmes.com/blog)
#.Example
#   Get-ChildItem | Select-ViaUI -show | Remove-Item -WhatIf
    [OutputType([Windows.Controls.Grid])]
    [CmdletBinding(DefaultParameterSetName="DefaultView")]
    param(
    # Specifies the object properties that appear in the display and the order in which they appear. Type one or more property names (separated by commas), or use a hash table to display a calculated property. Wildcards are permitted.
    #
    # If you omit this parameter, the properties that appear in the display depend on the object being displayed. The parameter name ("Property") is optional. You cannot use the Property and View parameters in the same command.
    #
    # The value of the Property parameter can be a new calculated property. To create a calculated, property, use a hashtable. Valid keys are:
    # -- Name (or Label) <string>
    # -- Expression <string> or <script block> (MANDATORY)
    [Parameter(Position=0, ParameterSetName="Property")]
    [Object[]]$Property,

    # Specifies the name of an alternate table format or "view." You cannot use the Property and View parameters in the same command.
    [Parameter(ParameterSetName="View")]
    [String]$View,
    
    # Specifies the objects to be displayed for selection. Enter a variable that contains the objects, or type a command or expression that gets the objects.
    [Parameter(ValueFromPipeline=$true)]
    [PSObject[]]$InputObject,
    
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

begin {
   $Items = New-Object System.Collections.ArrayList
}
process {
   $Items.AddRange($InputObject)
}
end {
    # We're going to need the parameters later
    $uiParameters = @{} + $psBoundParameters
    $null = $uiParameters.Remove("Property")
    $null = $uiParameters.Remove("View")
    $null = $uiParameters.Remove("InputObject")
    
    $formatParameters = @{}
    if($psBoundParameters.ContainsKey("Property")){
        $formatParameters.Property = $PsBoundParameters.Property + @{Name="OriginalItem";Expression={$_}}
    }
    if($psBoundParameters.ContainsKey("View")){
        $formatParameters.View = $psBoundParameters.View
    }
    
    # we need to store the original items ... so we can output them later
    # But we're going to convert them to strings to display them
    $global:SelectViaUIStringItems = New-Object System.Collections.ArrayList
    if($psBoundParameters.ContainsKey("Property")) {
        $SelectViaUIStringItems = $items | Select-Object @formatParameters
        $Strings = $Items | Format-Table @formatParameters -AutoSize | Tee-Object -variable formattedData | Out-String -Width 10000 -Stream
        $tableColumnInfo = $formattedData[0].shapeInfo.tableColumnInfoList | 
                    Select-Object width, alignment, @{n="label";e={if($_.label){$_.label}else{$_.propertyName}}} | 
                    Where-Object { $_.label -ne "OriginalItem" } 
    } else {
        ## Convert input to string representations and store ...
        $Strings = $Items | Format-Table | Tee-Object -variable formattedData | Out-String -Width 10000 -Stream
        $tableColumnInfo = $formattedData[0].shapeInfo.tableColumnInfoList | Select-Object width, alignment, @{n="label";e={if($_.label){$_.label}else{$_.propertyName}}}
        for($c=0;$c -lt $Strings.Length;$c++) {
            ## We're looking for a line that has at least one "-" and nothing but " " and "-"
            if( $Strings[$c] -match '^ *-+[ -]*$' ) {
                $separators = [regex]::Matches($Strings[$c],"(?<=^|\s+)-+") + (New-Object PSObject -Property @{Index =$Delimiters.Length})
                break
            }
        }
        #  $Headers =  foreach($column in $separators) {
            #  $Strings[($c-1)].substring($column.Index,$column.length).TrimEnd()
        #  }
        $Strings = $Strings[($c+1)..($Strings.Count -2)] | where-object { $_ }

        # $formattedData[@(2..($formattedData.Count-3))] | %{ $field = $_.formatEntryInfo.formatPropertyFieldList[0]; $_.formatEntryInfo.formatPropertyFieldList.clear(); $_.formatEntryInfo.formatPropertyFieldList.Add($field) }
        for($i=0; $i -lt $Items.Count;$i++) {
            $start = 0
            $line = $Strings[$i]
            $outputRow = @{} 
            for($c=0;$c -lt $tableColumnInfo.Count;$c++) {
                $length = $tableColumnInfo[$c].width
                if(!$length) { 
                    if($tableColumnInfo.Count -gt $c) {
                        ## If right aligned, use the right side of the column header:
                        if($tableColumnInfo[$c].alignment -eq 3) {
                            $length = $start - ($separators[$c].index + $separators[$c].length)
                        ## If the NEXT one is left aligned, use the left side of that header
                        } elseif($tableColumnInfo[$c+1].alignment -eq 1) {
                            $length = $Start - $separators[$c+1].index
                        ## Otherwise, it's really hard to say what the right answer is...
                        ## Technically, we need to scan all the way down the columns looking for whitespace
                        ## Let's try a shortcut though...
                        } else {
                            $length = $start - ($separators[$c].index + $separators[$c].length)
                        }
                    }
                    $length = $tableColumnInfo[$c].width = $line.Length - $start
                }
                # Write-Warning "Start: $start, Length: $length (of $($line.Length))"
                $outputRow.($tableColumnInfo[$c].label) = $line.substring($start, $length).Trim()
                $start += $length + 1
            }
            $outputRow = New-Object PSObject -Property $outputRow
            $outputRow | Add-Member -Type NoteProperty -Name OriginalItem -Value $Items[$i]
            $null = $SelectViaUIStringItems.Add( $outputRow )
        }
    }
    # Stick the original items on there ...
    $SelectViaUIStringItems | Add-Member -Type ScriptMethod -Name ToString -Value { ($this.OriginalItem | Format-Table @formatParameters -HideTableHeaders | Out-String -Width 10000).Trim() } -Force

## Generate the window
# Show-UI -Title "Object Filter" -MinWidth 400 -Height 600 {
Grid -Margin 5 -Name Grid -ControlName SelectFTList -Rows Auto, *, Auto, Auto -Children {
    ## This is just a label ...
    TextBlock -Margin 5 -Row 0 "Type or click to search. Press Enter or click OK to pass the items down the pipeline." 

    ## Put the items in a ListBox, inside a ScrollViewer so it can scroll :)
    ScrollViewer -Margin 5 -Row 1 {
        ListView -SelectionMode Extended -ItemsSource $SelectViaUIStringItems -Name SelectedItems `
                -FontFamily "Consolas, Courier New" -View {
                    GridView -Columns {
                        foreach($h in $tableColumnInfo) {
                            GridViewColumn -Header $h.label -DisplayMember { Binding $h.Label }
                        }
                    }
                } -On_SelectionChanged {
                    if($selectedItems.SelectedItems.Count -gt 0)
                    {
                        $SelectFTList | Set-UIValue -value ( $selectedItems.SelectedItems | ForEach-Object { $_.OriginalItem } )
                    } else {
                        $SelectFTList | Set-UIValue -value ( $selectedItems.Items | ForEach-Object { $_.OriginalItem } )
                    }
                } -On_Loaded {
                    ## Default output, in case you close the window without selecting anything
                    $SelectFTList | Set-UIValue -value ( $selectedItems.Items | ForEach-Object { $_.OriginalItem } )
                }
                # -On_MouseDoubleClick { Close-Control $parent }
    } -On_Load {
    
        Add-EventHandler -Input $SelectedItems -SourceType GridViewColumnHeader -EventName Click { 
            if($_.OriginalSource -and $_.OriginalSource.Role -ne "Padding") {
                $direction = if($this -eq $lastSort) { "Descending" } else { "Ascending" }
                $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView( $SelectedItems.ItemsSource )
                $view.SortDescriptions.Clear()
                $view.SortDescriptions.Add(( New-Object System.ComponentModel.SortDescription $_.OriginalSource.Column.Header, $direction ))
                $view.Refresh()
            }
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
        
        ## Update the output after the filter
        if($selectedItems.SelectedItems.Count -gt 0)
        {
            $SelectFTList | Set-UIValue -value ( $selectedItems.SelectedItems | ForEach-Object { $_.OriginalItem } )
        } else {
            $SelectFTList | Set-UIValue -value ( $selectedItems.Items | ForEach-Object { $_.OriginalItem } )
        }
    }

    ## Use a GridPanel ... it's a simple, yet effective way to lay out a couple of buttons.
    Grid -Margin 5 -HorizontalAlignment Right -Columns 65, 10, 65 {
        Button "OK" -IsDefault -Width 65 -On_Click { Close-Control $window } -Column 0
        Button "Cancel" -IsCancel -Width 65 -On_Click { $SelectFTList | Set-UIValue -value $null } -Column 2
    } -Row 3
    ## Focus on the Search box by default
} -On_Loaded { 
    $SearchText.Focus()
} @uiParameters

}}