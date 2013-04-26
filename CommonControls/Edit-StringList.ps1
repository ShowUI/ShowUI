function Edit-StringList
{
    <#
        .Synopsis
            Edits (and returns) a list of strings.
        .Description
            Edits a list of strings.          
    #>
    [OutputType([Windows.Controls.Grid], [string[]])]
    param(
        # Starting contents of a list
        [string[]]$List,

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
    process {
        $null = $PsBoundParameters.Remove('List')
        New-Grid -Rows (@('Auto')*4) -Columns 1 -ControlName Edit-List @PsBoundParameters -Resource @{
            # The Resource dictionary is used to store information and default settings
            ListItems = $List
        } -On_Loaded {
            $List.ItemsSource = $ListItems
            Set-UIValue -Ui $this -Value ($List.ItemsSource -as [string[]])
        } {
            New-ListBox -SelectionMode Multiple -Row 0 -Name List -On_SelectionChanged {
                $Remove.IsEnabled = $this.SelectedIndex -ge 0
            } -On_PreviewKeyDown {
                if($_.Key -eq "Delete") {
                    $this.ItemsSource = @( $this.ItemsSource | Where-Object { $this.SelectedItems -notcontains $_ } )
                    $_.Handled = $true
                }
            }
            New-UniformGrid -Row 1 -Rows 1 {            
                New-Button -Name Add -FontSize 14 -FontWeight Bold '+' -On_Click {
                    $AddTextBox.Visibility = $OkButton.Visibility = 'Visible'
                    $AddTextBox.Focus()                     
                }
                New-Button -Name Remove -FontSize 14 -FontWeight Bold '-' -On_Click {
                    $list.ItemsSource = @( $List.ItemsSource | Where-Object { $List.SelectedItems -notcontains $_ } )
                    Set-UIValue -Ui $parent -Value ($list.ItemsSource -as [string[]])
                }
            }
            
            New-TextBox -Row 2 -Visibility Collapsed -Name AddTextBox -AcceptsReturn -On_PreviewKeyDown {
                if ($_.Key -eq 'Enter') {
                    $_.Handled = $true                    
                    if ($this.Text) {
                        $List.ItemsSource = @($this.Text) + @($list.ItemsSource)
                        $this.Text = ""
                        Set-UIValue -Ui $parent -Value ($list.ItemsSource -as [string[]])
                    } 
                }                
            }
                                            
            New-Button -Row 3 -Visibility Collapsed -Name OkButton "_Ok" -On_Click {
                if ($AddTextBox.Text) {
                    $List.ItemsSource = @($AddTextBox.Text) + @($list.ItemsSource)
                    $AddTextBox.Text = ""
                    Set-UIValue -Ui $parent -Value ($list.ItemsSource -as [string[]])
                }
                $addTextBox.Visibility = $okButton.Visibility = 'Collapsed'
            }        
        }
    }
}
